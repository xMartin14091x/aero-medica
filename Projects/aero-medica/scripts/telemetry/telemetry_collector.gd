## TelemetryCollector — Singleton that receives and stores all gameplay telemetry.
## Autoload registered in project.godot.
## Phase 3: scenario lifecycle events, movement_data integration.
extends Node

## Emitted when a session starts (for other systems to react).
signal session_started(scenario_id: String)

## Emitted when a session ends.
signal session_ended(scenario_id: String)

## All action events recorded this session.
var session_events: Array[Dictionary] = []

## Movement position samples — populated by PositionTracker (MON-13).
var movement_data: Array[Dictionary] = []

## Patient proximity times — populated by PositionTracker (MON-13).
var patient_proximity_times: Dictionary = {}

## Active scenario identifier.
var _scenario_id: String = ""

## Session start timestamp (msec). Public for TelemetryEmitter to read.
var _session_start_msec: int = 0

## Whether a session is currently active.
var _session_active: bool = false


## Begin a new telemetry session. Clears previous data.
func start_session(scenario_id: String) -> void:
	_scenario_id = scenario_id
	_session_start_msec = Time.get_ticks_msec()
	_session_active = true
	session_events.clear()
	movement_data.clear()
	patient_proximity_times.clear()

	# Log session start event
	record_event({
		"type": "scenario_started",
		"target": scenario_id,
		"timestamp": 0.0,
		"player_position": {"x": 0, "y": 0, "z": 0},
		"details": {},
	})

	session_started.emit(scenario_id)


## Record an action event from a TelemetryEmitter.
func record_event(action_data: Dictionary) -> void:
	session_events.append(action_data)


## End the session and return the full data package.
func end_session() -> Dictionary:
	if not _session_active:
		return {}

	var duration_sec := (Time.get_ticks_msec() - _session_start_msec) / 1000.0

	# Log session end event
	record_event({
		"type": "scenario_ended",
		"target": _scenario_id,
		"timestamp": duration_sec,
		"player_position": {"x": 0, "y": 0, "z": 0},
		"details": {"duration_seconds": duration_sec},
	})

	_session_active = false

	var data := {
		"scenario_id": _scenario_id,
		"duration_seconds": duration_sec,
		"event_count": session_events.size(),
		"events": session_events.duplicate(true),
		"movement_data": movement_data.duplicate(true),
		"patient_proximity_times": patient_proximity_times.duplicate(true),
	}

	session_ended.emit(_scenario_id)
	return data


## Export session data to a JSON file.
func export_session_json(path: String) -> void:
	var data := end_session()
	var json_string := JSON.stringify(data, "\t")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(json_string)


## Check if a session is currently active.
func is_session_active() -> bool:
	return _session_active


## Get the scenario-relative timestamp (seconds since session start).
func get_session_time() -> float:
	if _session_start_msec == 0:
		return 0.0
	return (Time.get_ticks_msec() - _session_start_msec) / 1000.0


## Record a scenario time expired event (called by ScenarioManager).
func record_time_expired() -> void:
	record_event({
		"type": "scenario_time_expired",
		"target": _scenario_id,
		"timestamp": get_session_time(),
		"player_position": {"x": 0, "y": 0, "z": 0},
		"details": {},
	})


## Wire gameplay signals from player components for enriched telemetry.
## Call after entities are spawned (e.g., from ScenarioManager after load).
func wire_player_signals(player: Node) -> void:
	# Connect InventoryComponent.item_used → treatment correctness logging
	var inventory: Node = player.get_node_or_null("InventoryComponent")
	if inventory and inventory.has_signal("item_used"):
		inventory.item_used.connect(_on_item_used_on_patient)

	# Connect MedicalBagTierManager.equipment_deployed → treatment logging
	var bag_mgr: Node = player.get_node_or_null("MedicalBagTierManager")
	if bag_mgr and bag_mgr.has_signal("equipment_deployed"):
		if not bag_mgr.equipment_deployed.is_connected(_on_bag_equipment_deployed):
			bag_mgr.equipment_deployed.connect(_on_bag_equipment_deployed)

	# Connect DrugAdministrationManager.drug_administered → treatment logging
	var drug_mgr: Node = player.get_node_or_null("DrugAdministrationManager")
	if drug_mgr and drug_mgr.has_signal("drug_administered"):
		if not drug_mgr.drug_administered.is_connected(_on_drug_administered):
			drug_mgr.drug_administered.connect(_on_drug_administered)

	# Connect MedicalStateComponent.state_changed on all patients for state tracking
	_wire_patient_signals()


