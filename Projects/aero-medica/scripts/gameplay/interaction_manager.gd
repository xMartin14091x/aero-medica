## InteractionManager — Detects nearby interactables and handles E-key interaction.
## Attached to Player. Uses the InteractionArea (Area3D) to find InteractableComponent nodes.
extends Node

## Emitted when the nearest interaction target changes (for UI prompt updates).
signal interaction_target_changed(old_target: Node, new_target: Node)

## The currently tracked nearest interactable entity (parent of InteractableComponent).
var current_target: Node = null

## Reference to the player's TelemetryEmitter for logging interactions.
@onready var _telemetry: Node = _find_sibling("TelemetryEmitter")

## Reference to InventoryComponent for equipment routing.
@onready var _inventory: Node = _find_sibling("InventoryComponent")

## Reference to AssessmentManager for patient assessment routing.
@onready var _assessment: Node = _find_sibling("AssessmentManager")

## Reference to HistoryTakingManager for patient history dialogue routing.
@onready var _history: Node = _find_sibling("HistoryTakingManager")

## Reference to the InteractionArea on the player.
@onready var _area: Area3D = get_parent().get_node("InteractionArea")

## All InteractableComponent nodes currently inside the detection area.
var _interactables_in_range: Array[Node] = []


func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)
	_area.area_entered.connect(_on_area_entered)
	_area.area_exited.connect(_on_area_exited)


func _process(_delta: float) -> void:
	_update_nearest_target()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_target:
		# Block interaction after scenario ends
		var sm: Node = get_node_or_null("/root/ScenarioManager")
		if sm and "_scenario_running" in sm and not sm._scenario_running:
			return
		_interact_with_target()


## Interact with the current target — route to appropriate subsystem.
## Patient → open PatientInteractionUI (tabbed panel with Talk/Exam/Stabilize/Differential).
## Equipment on ground → pickup (legacy, kept for backwards compatibility).
func _interact_with_target() -> void:
	var target := current_target
	var interactable := _get_interactable(target)
	if not interactable or not interactable.can_interact():
		return

	var player: Node = get_parent()
	var is_patient := _is_patient_entity(target)

	# Primary route: patient → open the tabbed Patient Interaction UI
	if is_patient:
		interactable.interacted.emit(player)
		_open_patient_interaction_ui(target)
		_log_interact(interactable, target)
		return

	# Legacy: equipment on ground → pickup (for any remaining ground equipment)
	var is_equipment := _is_equipment_entity(target)
	var holding: bool = _inventory and _inventory.is_holding()
	if is_equipment and not holding and _inventory:
		interactable.interacted.emit(player)
		_inventory.try_pickup(target)
		_log_interact(interactable, target)
		return

	# Fallback: generic interaction
	interactable.interacted.emit(player)
	_log_interact(interactable, target)


## Open the PatientInteractionUI for the given patient.
## Searches the HUD CanvasLayer for the PatientInteractionUI node.
func _open_patient_interaction_ui(patient: Node) -> void:
	var hud := _find_hud()
	if not hud:
		# Fallback to old assessment mode if UI not found
		if _assessment:
			_assessment.begin_assessment(patient)
		return

	var interaction_ui: Control = hud.get_node_or_null("PatientInteractionUI")
	if interaction_ui and interaction_ui.has_method("open_ui"):
		interaction_ui.open_ui(patient, get_parent())
	else:
		# Fallback to old assessment mode
		if _assessment:
			_assessment.begin_assessment(patient)


## Find the HUD CanvasLayer in the scene tree.
func _find_hud() -> Node:
	var root := get_tree().current_scene
	if not root:
		return null
	var hud: Node = root.get_node_or_null("HUD")
	if hud:
		return hud
	# Search deeper
	for child in root.get_children():
		if child.name == "HUD" or child is CanvasLayer:
			var ui: Control = child.get_node_or_null("PatientInteractionUI")
			if ui:
				return child
	return null


## Log the interaction to telemetry.
func _log_interact(interactable: Node, target: Node = null) -> void:
	if not target:
		target = current_target
	if _telemetry and _telemetry.has_method("emit_action") and target:
		_telemetry.emit_action("interact", target.name, {
			"label": interactable.interaction_label,
		})


## Recalculate the nearest interactable from all in-range candidates.
func _update_nearest_target() -> void:
	# Clean up freed references
	_interactables_in_range = _interactables_in_range.filter(func(n): return is_instance_valid(n))

	var player_pos: Vector3 = get_parent().global_position
	var nearest: Node = null
	var nearest_dist := INF

	for entity in _interactables_in_range:
		var interactable := _get_interactable(entity)
		if not interactable or not interactable.can_interact():
			continue
		var dist: float = player_pos.distance_to(entity.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = entity

	if nearest != current_target:
		var old := current_target
		current_target = nearest
		interaction_target_changed.emit(old, current_target)


## When a body enters the interaction area, check if it has an InteractableComponent.
func _on_body_entered(body: Node3D) -> void:
	if _get_interactable(body) and body != get_parent():
		if body not in _interactables_in_range:
			_interactables_in_range.append(body)


func _on_body_exited(body: Node3D) -> void:
	_interactables_in_range.erase(body)
	if current_target == body:
		current_target = null


## Also detect Area3D-based entities (some interactables may use Area3D instead of body).
func _on_area_entered(area: Area3D) -> void:
	var entity: Node = area.get_parent()
	if entity and _get_interactable(entity) and entity != get_parent():
		if entity not in _interactables_in_range:
			_interactables_in_range.append(entity)


func _on_area_exited(area: Area3D) -> void:
	var entity: Node = area.get_parent()
	_interactables_in_range.erase(entity)
	if current_target == entity:
		current_target = null


## Find an InteractableComponent child on the given entity node.
func _get_interactable(entity: Node) -> Node:
	for child in entity.get_children():
		if child.has_signal("interacted") and child.has_method("can_interact"):
			return child
	return null


## Check if the entity is an equipment node (has EquipmentData or equipment_data property).
func _is_equipment_entity(entity: Node) -> bool:
	if "equipment_data" in entity and entity.equipment_data is EquipmentData:
		return true
	for child in entity.get_children():
		if "equipment_data" in child and child.equipment_data is EquipmentData:
			return true
	return false


## Check if the entity is a patient node (has MedicalStateComponent or is in "patients" group).
func _is_patient_entity(entity: Node) -> bool:
	if entity.is_in_group("patients"):
		return true
	for child in entity.get_children():
		if child.name == "MedicalStateComponent":
			return true
	return false


## Find a sibling node by name.
func _find_sibling(node_name: String) -> Node:
	var parent: Node = get_parent()
	if parent:
		return parent.get_node_or_null(node_name)
	return null
