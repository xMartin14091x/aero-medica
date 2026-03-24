## TelemetryEmitter — Attach as child to the player entity.
## Emits structured action events for the telemetry pipeline.
## Phase 3: includes player position and scenario-relative timestamps in every event.
extends Node

## Emitted on every tracked gameplay action.
signal action_performed(action_data: Dictionary)

## Emitted when a dialogue exchange occurs (F12 hook).
signal dialogue_event(question: String, response: String, duration: float)


func _ready() -> void:
	# Auto-connect to TelemetryCollector singleton if available
	var collector := get_node_or_null("/root/TelemetryCollector")
	if collector and collector.has_method("record_event"):
		action_performed.connect(collector.record_event)


## Helper to build and emit a structured action event.
## Includes player position and scenario-relative timestamp automatically.
func emit_action(action_type: String, target: String, details: Dictionary = {}) -> void:
	var player := get_parent()
	var player_pos := Vector3.ZERO
	if player and player is Node3D:
		player_pos = player.global_position

	# Use scenario-relative timestamp if a session is active
	var timestamp: float
	var collector := get_node_or_null("/root/TelemetryCollector")
	if collector and collector._session_start_msec > 0:
		timestamp = (Time.get_ticks_msec() - collector._session_start_msec) / 1000.0
	else:
		timestamp = Time.get_ticks_msec() / 1000.0

	var action_data := {
		"type": action_type,
		"target": target,
		"timestamp": timestamp,
		"player_position": {"x": player_pos.x, "y": player_pos.y, "z": player_pos.z},
		"details": details,
	}
	action_performed.emit(action_data)