## Wire patient medical state signals for telemetry tracking.
func _wire_patient_signals() -> void:
	var patients := get_tree().get_nodes_in_group("patients")
	for patient in patients:
		var medical: Node = patient.get_node_or_null("MedicalStateComponent")
		if medical and medical.has_signal("state_changed"):
			if not medical.state_changed.is_connected(_on_patient_state_changed.bind(patient)):
				medical.state_changed.connect(_on_patient_state_changed.bind(patient))
		var deterioration: Node = patient.get_node_or_null("DeteriorationSystem")
		if deterioration and deterioration.has_signal("condition_worsened"):
			if not deterioration.condition_worsened.is_connected(_on_condition_worsened):
				deterioration.condition_worsened.connect(_on_condition_worsened)


## Handle medical bag equipment deployed on patient — log treatment_applied.
## Fired by MedicalBagTierManager.equipment_deployed(patient, equipment_key).
func _on_bag_equipment_deployed(patient: Node, equipment_key: String) -> void:
	if not _session_active:
		return

	# Determine treatment correctness from patient medical state
	var was_correct := false
	var medical: Node = patient.get_node_or_null("MedicalStateComponent")
	if medical and medical.has_method("apply_treatment"):
		var treatment_map := {
			"CPR": "cpr",
			"BANDAGE": "apply_bandage",
			"TOURNIQUET": "apply_bandage",
			"OXYGEN_MASK": "oxygen_mask",
			"BVM": "oxygen_mask",
			"AED": "aed",
			"IV_ACCESS": "iv_access",
			"CERVICAL_COLLAR": "c_collar",
			"SPLINT_SAM": "apply_bandage",
		}
		var treatment_type: String = treatment_map.get(equipment_key, "")
		if treatment_type != "":
			was_correct = medical.apply_treatment(treatment_type)
		else:
			was_correct = true  # Non-treatment equipment (thermometer, etc.) is always "correct"

	var display_name := equipment_key.replace("_", " ").capitalize()
	record_event({
		"type": "treatment_applied",
		"target": get_patient_display_name(patient),
		"timestamp": get_session_time(),
		"player_position": {"x": 0, "y": 0, "z": 0},
		"details": {
			"equipment_name": display_name,
			"equipment_key": equipment_key,
			"was_correct": was_correct,
		},
	})


## Handle drug administration — log as treatment_applied for AI reviewer.
## Fired by DrugAdministrationManager.drug_administered(patient, drug_key, dose, route, error).
func _on_drug_administered(patient: Node, drug_key: String, dose: String, route: String, error: int) -> void:
	if not _session_active:
		return
	var was_correct: bool = (error == 0)  # MedError.NONE = 0
	var display_name: String = "%s %s via %s" % [drug_key.replace("_", " ").capitalize(), dose, route]

	# Capture patient state at time of drug administration for AI reviewer context
	var patient_state := "UNKNOWN"
	var patient_rhythm := ""
	var medical: Node = patient.get_node_or_null("MedicalStateComponent") if is_instance_valid(patient) else null
	if medical:
		var state_names := ["CONSCIOUS", "UNCONSCIOUS", "CARDIAC_ARREST", "DEAD"]
		var idx: int = medical.current_state if "current_state" in medical else 0
		patient_state = state_names[idx] if idx < state_names.size() else "UNKNOWN"
		patient_rhythm = medical.ecg_rhythm if "ecg_rhythm" in medical else ""

	record_event({
		"type": "treatment_applied",
		"target": get_patient_display_name(patient),
		"timestamp": get_session_time(),
		"player_position": {"x": 0, "y": 0, "z": 0},
		"details": {
			"equipment_name": display_name,
			"equipment_key": "DRUG_%s" % drug_key,
			"drug_key": drug_key,
			"dose": dose,
			"route": route,
			"was_correct": was_correct,
			"is_drug": true,
			"patient_state": patient_state,
			"patient_rhythm": patient_rhythm,
		},
	})


