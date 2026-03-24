## RandomEventSystem — Mid-scenario random events that force player adaptation.
## Manages timed triggers: new patient spawns, equipment failure, bystander arrival.
## Events defined in scenario JSON as random_events[] array.
## Created by ScenarioManager during scenario load.
## MON-17: Optimised — cached singleton references, disable process when no pending events.
extends Node

## Emitted when any random event triggers.
signal random_event_triggered(event_type: String, event_data: Dictionary)

## Event definitions loaded from scenario data.
var _event_defs: Array[Dictionary] = []

## Pending events that haven't fired yet.
var _pending_events: Array[Dictionary] = []

## Resolved trigger times for each pending event (randomised within range).
var _trigger_times: Array[float] = []

## Whether the system is active (running with scenario).
var _active: bool = false

## Reference to scene root for spawning.
var _scene_root: Node = null

## Cached singleton references (avoid per-frame get_node_or_null).
var _scenario_mgr: Node = null
var _collector: Node = null

## Preloaded resources.
const PatientScene := preload("res://scenes/entities/patients/PatientBase.tscn")


## Initialize the random event system with event definitions from scenario data.
## Called by ScenarioManager after entity spawn.
func setup(event_defs: Array, scene_root: Node) -> void:
	_scene_root = scene_root
	_event_defs.clear()
	_pending_events.clear()
	_trigger_times.clear()
	_active = false

	# Cache singleton references once
	_scenario_mgr = get_node_or_null("/root/ScenarioManager")
	_collector = get_node_or_null("/root/TelemetryCollector")

	for def: Dictionary in event_defs:
		var event: Dictionary = def.duplicate(true)
		_event_defs.append(event)
		_pending_events.append(event)

		# Resolve trigger time: random within [trigger_time_min, trigger_time_max]
		var t_min: float = def.get("trigger_time_min", 30.0)
		var t_max: float = def.get("trigger_time_max", t_min)
		var trigger_time: float = randf_range(t_min, t_max)
		_trigger_times.append(trigger_time)

	# Disable processing if no events to wait for
	if _pending_events.is_empty():
		set_process(false)


## Start processing events (call when scenario starts).
func start() -> void:
	_active = true
	if not _pending_events.is_empty():
		set_process(true)


## Stop processing events.
func stop() -> void:
	_active = false
	set_process(false)


func _process(_delta: float) -> void:
	if not _active or _pending_events.is_empty():
		set_process(false)
		return

	# Get scenario elapsed time from cached reference
	if not _scenario_mgr:
		return
	var elapsed: float = _scenario_mgr.get_elapsed_time()

	# Check each pending event (iterate backwards for safe removal)
	var i := _pending_events.size() - 1
	while i >= 0:
		if elapsed >= _trigger_times[i]:
			var event := _pending_events[i]
			_pending_events.remove_at(i)
			_trigger_times.remove_at(i)
			_fire_event(event)
		i -= 1

	# Disable process when all events have fired
	if _pending_events.is_empty():
		set_process(false)


## Execute a random event.
func _fire_event(event: Dictionary) -> void:
	var event_type: String = event.get("type", "")
	var event_data: Dictionary = event.get("data", {})

	match event_type:
		"NEW_PATIENT":
			_spawn_new_patient(event_data)
		"EQUIPMENT_FAILURE":
			_trigger_equipment_failure(event_data)
		"BYSTANDER":
			_spawn_bystander(event_data)
		_:
			push_warning("RandomEventSystem: Unknown event type '%s'" % event_type)
			return

	# Emit signal for UI/audio
	random_event_triggered.emit(event_type, event_data)

	# Log to telemetry
	if _collector and _collector.is_session_active():
		_collector.record_event({
			"type": "random_event",
			"target": event_type,
			"timestamp": _collector.get_session_time(),
			"player_position": {"x": 0, "y": 0, "z": 0},
			"details": event_data,
		})


