## PhysicsInteractable — Extends InteractableComponent for physics-based objects.
## Handles movable debris (RigidBody3D push/pull), openable doors (toggle state),
## and draggable stretchers (patient loading + transport).
## Physics interactions logged to telemetry.
extends Node

## Interaction types for physics objects.
enum PhysicsType { DEBRIS, DOOR, STRETCHER }

## The type of physics interaction this object supports.
@export var physics_type: PhysicsType = PhysicsType.DEBRIS

## Maximum weight the player can push/pull (kg). Objects heavier than this won't budge.
@export var mass_limit: float = 100.0

## Push/pull force applied to RigidBody3D objects.
@export var push_force: float = 5.0

## Whether this object is currently being interacted with (dragged/pushed).
var is_active: bool = false

## For doors: whether the door is currently open.
var is_open: bool = false

## For stretchers: the loaded patient node (null if empty).
var loaded_patient: Node3D = null

## Reference to the player currently interacting (null if none).
var _interacting_player: Node3D = null

## The parent entity this component is attached to.
@onready var _entity: Node3D = get_parent()

## InteractableComponent sibling for signal wiring.
@onready var _interactable: Node = _entity.get_node_or_null("InteractableComponent")


func _ready() -> void:
	if _interactable:
		_interactable.interacted.connect(_on_interacted)
		# Set appropriate label based on type
		match physics_type:
			PhysicsType.DEBRIS:
				if _interactable.interaction_label == "Interact":
					_interactable.interaction_label = "Push Debris"
			PhysicsType.DOOR:
				_update_door_label()
			PhysicsType.STRETCHER:
				_update_stretcher_label()


func _physics_process(delta: float) -> void:
	if not is_active or not _interacting_player:
		return

	match physics_type:
		PhysicsType.DEBRIS:
			_process_push_pull(delta)
		PhysicsType.STRETCHER:
			_process_drag(delta)


## Handle interaction from InteractableComponent signal.
func _on_interacted(interactor: Node) -> void:
	match physics_type:
		PhysicsType.DEBRIS:
			_toggle_push(interactor)
		PhysicsType.DOOR:
			_toggle_door()
		PhysicsType.STRETCHER:
			_handle_stretcher_interact(interactor)

	_log_telemetry(interactor)


## DEBRIS — Toggle push/pull mode.
func _toggle_push(interactor: Node) -> void:
	if is_active:
		# Release
		is_active = false
		_interacting_player = null
		if _interactable:
			_interactable.interaction_label = "Push Debris"
	else:
		# Check weight limit
		if _entity is RigidBody3D and _entity.mass > mass_limit:
			return  # Too heavy
		is_active = true
		_interacting_player = interactor


## Process push/pull physics each frame while active.
func _process_push_pull(_delta: float) -> void:
	if not (_entity is RigidBody3D) or not _interacting_player:
		return

	# Direction from player to debris
	var dir: Vector3 = (_entity.global_position - _interacting_player.global_position).normalized()
	dir.y = 0.0  # Keep horizontal only

	# Apply force in the player's facing direction
	var player_forward := -_interacting_player.global_transform.basis.z.normalized()
	player_forward.y = 0.0

	_entity.apply_central_force(player_forward * push_force)


## DOOR — Toggle open/close.
func _toggle_door() -> void:
	is_open = not is_open

	# Animate the door via AnimationPlayer if present, otherwise rotate
	var anim_player: Node = _entity.get_node_or_null("AnimationPlayer")
	if anim_player:
		if is_open:
			if anim_player.has_animation("open"):
				anim_player.play("open")
		else:
			if anim_player.has_animation("close"):
				anim_player.play("close")
	elif _entity is Node3D:
		# Simple rotation fallback (90 degrees)
		var target_y: float = -PI / 2.0 if is_open else 0.0
		var tween := _entity.create_tween()
		tween.tween_property(_entity, "rotation:y", target_y, 0.5)

	_update_door_label()

	# Trigger NavMesh rebake if navigation region exists
	_request_navmesh_rebake()


## STRETCHER — Handle pickup, patient loading, or release.
func _handle_stretcher_interact(interactor: Node) -> void:
	if is_active:
		# Already dragging — release
		is_active = false
		_interacting_player = null
		_update_stretcher_label()
		return

	# Check if there's a patient nearby to load
	if loaded_patient == null:
		var nearby_patient := _find_nearby_patient()
		if nearby_patient:
			_load_patient(nearby_patient)
			_update_stretcher_label()
			_log_patient_loaded(interactor, nearby_patient)
			return

	# Start dragging
	is_active = true
	_interacting_player = interactor
	_update_stretcher_label()


