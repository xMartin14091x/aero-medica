## HazardSystem — Manages all environmental hazards in a scenario.
## Spawns hazard zones from scenario data, tracks active hazards, emits signals for UI/audio.
## Created by ScenarioManager during scenario load.
extends Node

## Emitted when a hazard zone activates (initial or delayed).
signal hazard_activated(hazard_zone: Node)

## Emitted when a hazard zone expands (fire spread).
signal hazard_expanded(hazard_zone: Node)

## Emitted when any entity enters a hazard zone.
signal entity_in_hazard(entity: Node3D, hazard_type: String)

## Emitted when any entity exits a hazard zone.
signal entity_left_hazard(entity: Node3D, hazard_type: String)

## Emitted when the player is incapacitated by hazard exposure.
signal player_incapacitated_signal

## All active hazard zones managed by this system.
var _hazard_zones: Array[Node] = []

## Hazard type name lookup for signals.
const HAZARD_TYPE_NAMES := {
	0: "FIRE",
	1: "COLLAPSE",
	2: "TRAFFIC",
}

## Reference to the HazardZone script for type checking.
const HazardZoneScript := preload("res://scripts/gameplay/hazard_zone.gd")

## Cached TelemetryCollector reference (MON-17: avoid per-event lookup).
var _collector: Node = null

## Number of hazard zones the player is currently inside.
var _player_in_hazard_count: int = 0

## Total seconds the player has spent inside any hazard zone (for telemetry/AI review).
var player_total_hazard_time: float = 0.0


## Spawn all hazards defined in scenario data.
## Called by ScenarioManager after scene is loaded.
func spawn_hazards(hazard_defs: Array, scene_root: Node) -> void:
	_collector = get_node_or_null("/root/TelemetryCollector")
	for hazard_def: Dictionary in hazard_defs:
		var zone := _create_hazard_zone(hazard_def)
		if zone:
			scene_root.add_child(zone)
			_hazard_zones.append(zone)

			# Wire signals
			zone.entity_entered.connect(_on_entity_entered_hazard)
			zone.entity_exited.connect(_on_entity_exited_hazard)
			zone.hazard_expanded.connect(_on_hazard_expanded.bind(zone))
			if zone.has_signal("player_incapacitated"):
				zone.player_incapacitated.connect(_on_player_incapacitated)

			if zone.is_active:
				hazard_activated.emit(zone)


## Create a single hazard zone from a definition dictionary.
func _create_hazard_zone(def: Dictionary) -> Node:
	var zone := Area3D.new()
	zone.set_script(HazardZoneScript)

	# Set position
	var pos: Dictionary = def.get("position", {})
	zone.position = Vector3(
		pos.get("x", 0.0),
		pos.get("y", 0.0),
		pos.get("z", 0.0)
	)

	# Map type string to enum
	var type_str: String = def.get("type", "FIRE")
	var type_map := {"FIRE": 0, "COLLAPSE": 1, "TRAFFIC": 2}
	zone.hazard_type = type_map.get(type_str, 0)

	# Configure properties
	zone.radius = def.get("radius", 3.0)
	zone.spread_rate = def.get("spread_rate", 0.0)
	zone.max_radius = def.get("max_radius", 15.0)
	zone.damage_per_second = def.get("damage_per_second", 10.0)
	zone.is_active = def.get("initial_active", true)

	# Traffic-specific
	zone.traffic_interval = def.get("traffic_interval", 10.0)
	zone.traffic_danger_duration = def.get("traffic_danger_duration", 3.0)

	zone.name = "Hazard_%s_%d" % [type_str, _hazard_zones.size()]
	return zone


## Get all currently active hazard zones.
func get_active_hazards() -> Array[Node]:
	var active: Array[Node] = []
	for zone in _hazard_zones:
		if is_instance_valid(zone) and zone.is_active:
			active.append(zone)
	return active


## Check if a world position is inside any active hazard zone.
## Returns the hazard type string or empty string if safe.
func get_hazard_at_position(world_pos: Vector3) -> String:
	for zone in _hazard_zones:
		if is_instance_valid(zone) and zone.is_active:
			if zone.is_position_inside(world_pos):
				return HAZARD_TYPE_NAMES.get(zone.hazard_type, "UNKNOWN")
	return ""


## Activate a specific hazard by index (for delayed hazards).
func activate_hazard(index: int) -> void:
	if index >= 0 and index < _hazard_zones.size():
		var zone := _hazard_zones[index]
		if is_instance_valid(zone):
			zone.activate()
			hazard_activated.emit(zone)


## Deactivate a specific hazard by index.
func deactivate_hazard(index: int) -> void:
	if index >= 0 and index < _hazard_zones.size():
		var zone := _hazard_zones[index]
		if is_instance_valid(zone):
			zone.deactivate()


## Clean up all hazard zones.
func cleanup() -> void:
	for zone in _hazard_zones:
		if is_instance_valid(zone):
			zone.queue_free()
	_hazard_zones.clear()


## Accumulate player hazard exposure time each frame.
func _process(delta: float) -> void:
	if _player_in_hazard_count > 0:
		player_total_hazard_time += delta


## Handle player incapacitation from any hazard zone.
func _on_player_incapacitated() -> void:
	player_incapacitated_signal.emit()
	var scenario_mgr: Node = get_node_or_null("/root/ScenarioManager")
	if scenario_mgr and scenario_mgr.has_method("end_scenario"):
		scenario_mgr.end_scenario()


func _on_entity_entered_hazard(entity: Node3D, hazard: Area3D) -> void:
	var type_name: String = HAZARD_TYPE_NAMES.get(hazard.hazard_type, "UNKNOWN")
	entity_in_hazard.emit(entity, type_name)

	# Track player presence across all hazard zones
	if entity.is_in_group("player"):
		_player_in_hazard_count += 1

	# Log to telemetry (uses cached reference)
	if _collector and _collector.is_session_active():
		_collector.record_event({
			"type": "entity_in_hazard",
			"target": entity.name,
			"timestamp": _collector.get_session_time(),
			"player_position": {"x": 0, "y": 0, "z": 0},
			"details": {"hazard_type": type_name},
		})


func _on_entity_exited_hazard(entity: Node3D, hazard: Area3D) -> void:
	var type_name: String = HAZARD_TYPE_NAMES.get(hazard.hazard_type, "UNKNOWN")
	entity_left_hazard.emit(entity, type_name)

	# Track player leaving hazard zones
	if entity.is_in_group("player"):
		_player_in_hazard_count = maxi(0, _player_in_hazard_count - 1)


func _on_hazard_expanded(_new_radius: float, zone: Node) -> void:
	hazard_expanded.emit(zone)