## NEW_PATIENT — Spawn an additional patient mid-scenario.
func _spawn_new_patient(data: Dictionary) -> void:
	if not _scene_root:
		return

	var patient: Node = PatientScene.instantiate()
	_scene_root.add_child(patient)

	# Position
	var pos: Dictionary = data.get("position", {})
	patient.position = Vector3(
		pos.get("x", 0.0),
		pos.get("y", 0.0),
		pos.get("z", 0.0)
	)

	# Configure medical state
	var initial_state: String = data.get("initial_state", "CONSCIOUS")
	var medical: Node = patient.get_node_or_null("MedicalStateComponent")
	if medical:
		var state_map := {"CONSCIOUS": 0, "UNCONSCIOUS": 1, "CARDIAC_ARREST": 2, "DEAD": 3}
		medical.current_state = state_map.get(initial_state, 0)

		var modifiers: Dictionary = data.get("modifiers", {})
		if modifiers.has("bleeding_severity"):
			medical.bleeding_severity = modifiers["bleeding_severity"]
		if modifiers.has("airway_status"):
			medical.airway_status = modifiers["airway_status"]
		if modifiers.has("breathing_rate"):
			medical.breathing_rate = modifiers["breathing_rate"]
		if modifiers.has("pulse_present"):
			medical.pulse_present = modifiers["pulse_present"]

	# Configure persona
	var persona_data: Dictionary = data.get("persona", {})
	if not persona_data.is_empty() and "persona" in patient:
		var persona := PatientPersona.new()
		persona.patient_name = persona_data.get("name", "Unknown Patient")
		persona.age = persona_data.get("age", 30)
		persona.consciousness_level = persona_data.get("consciousness_level", "ALERT")
		persona.pain_level = persona_data.get("pain_level", 0)
		persona.panic_level = persona_data.get("panic_level", 0.0)
		persona.language_clarity = persona_data.get("language_clarity", 1.0)
		patient.persona = persona

	# Configure deterioration
	var deterioration: Node = patient.get_node_or_null("DeteriorationSystem")
	if deterioration:
		var det_data: Dictionary = data.get("deterioration", {})
		if det_data.has("rate"):
			deterioration.deterioration_rate = det_data["rate"]
		if det_data.has("enabled"):
			deterioration.deterioration_enabled = det_data["enabled"]

	# Add to patients group for telemetry tracking
	patient.add_to_group("patients")

	# Register with ScenarioManager for cleanup
	if _scenario_mgr:
		_scenario_mgr._spawned_entities.append(patient)

	# Wire telemetry for the new patient
	if _collector:
		_collector._wire_patient_signals()


## EQUIPMENT_FAILURE — Mark equipment as unusable.
func _trigger_equipment_failure(data: Dictionary) -> void:
	var target_type: String = data.get("equipment_type", "")
	var target_name: String = data.get("equipment_name", "")

	# Find matching equipment in the scene
	var equipment_nodes := get_tree().get_nodes_in_group("equipment")

	# Also search scene children for equipment entities
	if equipment_nodes.is_empty() and _scene_root:
		for child in _scene_root.get_children():
			if "data" in child and child.data is EquipmentData:
				equipment_nodes.append(child)

	for equip in equipment_nodes:
		if not is_instance_valid(equip):
			continue
		var matches := false
		if "data" in equip and equip.data:
			if target_name != "" and equip.data.equipment_name == target_name:
				matches = true
			elif target_type != "" and EquipmentData.EquipmentType.keys()[equip.data.equipment_type] == target_type:
				matches = true

		if matches:
			equip.set_meta("equipment_broken", true)
			var interactable: Node = equip.get_node_or_null("InteractableComponent")
			if interactable:
				interactable.set_meta("disabled", true)
				interactable.interaction_label = "[BROKEN] " + interactable.interaction_label
			break


## BYSTANDER — Spawn a non-patient NPC that can be interacted with.
func _spawn_bystander(data: Dictionary) -> void:
	if not _scene_root:
		return

	var bystander := CharacterBody3D.new()
	bystander.name = data.get("name", "Bystander")

	var pos: Dictionary = data.get("position", {})
	bystander.position = Vector3(
		pos.get("x", 0.0),
		pos.get("y", 0.0),
		pos.get("z", 0.0)
	)

	# Add collision shape
	var col := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.6
	col.shape = capsule
	col.position.y = 0.8
	bystander.add_child(col)

	# Add mesh (blue capsule to distinguish from patients)
	var mesh_inst := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.3
	mesh.height = 1.6
	mesh_inst.mesh = mesh
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.2, 0.4, 0.8)
	mesh_inst.material_override = mat
	mesh_inst.position.y = 0.8
	bystander.add_child(mesh_inst)

	# Add InteractableComponent for dialogue (F12-ready)
	var interactable_script := load("res://scripts/gameplay/interactable_component.gd")
	if interactable_script:
		var interactable := Node.new()
		interactable.set_script(interactable_script)
		interactable.name = "InteractableComponent"
		bystander.add_child(interactable)
		interactable.set("dialogue_capable", true)
		interactable.set("interaction_label", data.get("label", "Talk to Bystander"))

	_scene_root.add_child(bystander)

	if _scenario_mgr:
		_scenario_mgr._spawned_entities.append(bystander)
