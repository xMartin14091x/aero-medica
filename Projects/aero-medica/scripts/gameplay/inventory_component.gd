## InventoryComponent — Single-item equipment inventory for the player.
## Handles pickup, carry, use-on-patient, and drop (Q key).
extends Node

## Emitted when equipment is picked up from the ground.
signal item_picked_up(equipment_data: EquipmentData)

## Emitted when held equipment is used on a target (patient).
signal item_used(equipment_data: EquipmentData, target: Node)

## Emitted when held equipment is dropped.
signal item_dropped(equipment_data: EquipmentData)

## Currently held equipment resource (null if hands are empty).
var held_item: EquipmentData = null

## The scene node of the held equipment (reparented to HeldItemMount).
var _held_node: Node3D = null

## Mount point on the player where held items attach visually.
@onready var _mount: Node3D = get_parent().get_node("HeldItemMount")

## Reference to TelemetryEmitter for logging.
@onready var _telemetry: Node = _find_sibling("TelemetryEmitter")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("drop") and held_item:
		drop_item()


## Attempt to pick up an equipment entity from the scene.
## Called when player interacts with an equipment node (has EquipmentData).
func try_pickup(equipment_node: Node3D) -> bool:
	if held_item:
		return false  # Already holding something

	var data := _get_equipment_data(equipment_node)
	if not data:
		return false

	held_item = data
	_held_node = equipment_node

	# Reparent to mount point for visual follow
	equipment_node.get_parent().remove_child(equipment_node)
	_mount.add_child(equipment_node)
	equipment_node.position = Vector3.ZERO
	equipment_node.rotation = Vector3.ZERO

	# Disable collision to prevent physics conflicts with player CharacterBody3D
	if equipment_node is StaticBody3D:
		equipment_node.collision_layer = 0
		equipment_node.collision_mask = 0
	for child in equipment_node.get_children():
		if child is CollisionShape3D:
			child.disabled = true

	item_picked_up.emit(held_item)

	if _telemetry and _telemetry.has_method("emit_action"):
		_telemetry.emit_action("equipment_pickup", held_item.equipment_name, {
			"type": EquipmentData.EquipmentType.keys()[held_item.equipment_type],
		})

	return true


## Use the held equipment on a target (typically a patient).
func use_on_target(target: Node) -> bool:
	if not held_item:
		return false

	var data := held_item
	item_used.emit(data, target)

	if _telemetry and _telemetry.has_method("emit_action"):
		_telemetry.emit_action("equipment_use", data.equipment_name, {
			"type": EquipmentData.EquipmentType.keys()[data.equipment_type],
			"target": target.name,
		})

	# Equipment is consumed on use — remove from inventory
	_clear_held_item()
	return true


## Drop the held item at the player's current position.
func drop_item() -> void:
	if not held_item:
		return

	var data := held_item
	var player: Node = get_parent()
	var drop_pos: Vector3 = player.global_position + Vector3(0.5, 0.0, 0.5)

	if _held_node and is_instance_valid(_held_node):
		# Restore collision before reparenting back to level
		if _held_node is StaticBody3D:
			_held_node.collision_layer = 1
			_held_node.collision_mask = 1
		for child in _held_node.get_children():
			if child is CollisionShape3D:
				child.disabled = false

		# Reparent back to the level
		_mount.remove_child(_held_node)
		var level: Node = player.get_parent()
		level.add_child(_held_node)
		_held_node.global_position = drop_pos

	item_dropped.emit(data)

	if _telemetry and _telemetry.has_method("emit_action"):
		_telemetry.emit_action("equipment_drop", data.equipment_name, {
			"type": EquipmentData.EquipmentType.keys()[data.equipment_type],
		})

	_clear_held_item()


## Clear internal held item state.
func _clear_held_item() -> void:
	held_item = null
	_held_node = null


## Check if the player is currently holding equipment.
func is_holding() -> bool:
	return held_item != null


## Extract EquipmentData resource from an equipment entity node.
func _get_equipment_data(entity: Node) -> EquipmentData:
	# Check for exported EquipmentData property
	if entity.has_method("get_equipment_data"):
		return entity.get_equipment_data()
	# Check for direct property
	if "equipment_data" in entity:
		return entity.equipment_data
	# Check children for a node holding the resource
	for child in entity.get_children():
		if "equipment_data" in child:
			return child.equipment_data
	return null


## Find a sibling node by name.
func _find_sibling(node_name: String) -> Node:
	var parent: Node = get_parent()
	if parent:
		return parent.get_node_or_null(node_name)
	return null
