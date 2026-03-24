## ScenarioManager — Loads scenario definitions, spawns entities, manages lifecycle.
## Autoload singleton registered in project.godot.
extends Node

## Emitted when a scenario definition has been parsed and entities spawned.
signal scenario_loaded(scenario_data: Dictionary)

## Emitted when gameplay begins (timer starts, state → PLAYING).
signal scenario_started()

## Emitted when the scenario ends (timer stops, state → DEBRIEF).
signal scenario_ended(results: Dictionary)

## Scene paths for equipment types — maps JSON type string to scene path.
const EQUIPMENT_SCENES := {
	"AED": "res://scenes/entities/equipment/AED.tscn",
	"BANDAGE": "res://scenes/entities/equipment/Bandage.tscn",
	"SPLINT": "res://scenes/entities/equipment/Splint.tscn",
	"OXYGEN_MASK": "res://scenes/entities/equipment/OxygenMask.tscn",
	"STRETCHER": "res://scenes/entities/equipment/Stretcher.tscn",
}

## Patient base scene.
const PATIENT_SCENE := "res://scenes/entities/patients/PatientBase.tscn"

## Current scenario data (parsed from JSON).
var current_scenario: Dictionary = {}

## Scenario timer.
var _time_limit: float = 0.0
var _elapsed_time: float = 0.0
var _scenario_running: bool = false

## Spawned entity references for cleanup.
var _spawned_entities: Array[Node] = []

## HazardSystem instance — manages environmental hazards (MON-14).
var _hazard_system: Node = null

## Preload HazardSystem script.
const HazardSystemScript := preload("res://scripts/gameplay/hazard_system.gd")

## RandomEventSystem instance — manages mid-scenario events (MON-15).
var _random_event_system: Node = null

## Preload RandomEventSystem script.
const RandomEventSystemScript := preload("res://scripts/gameplay/random_event_system.gd")


func _process(delta: float) -> void:
	if not _scenario_running:
		return
	_elapsed_time += delta
	if _time_limit > 0.0 and _elapsed_time >= _time_limit:
		TelemetryCollector.record_time_expired()
		end_scenario()


