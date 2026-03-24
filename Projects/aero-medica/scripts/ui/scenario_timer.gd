## ScenarioTimer — HUD countdown display in MM:SS format.
## Colour shifts: white → yellow (50%) → red (25%) → pulsing red (10%).
## Wired to TimePressureSystem.time_updated and time_warning signals.
extends Control

## Colour states for time remaining.
const COLOUR_NORMAL := Color(1.0, 1.0, 1.0)
const COLOUR_WARNING := Color(1.0, 1.0, 0.0)
const COLOUR_DANGER := Color(1.0, 0.0, 0.0)
const COLOUR_CRITICAL := Color(1.0, 0.0, 0.0)

## Pulse speed for critical state (10% remaining).
const PULSE_SPEED := 3.0

## Reference to the time label.
@onready var label: Label = $PanelContainer/Label

## Total time limit (set when timer starts, for percentage calculation).
var _time_limit: float = 0.0

## Whether the timer is visible and active.
var _active: bool = false

## Pulse tween for critical state.
var _pulse_tween: Tween = null

## Current colour state (to avoid redundant updates).
var _current_colour_state: int = 0  # 0=normal, 1=warning, 2=danger, 3=critical


func _ready() -> void:
	visible = false
	_find_and_wire_timer.call_deferred()


## Find TimePressureSystem in the scene and connect signals.
func _find_and_wire_timer() -> void:
	await get_tree().process_frame

	var timer := _find_time_pressure_system()
	if timer:
		timer.time_updated.connect(_on_time_updated)
		timer.time_warning.connect(_on_time_warning)
		timer.time_expired.connect(_on_time_expired)
		_time_limit = timer.time_limit_seconds
		_active = true
		visible = true
		_update_display(_time_limit)


## Search for TimePressureSystem in the scene tree.
func _find_time_pressure_system() -> Node:
	var root := get_tree().current_scene
	if not root:
		return null

	# Search direct children first
	for child in root.get_children():
		if child.has_signal("time_updated") and child.has_method("start_timer"):
			return child

	# Recursive search
	return _find_in_tree(root)


func _find_in_tree(node: Node) -> Node:
	if node.has_signal("time_updated") and node.has_method("start_timer"):
		return node
	for child in node.get_children():
		var found := _find_in_tree(child)
		if found:
			return found
	return null


## TimePressureSystem.time_updated(remaining_seconds) — update display every second.
func _on_time_updated(remaining: float) -> void:
	_update_display(remaining)


## TimePressureSystem.time_warning(remaining_seconds) — warning threshold hit.
func _on_time_warning(remaining: float) -> void:
	_update_colour(remaining)


## TimePressureSystem.time_expired() — time's up.
func _on_time_expired() -> void:
	_update_display(0.0)
	_stop_pulse()
	label.add_theme_color_override("font_color", COLOUR_DANGER)


## Update the MM:SS display.
func _update_display(remaining: float) -> void:
	var total_seconds := int(ceilf(maxf(remaining, 0.0)))
	var minutes := total_seconds / 60
	var seconds := total_seconds % 60
	label.text = "%02d:%02d" % [minutes, seconds]
	_update_colour(remaining)


## Update text colour based on remaining time percentage.
func _update_colour(remaining: float) -> void:
	if _time_limit <= 0.0:
		return

	var percent := (remaining / _time_limit) * 100.0
	var new_state: int

	if percent <= 10.0:
		new_state = 3  # Critical — pulsing red
	elif percent <= 25.0:
		new_state = 2  # Danger — red
	elif percent <= 50.0:
		new_state = 1  # Warning — yellow
	else:
		new_state = 0  # Normal — white

	if new_state == _current_colour_state:
		return
	_current_colour_state = new_state

	match new_state:
		0:
			_stop_pulse()
			label.add_theme_color_override("font_color", COLOUR_NORMAL)
		1:
			_stop_pulse()
			label.add_theme_color_override("font_color", COLOUR_WARNING)
		2:
			_stop_pulse()
			label.add_theme_color_override("font_color", COLOUR_DANGER)
		3:
			label.add_theme_color_override("font_color", COLOUR_CRITICAL)
			_start_pulse()


## Start pulsing red for critical time remaining.
func _start_pulse() -> void:
	_stop_pulse()
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.tween_property(self, "modulate:a", 0.4, 0.5 / PULSE_SPEED)
	_pulse_tween.tween_property(self, "modulate:a", 1.0, 0.5 / PULSE_SPEED)


## Stop pulsing.
func _stop_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
	modulate.a = 1.0


## Set the total time limit (called when scenario starts).
func set_time_limit(limit: float) -> void:
	_time_limit = limit
	_active = true
	visible = true
	_current_colour_state = -1  # Force colour update
	_update_display(limit)


## Hide and reset the timer.
func reset() -> void:
	_active = false
	visible = false
	_stop_pulse()
	_current_colour_state = 0
	label.text = "00:00"


## Clean up.
func _exit_tree() -> void:
	_stop_pulse()
