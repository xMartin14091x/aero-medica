## PositionTracker — Records player position at regular intervals.
## Attached to the Player entity. Generates heatmap data and patient proximity tracking.
## Data feeds into TelemetryCollector session export.
## MON-17: Optimised — cached patients, squared distance, periodic refresh.
extends Node

## How often to sample position (seconds).
@export var tracking_interval: float = 1.0

## Internal timer for position sampling.
var _sample_timer: float = 0.0

## Whether tracking is currently active.
var _tracking: bool = false

## Position samples — array of {position: {x,y,z}, timestamp: float}.
var _position_samples: Array[Dictionary] = []

## Time spent near each patient (within interaction radius).
## Key = patient node name, Value = accumulated seconds.
var _patient_proximity: Dictionary = {}

## Detection radius for patient proximity (matches InteractionArea default).
var _proximity_radius: float = 2.0

## Squared proximity radius — avoids per-frame sqrt.
var _proximity_radius_sq: float = 4.0

## Cached patient list — refreshed periodically, not every frame.
var _cached_patients: Array[Node] = []

## Timer for periodic patient list refresh.
var _patient_refresh_timer: float = 0.0

## How often to refresh the patient cache (seconds).
const PATIENT_REFRESH_INTERVAL: float = 2.0

## Cached references to avoid per-frame node lookups.
var _collector: Node = null
var _player: Node3D = null


func _ready() -> void:
	# Cache collector reference
	_collector = get_node_or_null("/root/TelemetryCollector")
	if _collector:
		_collector.session_started.connect(_on_session_started)
		_collector.session_ended.connect(_on_session_ended)

	# Read interaction radius from sibling InteractionArea if available
	var area := get_parent().get_node_or_null("InteractionArea")
	if area:
		for child in area.get_children():
			if child is CollisionShape3D and child.shape is SphereShape3D:
				_proximity_radius = child.shape.radius
				_proximity_radius_sq = _proximity_radius * _proximity_radius
				break


func _process(delta: float) -> void:
	if not _tracking:
		return

	_sample_timer += delta

	# Refresh patient cache periodically (not every frame)
	_patient_refresh_timer += delta
	if _patient_refresh_timer >= PATIENT_REFRESH_INTERVAL:
		_patient_refresh_timer = 0.0
		_refresh_patient_cache()

	# Track patient proximity continuously
	_update_patient_proximity(delta)

	# Sample position at interval
	if _sample_timer >= tracking_interval:
		_sample_timer = 0.0
		_record_position()


## Start tracking (triggered by TelemetryCollector session start).
func _on_session_started(_scenario_id: String) -> void:
	_tracking = true
	_sample_timer = 0.0
	_patient_refresh_timer = 0.0
	_position_samples.clear()
	_patient_proximity.clear()
	# Cache player reference
	_player = get_parent() as Node3D
	# Build initial patient cache
	_refresh_patient_cache()
	# Record initial position immediately
	_record_position()


## Stop tracking and push data to TelemetryCollector.
func _on_session_ended(_scenario_id: String) -> void:
	_tracking = false
	if _collector:
		_collector.movement_data = _position_samples.duplicate(true)
		_collector.patient_proximity_times = _patient_proximity.duplicate(true)


## Record current position with timestamp.
func _record_position() -> void:
	if not _player:
		return

	var pos: Vector3 = _player.global_position
	var timestamp: float = _collector.get_session_time() if _collector else 0.0

	_position_samples.append({
		"position": {"x": pos.x, "y": pos.y, "z": pos.z},
		"timestamp": timestamp,
	})


## Refresh the cached patient list from the scene tree.
func _refresh_patient_cache() -> void:
	_cached_patients.clear()
	var patients := get_tree().get_nodes_in_group("patients")

	# Fallback: find patients by MedicalStateComponent if not in group
	if patients.is_empty():
		var scene := get_tree().current_scene
		if scene:
			for node in scene.get_children():
				if node.get_node_or_null("MedicalStateComponent"):
					patients.append(node)

	for p in patients:
		if is_instance_valid(p) and p is Node3D:
			_cached_patients.append(p)


## Update proximity tracking — accumulate time spent near each patient.
## Uses squared distance to avoid per-frame sqrt.
func _update_patient_proximity(delta: float) -> void:
	if not _player:
		return

	var player_pos: Vector3 = _player.global_position

	for patient in _cached_patients:
		if not is_instance_valid(patient):
			continue
		var dist_sq: float = player_pos.distance_squared_to(patient.global_position)
		if dist_sq <= _proximity_radius_sq:
			var key: String = patient.name
			_patient_proximity[key] = _patient_proximity.get(key, 0.0) + delta


## Returns position samples for heatmap visualisation.
func get_heatmap_data() -> Array:
	return _position_samples.duplicate(true)


## Returns time spent near each patient.
func get_patient_proximity_times() -> Dictionary:
	return _patient_proximity.duplicate(true)