## Handle equipment used on patient — log treatment_applied with correctness.
func _on_item_used_on_patient(equipment_data: Resource, target: Node) -> void:
	if not _session_active:
		return

	var was_correct := false
	var medical: Node = target.get_node_or_null("MedicalStateComponent")

	# Map equipment type to treatment type for apply_treatment
	if medical and medical.has_method("apply_treatment"):
		var treatment_map := {
			"AED": "aed",
			"BANDAGE": "apply_bandage",
			"SPLINT": "apply_bandage",
			"OXYGEN_MASK": "oxygen_mask",
			"STRETCHER": "",  # Stretcher is transport, not treatment
		}
		var equip_type_name: String = ""
		if equipment_data.has_method("get") or "equipment_type" in equipment_data:
			equip_type_name = equipment_data.EquipmentType.keys()[equipment_data.equipment_type]
		var treatment_type: String = treatment_map.get(equip_type_name, "")
		if treatment_type != "":
			was_correct = medical.apply_treatment(treatment_type)

	record_event({
		"type": "treatment_applied",
		"target": get_patient_display_name(target),
		"timestamp": get_session_time(),
		"player_position": {"x": 0, "y": 0, "z": 0},
		"details": {
			"equipment_name": equipment_data.equipment_name if "equipment_name" in equipment_data else "unknown",
			"was_correct": was_correct,
		},
	})


## Get the display name for a patient node (persona name or fallback to node name).
static func get_patient_display_name(patient: Node) -> String:
	if "persona" in patient and patient.persona and patient.persona.patient_name != "":
		return patient.persona.patient_name
	return patient.name


## Record a triage assignment event (called externally by triage UI system).
func record_triage_assignment(patient: Node, assigned_tag: String) -> void:
	var correct_tag := ""
	var medical: Node = patient.get_node_or_null("MedicalStateComponent")
	if medical and medical.has_method("get_triage_priority"):
		correct_tag = medical.get_triage_priority()

	record_event({
		"type": "triage_assign",
		"target": get_patient_display_name(patient),
		"timestamp": get_session_time(),
		"player_position": {"x": 0, "y": 0, "z": 0},
		"details": {
			"assigned_tag": assigned_tag,
			"correct_tag": correct_tag,
			"was_correct": assigned_tag == correct_tag,
		},
	})


## Log patient state changes for timeline tracking.
func _on_patient_state_changed(old_state: int, new_state: int, patient: Node) -> void:
	if not _session_active:
		return
	var medical: Node = patient.get_node_or_null("MedicalStateComponent")
	var state_names := ["CONSCIOUS", "UNCONSCIOUS", "CARDIAC_ARREST", "DEAD"]
	record_event({
		"type": "patient_state_changed",
		"target": get_patient_display_name(patient),
		"timestamp": get_session_time(),
		"player_position": {"x": 0, "y": 0, "z": 0},
		"details": {
			"old_state": state_names[old_state] if old_state < state_names.size() else str(old_state),
			"new_state": state_names[new_state] if new_state < state_names.size() else str(new_state),
		},
	})


## Log deterioration events.
func _on_condition_worsened(patient: Node, modifier: String, old_value: Variant, new_value: Variant) -> void:
	if not _session_active:
		return
	record_event({
		"type": "condition_worsened",
		"target": get_patient_display_name(patient),
		"timestamp": get_session_time(),
		"player_position": {"x": 0, "y": 0, "z": 0},
		"details": {
			"modifier": modifier,
			"old_value": str(old_value),
			"new_value": str(new_value),
		},
	})
