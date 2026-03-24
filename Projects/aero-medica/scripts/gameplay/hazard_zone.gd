## HazardZone — Individual hazard area (Area3D) that damages or blocks entities.
## Supports FIRE (spreading damage), COLLAPSE (impassable), and TRAFFIC (periodic danger).
## Spawned and managed by HazardSystem.
## MON-17: Optimised — cached medical refs, disabled process for COLLAPSE, squared distance.
extends Area3D

## Hazard type determines behaviour: damage, block, or periodic danger.
enum HazardType { FIRE, COLLAPSE, TRAFFIC }

## Emitted when an entity enters this hazard zone.
signal entity_entered(entity: Node3D, hazard: Area3D)

## Emitted when an entity exits this hazard zone.
signal entity_exited(entity: Node3D, hazard: Area3D)

## Emitted when the hazard radius expands (fire spread).
signal hazard_expanded(new_radius: float)

## Emitted when the player has been inside this hazard too long (incapacitated).
signal player_incapacitated

## Type of this hazard zone.
@export var hazard_type: HazardType = HazardType.FIRE

## Current radius of the hazard zone.
@export var radius: float = 3.0

## How fast the radius grows per second (FIRE only). 0 = static.
@export var spread_rate: float = 0.0

## Maximum radius this hazard can grow to.
@export var max_radius: float = 15.0

## Damage dealt per second to entities inside (FIRE/TRAFFIC active window).
@export var damage_per_second: float = 10.0

## Whether this hazard is currently active.
@export var is_active: bool = true

## TRAFFIC: seconds between danger windows.
@export var traffic_interval: float = 10.0

## TRAFFIC: how long each danger window lasts (seconds).
@export var traffic_danger_duration: float = 3.0

## Collision shape reference — created at runtime.
var _collision_shape: CollisionShape3D = null

## Entities currently inside this zone with cached medical component references.
## Format: {entity: Node3D, medical: Node (or null), damage_acc: float}
var _entities_inside: Array[Dictionary] = []

## TRAFFIC: internal timer for danger window cycling.
var _traffic_timer: float = 0.0

## TRAFFIC: whether the danger window is currently open.
var _traffic_danger_active: bool = false

## Squared radius for distance checks (avoids sqrt).
var _radius_sq: float = 9.0

## Accumulated time the player has spent inside this hazard zone.
var _player_hazard_time: float = 0.0

## Threshold (seconds) before the player becomes incapacitated.
const PLAYER_INCAPACITATE_THRESHOLD: float = 15.0


func _ready() -> void:
	# Create collision shape programmatically
	_collision_shape = CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = radius
	_collision_shape.shape = sphere
	add_child(_collision_shape)

	# Monitor bodies entering/exiting
	monitoring = true
	monitorable = false

	# Set collision layer/mask — hazards detect on layer 5, monitor players (1) and patients (2)
	collision_layer = 0
	collision_mask = 3  # Monitor layers 1 + 2

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_radius_sq = radius * radius

	# COLLAPSE hazards have no per-frame logic — disable _process entirely
	if hazard_type == HazardType.COLLAPSE:
		set_process(false)


func _process(delta: float) -> void:
	if not is_active:
		return

	match hazard_type:
		HazardType.FIRE:
			_process_fire(delta)
		HazardType.TRAFFIC:
			_process_traffic(delta)


## FIRE: spread radius over time and damage entities inside.
func _process_fire(delta: float) -> void:
	# Spread
	if spread_rate > 0.0 and radius < max_radius:
		var old_radius := radius
		radius = minf(radius + spread_rate * delta, max_radius)
		if radius != old_radius:
			_radius_sq = radius * radius
			_update_collision_radius()
			hazard_expanded.emit(radius)

	# Damage entities inside
	_apply_damage(delta)


## TRAFFIC: cycle between safe and danger windows.
func _process_traffic(delta: float) -> void:
	_traffic_timer += delta

	if _traffic_danger_active:
		_apply_damage(delta)
		if _traffic_timer >= traffic_danger_duration:
			_traffic_timer = 0.0
			_traffic_danger_active = false
	else:
		if _traffic_timer >= traffic_interval:
			_traffic_timer = 0.0
			_traffic_danger_active = true


## Apply damage to all entities currently inside the zone.
## Uses cached medical component references to avoid per-frame get_node_or_null.
## When the player is co-located, patients take 25% more damage (scene safety penalty).
func _apply_damage(delta: float) -> void:
	# Check if player is present in this zone for damage multiplier + incapacitation
	var player_present := false
	for entry in _entities_inside:
		var entity: Node3D = entry["entity"]
		if is_instance_valid(entity) and entity.is_in_group("player"):
			player_present = true
			_player_hazard_time += delta
			if _player_hazard_time >= PLAYER_INCAPACITATE_THRESHOLD:
				player_incapacitated.emit()
				_player_hazard_time = 0.0  # Prevent repeat emission
			break

	var damage_mult: float = 1.25 if player_present else 1.0

	for entry in _entities_inside:
		var entity: Node3D = entry["entity"]
		if not is_instance_valid(entity):
			continue
		var medical: Node = entry["medical"]
		if medical == null:
			continue
		# Accumulate damage and apply when threshold reached
		entry["damage_acc"] += damage_per_second * delta * damage_mult
		if entry["damage_acc"] >= 10.0:
			entry["damage_acc"] -= 10.0
			if medical.bleeding_severity < 3:
				medical.set_modifier("bleeding_severity", medical.bleeding_severity + 1)


## Update the collision sphere radius when fire spreads.
func _update_collision_radius() -> void:
	if _collision_shape and _collision_shape.shape is SphereShape3D:
		_collision_shape.shape.radius = radius


## Activate this hazard zone.
func activate() -> void:
	is_active = true
	if hazard_type != HazardType.COLLAPSE:
		set_process(true)


## Deactivate this hazard zone.
func deactivate() -> void:
	is_active = false
	_traffic_danger_active = false
	_traffic_timer = 0.0


## Check if a world position is inside this hazard zone (uses squared distance).
func is_position_inside(world_pos: Vector3) -> bool:
	return global_position.distance_squared_to(world_pos) <= _radius_sq


## Whether the TRAFFIC hazard is currently in its danger window.
func is_traffic_danger_active() -> bool:
	return hazard_type == HazardType.TRAFFIC and _traffic_danger_active


func _on_body_entered(body: Node3D) -> void:
	# Check if entity is already tracked
	for entry in _entities_inside:
		if entry["entity"] == body:
			return
	# Cache the medical component reference on entry (avoids per-frame lookup)
	var medical: Node = body.get_node_or_null("MedicalStateComponent")
	_entities_inside.append({
		"entity": body,
		"medical": medical,
		"damage_acc": 0.0,
	})
	entity_entered.emit(body, self)


func _on_body_exited(body: Node3D) -> void:
	for i in range(_entities_inside.size()):
		if _entities_inside[i]["entity"] == body:
			_entities_inside.remove_at(i)
			break
	# Reset player hazard accumulator when they leave
	if body.is_in_group("player"):
		_player_hazard_time = 0.0
	entity_exited.emit(body, self)
