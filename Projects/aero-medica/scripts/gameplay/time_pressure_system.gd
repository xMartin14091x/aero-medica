## TimePressureSystem — Scenario countdown timer with escalating pressure.
## Drives urgency via time warnings and deterioration rate multiplier.
## Pauses when GameManager state is PAUSED.
extends Node

## Emitted every second with the remaining time.
signal time_updated(remaining_seconds: float)

## Emitted at 75%, 50%, 25% thresholds.
signal time_warning(remaining_seconds: float)

## Emitted when time runs out — scenario auto-ends.
signal time_expired()

## Total time limit loaded from scenario data.
@export var time_limit_seconds: float = 300.0

## Time scale applied when the player is NOT interacting (mouse captured / walking around).
## When interacting (mouse visible / UI open), time runs at 1.0x.
@export var idle_time_scale: float = 0.3

## Deterioration rate multiplier schedule.
## Format: {threshold_percent: multiplier}
## Applied to all DeteriorationSystem nodes in the scene.
@export var deterioration_schedule: Dictionary = {
	100: 1.0,
	50: 1.5,
	25: 2.0,
}

## Whether the timer is currently running.
var _running: bool = false

## Elapsed time since timer started.
var _elapsed: float = 0.0

## Tracks which warning thresholds have already fired.
var _warnings_fired: Dictionary = {
	75: false,
	50: false,
	25: false,
}

## Current deterioration multiplier (for external query).
var current_deterioration_multiplier: float = 1.0

## Internal tick accumulator for 1-second signal emission.
var _tick_accumulator: float = 0.0

## Reference to TelemetryEmitter (found at start).
var _telemetry: Node = null


## Start the timer. Called when ScenarioManager.start_scenario() fires.
func start_timer(limit_seconds: float) -> void:
	time_limit_seconds = limit_seconds
	_elapsed = 0.0
	_running = true
	_tick_accumulator = 0.0
	_warnings_fired = { 75: false, 50: false, 25: false }
	current_deterioration_multiplier = 1.0

	# Find telemetry emitter on player
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		_telemetry = players[0].get_node_or_null("TelemetryEmitter")
	else:
		var root: Node = get_tree().current_scene
		if root:
			var player: Node = root.get_node_or_null("Player")
			if player:
				_telemetry = player.get_node_or_null("TelemetryEmitter")


func _process(delta: float) -> void:
	if not _running:
		return

	# Pause when game is paused
	if GameManager.current_state == GameManager.GameState.PAUSED:
		return

	# Apply idle time scaling based on mouse mode.
	# MOUSE_MODE_VISIBLE (UI open / interacting) = 1.0x speed.
	# MOUSE_MODE_CAPTURED (walking around / not interacting) = idle_time_scale.
	var effective_delta: float = delta
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		effective_delta = delta * idle_time_scale

	_elapsed += effective_delta
	_tick_accumulator += effective_delta

	var remaining := maxf(time_limit_seconds - _elapsed, 0.0)

	# Emit time_updated every second
	if _tick_accumulator >= 1.0:
		_tick_accumulator -= 1.0
		time_updated.emit(remaining)

	# Check warning thresholds
	_check_warnings(remaining)

	# Update deterioration multiplier (scale factor passed for deterioration application)
	_update_deterioration_rate()

	# Check time expiry
	if remaining <= 0.0:
		_on_time_expired()


## Check and fire warning signals at 75%, 50%, 25% remaining.
func _check_warnings(remaining: float) -> void:
	if time_limit_seconds <= 0.0:
		return

	var percent_remaining := (remaining / time_limit_seconds) * 100.0

	for threshold: int in [75, 50, 25]:
		if not _warnings_fired[threshold] and percent_remaining <= threshold:
			_warnings_fired[threshold] = true
			time_warning.emit(remaining)


## Update deterioration rate multiplier based on time remaining.
## Applies to all DeteriorationSystem nodes in the scene.
func _update_deterioration_rate() -> void:
	if time_limit_seconds <= 0.0:
		return

	var percent_remaining := ((time_limit_seconds - _elapsed) / time_limit_seconds) * 100.0

	# Find the appropriate multiplier from schedule
	var new_multiplier := 1.0
	var sorted_thresholds: Array = deterioration_schedule.keys()
	sorted_thresholds.sort()

	for threshold in sorted_thresholds:
		if percent_remaining <= threshold:
			new_multiplier = deterioration_schedule[threshold]

	if new_multiplier != current_deterioration_multiplier:
		current_deterioration_multiplier = new_multiplier
		_apply_deterioration_multiplier(new_multiplier)


## Apply the deterioration multiplier to all DeteriorationSystem nodes in the scene.
func _apply_deterioration_multiplier(multiplier: float) -> void:
	var deterioration_nodes := get_tree().get_nodes_in_group("deterioration")
	for node: Node in deterioration_nodes:
		if "deterioration_rate" in node:
			# Store base rate on first application
			if not node.has_meta("base_deterioration_rate"):
				node.set_meta("base_deterioration_rate", node.deterioration_rate)
			var base_rate: float = node.get_meta("base_deterioration_rate")
			node.deterioration_rate = base_rate * multiplier

	# Fallback: search scene tree directly if no group
	if deterioration_nodes.size() == 0:
		_apply_to_tree(get_tree().current_scene, multiplier)


## Recursive fallback — find DeteriorationSystem nodes in scene tree.
func _apply_to_tree(node: Node, multiplier: float) -> void:
	if node == null:
		return
	if node.name == "DeteriorationSystem" and "deterioration_rate" in node:
		if not node.has_meta("base_deterioration_rate"):
			node.set_meta("base_deterioration_rate", node.deterioration_rate)
		var base_rate: float = node.get_meta("base_deterioration_rate")
		node.deterioration_rate = base_rate * multiplier

	for child in node.get_children():
		_apply_to_tree(child, multiplier)


## Handle time expiry — log telemetry, emit signal, stop timer.
func _on_time_expired() -> void:
	_running = false

	if _telemetry and _telemetry.has_method("emit_action"):
		_telemetry.emit_action("scenario_time_expired", "timer", {
			"time_limit": time_limit_seconds,
			"elapsed": _elapsed,
		})

	time_expired.emit()


## Stop the timer manually.
func stop_timer() -> void:
	_running = false


## Get remaining time in seconds.
func get_remaining() -> float:
	return maxf(time_limit_seconds - _elapsed, 0.0)


## Get elapsed time in seconds.
func get_elapsed() -> float:
	return _elapsed


## Get remaining time as a percentage (0.0 to 100.0).
func get_remaining_percent() -> float:
	if time_limit_seconds <= 0.0:
		return 100.0
	return (get_remaining() / time_limit_seconds) * 100.0


## Check if the timer is currently running.
func is_running() -> bool:
	return _running


## Reset the timer state.
func reset() -> void:
	_running = false
	_elapsed = 0.0
	_tick_accumulator = 0.0
	_warnings_fired = { 75: false, 50: false, 25: false }
	current_deterioration_multiplier = 1.0