## Process stretcher drag — follow player at offset.
func _process_drag(_delta: float) -> void:
	if not _interacting_player or not (_entity is Node3D):
		return

	# Follow behind the player
	var player_back := _interacting_player.global_transform.basis.z.normalized()
	var target_pos := _interacting_player.global_position + player_back * 1.5
	target_pos.y = _entity.global_position.y  # Keep same height

	# Smooth follow
	_entity.global_position = _entity.global_position.lerp(target_pos, 0.1)

	# Face the player
	var look_dir := (_interacting_player.global_position - _entity.global_position)
	look_dir.y = 0.0
	if look_dir.length_squared() > 0.01:
		_entity.look_at(_entity.global_position + look_dir, Vector3.UP)


## Load a patient onto the stretcher.
func _load_patient(patient: Node3D) -> void:
	loaded_patient = patient

	# Reparent patient to stretcher
	var global_pos := patient.global_position
	if patient.get_parent():
		patient.get_parent().remove_child(patient)
	_entity.add_child(patient)
	patient.position = Vector3(0.0, 0.3, 0.0)  # Slightly above stretcher surface

	# Disable patient interaction while loaded
	var interactable: Node = patient.get_node_or_null("InteractableComponent")
	if interactable:
		interactable.set_meta("disabled_by_stretcher", true)


## Unload patient from stretcher at current position.
func unload_patient() -> Node3D:
	if not loaded_patient:
		return null

	var patient := loaded_patient
	loaded_patient = null

	# Reparent back to scene
	var scene_root: Node = _entity.get_tree().current_scene
	var global_pos := patient.global_position
	_entity.remove_child(patient)
	scene_root.add_child(patient)
	patient.global_position = global_pos
	patient.global_position.y = 0.0  # Ground level

	# Re-enable patient interaction
	var interactable: Node = patient.get_node_or_null("InteractableComponent")
	if interactable:
		interactable.remove_meta("disabled_by_stretcher")

	_update_stretcher_label()
	return patient


## Find a patient within loading distance of the stretcher.
func _find_nearby_patient() -> Node3D:
	var patients := _entity.get_tree().get_nodes_in_group("patients")
	var stretcher_pos := _entity.global_position
	var load_distance := 2.0

	for patient in patients:
		if not is_instance_valid(patient) or not patient is Node3D:
			continue
		if stretcher_pos.distance_to(patient.global_position) <= load_distance:
			return patient

	return null


## Update the stretcher's interaction label based on state.
func _update_stretcher_label() -> void:
	if not _interactable:
		return
	if is_active:
		_interactable.interaction_label = "Release Stretcher"
	elif loaded_patient:
		_interactable.interaction_label = "Drag Stretcher (Patient Loaded)"
	elif _find_nearby_patient():
		_interactable.interaction_label = "Load Patient onto Stretcher"
	else:
		_interactable.interaction_label = "Drag Stretcher"


## Update the door's interaction label based on state.
func _update_door_label() -> void:
	if _interactable:
		_interactable.interaction_label = "Close Door" if is_open else "Open Door"


## Request a NavMesh rebake after moving debris or toggling a door.
func _request_navmesh_rebake() -> void:
	var nav_region: Node = _entity.get_tree().current_scene.find_child("NavigationRegion3D", true, false)
	if nav_region and nav_region is NavigationRegion3D:
		nav_region.bake_navigation_mesh()


## Log the physics interaction to telemetry.
func _log_telemetry(interactor: Node) -> void:
	var collector: Node = get_node_or_null("/root/TelemetryCollector")
	if not collector or not collector.is_session_active():
		return

	var type_name: String = PhysicsType.keys()[physics_type]
	var action: String = ""
	match physics_type:
		PhysicsType.DEBRIS:
			action = "release" if not is_active else "push"
		PhysicsType.DOOR:
			action = "open" if is_open else "close"
		PhysicsType.STRETCHER:
			if loaded_patient:
				action = "load_patient"
			elif is_active:
				action = "drag"
			else:
				action = "release"

	collector.record_event({
		"type": "physics_interact",
		"target": _entity.name,
		"timestamp": collector.get_session_time(),
		"player_position": _get_player_position(interactor),
		"details": {
			"object_type": type_name,
			"action": action,
			"has_patient": loaded_patient != null,
		},
	})


## Log patient loaded onto stretcher.
func _log_patient_loaded(interactor: Node, patient: Node3D) -> void:
	var collector: Node = get_node_or_null("/root/TelemetryCollector")
	if not collector or not collector.is_session_active():
		return

	collector.record_event({
		"type": "physics_interact",
		"target": _entity.name,
		"timestamp": collector.get_session_time(),
		"player_position": _get_player_position(interactor),
		"details": {
			"object_type": "STRETCHER",
			"action": "load_patient",
			"patient_name": patient.name,
		},
	})


## Get player position dictionary for telemetry.
func _get_player_position(interactor: Node) -> Dictionary:
	if interactor is Node3D:
		var pos := interactor.global_position
		return {"x": pos.x, "y": pos.y, "z": pos.z}
	return {"x": 0, "y": 0, "z": 0}