## Load a scenario from a JSON file path. Spawns entities into the current scene.
func load_scenario(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("ScenarioManager: Cannot open scenario file: %s" % path)
		return

	var json := JSON.new()
	var parse_result := json.parse(file.get_as_text())
	if parse_result != OK:
		push_error("ScenarioManager: JSON parse error in %s: %s" % [path, json.get_error_message()])
		return

	current_scenario = json.data
	_time_limit = current_scenario.get("time_limit_seconds", 0.0)

	# Enforce minimum time guarantee: at least 180 seconds (3 minutes) per patient.
	# Prevents scenarios from being unsolvable due to overly tight time limits.
	if _time_limit > 0.0:
		var patient_count: int = current_scenario.get("patients", []).size()
		_time_limit = maxf(_time_limit, patient_count * 180.0)

	# Change to the environment scene if specified
	var env_path: String = current_scenario.get("environment_scene_path", "")
	if env_path != "":
		# change_scene uses call_deferred, so we must wait for the new scene to be ready
		get_tree().change_scene_to_file(env_path)
		# Wait until the new scene is fully loaded and set as current_scene
		await get_tree().tree_changed
		# Keep waiting if current_scene is still null (deferred load not finished)
		while get_tree().current_scene == null:
			await get_tree().process_frame
		# One more frame to let _ready() run on all nodes
		await get_tree().process_frame

	_spawn_entities()

	# Wire telemetry signals and medical bag tier after entities are spawned
	var scene_root: Node = get_tree().current_scene
	var player: Node = scene_root.find_child("Player", true, false) if scene_root else null
	if player:
		TelemetryCollector.wire_player_signals(player)
		# Set the player's medical bag tier from scenario data (MON-17 integration)
		var bag_tier: String = current_scenario.get("bag_tier", "BLS")
		var bag_manager: Node = player.get_node_or_null("MedicalBagTierManager")
		if bag_manager and bag_manager.has_method("set_tier"):
			bag_manager.set_tier(bag_tier)

	scenario_loaded.emit(current_scenario)


## Spawn all patients and equipment defined in the scenario data.
func _spawn_entities() -> void:
	var scene_root: Node = get_tree().current_scene

	# Spawn patients
	var patients: Array = current_scenario.get("patients", [])
	var patient_scene := load(PATIENT_SCENE) as PackedScene
	for patient_def: Dictionary in patients:
		var patient := patient_scene.instantiate()
		scene_root.add_child(patient)

		# Set position from scenario data
		var pos: Dictionary = patient_def.get("position", {})
		patient.position = Vector3(
			pos.get("x", 0.0),
			pos.get("y", 0.0),
			pos.get("z", 0.0)
		)

		# Random Y rotation so patients don't all face the same direction
		patient.rotation_degrees.y = randf_range(0.0, 360.0)

		# Small random XZ offset for visual variation
		patient.position += Vector3(randf_range(-0.5, 0.5), 0.0, randf_range(-0.5, 0.5))

		# Configure persona if data is provided
		var persona_data: Dictionary = patient_def.get("persona", {})
		if not persona_data.is_empty() and patient.has_method("set") and "persona" in patient:
			var persona := PatientPersona.new()
			persona.patient_name = persona_data.get("name", "Unknown Patient")
			persona.age = persona_data.get("age", 30)
			persona.consciousness_level = persona_data.get("consciousness_level", "ALERT")
			persona.pain_level = persona_data.get("pain_level", 0)
			persona.panic_level = persona_data.get("panic_level", 0.0)
			persona.language_clarity = persona_data.get("language_clarity", 1.0)
			# Load SAMPLE history data from scenario JSON
			var history_data: Dictionary = patient_def.get("history", {})
			if not history_data.is_empty():
				persona.history_symptoms = history_data.get("symptoms", {})
				persona.history_allergies = history_data.get("allergies", {})
				persona.history_medications = history_data.get("medications", {})
				persona.history_past = history_data.get("past_history", {})
				persona.history_last_meal = history_data.get("last_meal", {})
				persona.history_events = history_data.get("events", {})
				persona.history_opqrst = history_data.get("opqrst", {})

			patient.persona = persona

		# Configure medical state
		var initial_state: String = patient_def.get("initial_state", "CONSCIOUS")
		var medical_comp: Node = patient.get_node_or_null("MedicalStateComponent")
		if medical_comp:
			var state_map := {
				"CONSCIOUS": 0,
				"UNCONSCIOUS": 1,
				"CARDIAC_ARREST": 2,
				"DEAD": 3,
			}
			medical_comp.current_state = state_map.get(initial_state, 0)
			# Set modifiers from scenario data
			var modifiers: Dictionary = patient_def.get("modifiers", {})
			if modifiers.has("bleeding_severity"):
				medical_comp.bleeding_severity = modifiers["bleeding_severity"]
			if modifiers.has("airway_status"):
				medical_comp.airway_status = modifiers["airway_status"]
			if modifiers.has("breathing_rate"):
				medical_comp.breathing_rate = modifiers["breathing_rate"]
			if modifiers.has("pulse_present"):
				medical_comp.pulse_present = modifiers["pulse_present"]

			# Load vital signs from scenario data (MON-11)
			var vitals_data: Dictionary = patient_def.get("vitals", {})
			if not vitals_data.is_empty() and medical_comp:
				if vitals_data.has("heart_rate"):
					medical_comp.heart_rate = vitals_data["heart_rate"]
				if vitals_data.has("blood_pressure_systolic"):
					medical_comp.blood_pressure_systolic = vitals_data["blood_pressure_systolic"]
				if vitals_data.has("blood_pressure_diastolic"):
					medical_comp.blood_pressure_diastolic = vitals_data["blood_pressure_diastolic"]
				if vitals_data.has("spo2"):
					medical_comp.spo2 = vitals_data["spo2"]
				if vitals_data.has("temperature"):
					medical_comp.temperature = vitals_data["temperature"]
				if vitals_data.has("blood_glucose"):
					medical_comp.blood_glucose = vitals_data["blood_glucose"]
				if vitals_data.has("capillary_refill"):
					medical_comp.capillary_refill = vitals_data["capillary_refill"]
				if vitals_data.has("pupil_left_size"):
					medical_comp.pupil_left_size = vitals_data["pupil_left_size"]
				if vitals_data.has("pupil_right_size"):
					medical_comp.pupil_right_size = vitals_data["pupil_right_size"]
				if vitals_data.has("pupil_left_reactive"):
					medical_comp.pupil_left_reactive = vitals_data["pupil_left_reactive"]
				if vitals_data.has("pupil_right_reactive"):
					medical_comp.pupil_right_reactive = vitals_data["pupil_right_reactive"]
				if vitals_data.has("skin_color"):
					medical_comp.skin_color = vitals_data["skin_color"]
				if vitals_data.has("skin_temperature"):
					medical_comp.skin_temperature = vitals_data["skin_temperature"]
				if vitals_data.has("skin_moisture"):
					medical_comp.skin_moisture = vitals_data["skin_moisture"]
				if vitals_data.has("ecg_rhythm"):
					medical_comp.ecg_rhythm = vitals_data["ecg_rhythm"]
				if vitals_data.has("gcs_eye"):
					medical_comp.gcs_eye = vitals_data["gcs_eye"]
				if vitals_data.has("gcs_verbal"):
					medical_comp.gcs_verbal = vitals_data["gcs_verbal"]
				if vitals_data.has("gcs_motor"):
					medical_comp.gcs_motor = vitals_data["gcs_motor"]
				if vitals_data.has("co_exposure"):
					medical_comp.co_exposure = vitals_data["co_exposure"]
				# Load examination findings (MON-12)
				medical_comp.examination_findings = patient_def.get("examination_findings", {})

		# Configure deterioration rates from scenario data
		var deterioration_comp: Node = patient.get_node_or_null("DeteriorationSystem")
		if deterioration_comp:
			var det_data: Dictionary = patient_def.get("deterioration", {})
			if det_data.has("rate"):
				deterioration_comp.deterioration_rate = det_data["rate"]
			if det_data.has("enabled"):
				deterioration_comp.deterioration_enabled = det_data["enabled"]
			if det_data.has("bleeding_interval"):
				deterioration_comp.bleeding_interval = det_data["bleeding_interval"]
			if det_data.has("airway_to_unconscious"):
				deterioration_comp.airway_to_unconscious = det_data["airway_to_unconscious"]
			if det_data.has("unconscious_to_cardiac"):
				deterioration_comp.unconscious_to_cardiac = det_data["unconscious_to_cardiac"]
			if det_data.has("cardiac_to_dead"):
				deterioration_comp.cardiac_to_dead = det_data["cardiac_to_dead"]

		_spawned_entities.append(patient)

	# Spawn equipment
	var equipment: Array = current_scenario.get("equipment", [])
	for equip_def: Dictionary in equipment:
		var equip_type: String = equip_def.get("type", "BANDAGE")
		var scene_path: String = EQUIPMENT_SCENES.get(equip_type, "")
		if scene_path == "":
			push_warning("ScenarioManager: Unknown equipment type: %s" % equip_type)
			continue

		var equip_scene := load(scene_path) as PackedScene
		var equip := equip_scene.instantiate()
		scene_root.add_child(equip)

		var pos: Dictionary = equip_def.get("position", {})
		equip.position = Vector3(
			pos.get("x", 0.0),
			pos.get("y", 0.0),
			pos.get("z", 0.0)
		)

		# Configure EquipmentData if the entity supports it
		if "equipment_data" in equip and equip.equipment_data == null:
			var eq_data := EquipmentData.new()
			eq_data.equipment_name = equip_def.get("name", equip_type)
			eq_data.use_label = equip_def.get("use_label", "Use")
			var type_map := {
				"AED": EquipmentData.EquipmentType.AED,
				"BANDAGE": EquipmentData.EquipmentType.BANDAGE,
				"SPLINT": EquipmentData.EquipmentType.SPLINT,
				"OXYGEN_MASK": EquipmentData.EquipmentType.OXYGEN_MASK,
				"STRETCHER": EquipmentData.EquipmentType.STRETCHER,
			}
			eq_data.equipment_type = type_map.get(equip_type, EquipmentData.EquipmentType.BANDAGE)
			equip.equipment_data = eq_data

		_spawned_entities.append(equip)

	# Spawn environmental hazards (MON-14)
	var hazard_defs: Array = current_scenario.get("hazards", [])
	if not hazard_defs.is_empty():
		_hazard_system = Node.new()
		_hazard_system.set_script(HazardSystemScript)
		_hazard_system.name = "HazardSystem"
		scene_root.add_child(_hazard_system)
		_hazard_system.spawn_hazards(hazard_defs, scene_root)

	# Setup random events (MON-15)
	var event_defs: Array = current_scenario.get("random_events", [])
	if not event_defs.is_empty():
		_random_event_system = Node.new()
		_random_event_system.set_script(RandomEventSystemScript)
		_random_event_system.name = "RandomEventSystem"
		scene_root.add_child(_random_event_system)
		_random_event_system.setup(event_defs, scene_root)


## Start the scenario — begins timer and telemetry.
func start_scenario() -> void:
	if current_scenario.is_empty():
		push_error("ScenarioManager: No scenario loaded.")
		return

	_elapsed_time = 0.0
	_scenario_running = true
	GameManager.change_state(GameManager.GameState.PLAYING)
	TelemetryCollector.start_session(current_scenario.get("scenario_id", "unknown"))
	# Start random events if configured
	if _random_event_system:
		_random_event_system.start()
	scenario_started.emit()


## End the scenario — stops timer, gathers results.
func end_scenario() -> void:
	if not _scenario_running:
		return  # Prevent double-end (e.g., incapacitation + time expiry race)
	_scenario_running = false
	# Stop random events
	if _random_event_system:
		_random_event_system.stop()
	# Read player hazard exposure BEFORE cleanup (cleanup frees zone nodes)
	var player_hazard_time: float = 0.0
	if _hazard_system and is_instance_valid(_hazard_system):
		# Stop processing immediately to prevent lingering damage/effects
		_hazard_system.set_process(false)
		if "player_total_hazard_time" in _hazard_system:
			player_hazard_time = _hazard_system.player_total_hazard_time
		# Now safe to destroy hazard zones
		if _hazard_system.has_method("cleanup"):
			_hazard_system.cleanup()

	GameManager.change_state(GameManager.GameState.DEBRIEF)
	var session_data := TelemetryCollector.end_session()

	# Flatten session_data into results for debrief screen consumption
	var events: Array = session_data.get("events", [])

	# Count patients in scenario
	var patient_defs: Array = current_scenario.get("patients", [])
	var patient_count: int = patient_defs.size()

	# Build patient summaries from spawned entities
	var patient_summaries: Array = _build_patient_summaries()

	# Compute triage summary from events
	var triage_summary: Dictionary = _compute_triage_summary(events)

	# Compute diagnosis results
	var diagnosis_summary: Dictionary = _compute_diagnosis_summary()

	var results := {
		"scenario_id": current_scenario.get("scenario_id", "unknown"),
		"scenario_name": current_scenario.get("scenario_name", "Unknown Scenario"),
		"elapsed_time": _elapsed_time,
		"duration_seconds": _elapsed_time,
		"time_limit": _time_limit,
		"patient_count": patient_count,
		"events": events,
		"patient_summaries": patient_summaries,
		"triage_summary": triage_summary,
		"diagnosis_summary": diagnosis_summary,
		"correct_diagnosis": current_scenario.get("correct_diagnosis", []),
		"session_data": session_data,
		"player_hazard_time": player_hazard_time,
	}
	scenario_ended.emit(results)

	# Save results for dashboard access
	_last_results = results


## Last completed scenario results (for dashboard to read).
var _last_results: Dictionary = {}


## Get the last scenario results (for dashboard/export).
func get_last_results() -> Dictionary:
	return _last_results


## Build per-patient summary from spawned entities.
func _build_patient_summaries() -> Array:
	var summaries: Array = []
	var scene_root: Node = get_tree().current_scene
	if not scene_root:
		return summaries

	for entity in _spawned_entities:
		if not is_instance_valid(entity):
			continue
		var medical: Node = entity.get_node_or_null("MedicalStateComponent")
		if not medical:
			continue

		var patient_name := "Unknown"
		if "persona" in entity and entity.persona:
			patient_name = entity.persona.patient_name

		var state_names := ["CONSCIOUS", "UNCONSCIOUS", "CARDIAC_ARREST", "DEAD"]
		var current_state_idx: int = medical.current_state if "current_state" in medical else 0
		var final_state: String = state_names[current_state_idx] if current_state_idx < state_names.size() else "UNKNOWN"

		# Use correct triage stored AT TIME OF TAGGING (not end-of-scenario state).
		# Falls back to current algorithm if patient was never tagged.
		var correct_triage: String = "Unknown"
		if entity.has_meta("triage_correct_at_assignment"):
			correct_triage = str(entity.get_meta("triage_correct_at_assignment"))
		elif medical.has_method("get_triage_priority"):
			correct_triage = medical.get_triage_priority()

		var summary := {
			"name": patient_name,
			"final_state": final_state,
			"triage_tag": "",
			"triage_correct": false,
			"correct_triage": correct_triage,
			"deployed_equipment": [],
			"diagnoses": [],
		}

		# Read triage tag and correctness from meta (set at tagging time by TriageSystem)
		if entity.has_meta("triage_tag"):
			summary["triage_tag"] = str(entity.get_meta("triage_tag"))
			summary["triage_correct"] = entity.get_meta("triage_correct") if entity.has_meta("triage_correct") else false

		# Read deployed equipment
		if entity.has_meta("deployed_equipment"):
			summary["deployed_equipment"] = entity.get_meta("deployed_equipment")

		# Read player diagnoses
		if entity.has_meta("player_diagnoses"):
			summary["diagnoses"] = entity.get_meta("player_diagnoses")
		if entity.has_meta("diagnosis_matches"):
			summary["diagnosis_matches"] = entity.get_meta("diagnosis_matches")

		summaries.append(summary)

	return summaries


## Compute triage accuracy from telemetry events.
func _compute_triage_summary(events: Array) -> Dictionary:
	var total_tagged: int = 0
	var correct_count: int = 0

	for event: Dictionary in events:
		if event.get("type", "") == "triage_assign":
			total_tagged += 1
			if event.get("details", {}).get("was_correct", false):
				correct_count += 1

	var accuracy: float = 0.0
	if total_tagged > 0:
		accuracy = float(correct_count) / float(total_tagged) * 100.0

	return {
		"total_tagged": total_tagged,
		"correct_count": correct_count,
		"accuracy": accuracy,
	}


## Compute diagnosis summary from patient metadata.
func _compute_diagnosis_summary() -> Dictionary:
	var total_patients: int = 0
	var correct_count: int = 0
	var total_matches: int = 0

	for entity in _spawned_entities:
		if not is_instance_valid(entity):
			continue
		if not entity.has_meta("player_diagnoses"):
			continue
		total_patients += 1
		var matches: int = entity.get_meta("diagnosis_matches") if entity.has_meta("diagnosis_matches") else 0
		total_matches += matches
		if matches > 0:
			correct_count += 1

	return {
		"patients_diagnosed": total_patients,
		"patients_with_correct": correct_count,
		"total_matches": total_matches,
	}


## Get elapsed scenario time in seconds.
func get_elapsed_time() -> float:
	return _elapsed_time


## Clean up all spawned entities (call before loading a new scenario).
func cleanup() -> void:
	for entity in _spawned_entities:
		if is_instance_valid(entity):
			entity.queue_free()
	_spawned_entities.clear()
	# Clean up hazard system
	if _hazard_system and is_instance_valid(_hazard_system):
		_hazard_system.cleanup()
		_hazard_system.queue_free()
		_hazard_system = null
	# Clean up random event system
	if _random_event_system and is_instance_valid(_random_event_system):
		_random_event_system.queue_free()
		_random_event_system = null
	current_scenario = {}
	_scenario_running = false
	_elapsed_time = 0.0


## Get the HazardSystem instance (for external systems to query).
func get_hazard_system() -> Node:
	return _hazard_system


## Get the RandomEventSystem instance (for external systems to query).
func get_random_event_system() -> Node:
	return _random_event_system
