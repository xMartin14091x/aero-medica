## RadarChart — Reusable 5-axis spider chart with animated fill.
## Colour-coded: green (>70), yellow (40–70), red (<40).
## Usage: set_scores({"triage_speed": 85, "protocol_accuracy": 60, ...})
extends Control

## Axis definitions (order matters for polygon layout).
const AXES := ["triage_speed", "protocol_accuracy", "decision_quality", "equipment_handling", "patient_outcome"]

## Display labels for each axis.
const AXIS_LABELS := {
	"triage_speed": "Triage Speed",
	"protocol_accuracy": "Protocol Accuracy",
	"decision_quality": "Decision Quality",
	"equipment_handling": "Equipment Handling",
	"patient_outcome": "Patient Outcome",
}

## Colour thresholds.
const COLOUR_GREEN := Color(0.2, 0.8, 0.3, 0.4)
const COLOUR_YELLOW := Color(1.0, 0.85, 0.2, 0.4)
const COLOUR_RED := Color(1.0, 0.3, 0.3, 0.4)

const OUTLINE_GREEN := Color(0.2, 0.8, 0.3, 0.9)
const OUTLINE_YELLOW := Color(1.0, 0.85, 0.2, 0.9)
const OUTLINE_RED := Color(1.0, 0.3, 0.3, 0.9)

const GRID_COLOUR := Color(0.4, 0.4, 0.5, 0.3)
const AXIS_COLOUR := Color(0.5, 0.5, 0.6, 0.5)
const LABEL_COLOUR := Color(0.8, 0.8, 0.85)

## Grid ring percentages.
const GRID_RINGS := [0.25, 0.5, 0.75, 1.0]

## Animation duration for score fill.
const ANIM_DURATION := 0.6

## Internal state.
var _target_scores: Dictionary = {}
var _display_scores: Dictionary = {}
var _anim_tween: Tween = null

## Padding for labels around the chart.
var _label_padding := 40.0


func _ready() -> void:
	for axis in AXES:
		_target_scores[axis] = 0.0
		_display_scores[axis] = 0.0


## Set scores and animate. scores: Dictionary with axis keys → float 0–100.
func set_scores(scores: Dictionary) -> void:
	for axis in AXES:
		_target_scores[axis] = clampf(float(scores.get(axis, 0.0)), 0.0, 100.0)

	# Animate from current display scores to target
	if _anim_tween and _anim_tween.is_valid():
		_anim_tween.kill()

	_anim_tween = create_tween()
	_anim_tween.set_ease(Tween.EASE_OUT)
	_anim_tween.set_trans(Tween.TRANS_CUBIC)

	for axis in AXES:
		var from_val: float = _display_scores[axis]
		var to_val: float = _target_scores[axis]
		_anim_tween.parallel().tween_method(
			func(val: float) -> void:
				_display_scores[axis] = val
				queue_redraw(),
			from_val, to_val, ANIM_DURATION
		)


## Get the overall average score for colour determination.
func _get_overall_score() -> float:
	var total := 0.0
	for axis in AXES:
		total += _display_scores.get(axis, 0.0)
	return total / AXES.size()


## Get fill colour based on overall score.
func _get_fill_colour() -> Color:
	var score := _get_overall_score()
	if score > 70.0:
		return COLOUR_GREEN
	elif score >= 40.0:
		return COLOUR_YELLOW
	return COLOUR_RED


## Get outline colour based on overall score.
func _get_outline_colour() -> Color:
	var score := _get_overall_score()
	if score > 70.0:
		return OUTLINE_GREEN
	elif score >= 40.0:
		return OUTLINE_YELLOW
	return OUTLINE_RED


func _draw() -> void:
	var center := size / 2.0
	var radius := minf(center.x, center.y) - _label_padding

	if radius <= 0.0:
		return

	var num_axes := AXES.size()
	var angle_step := TAU / num_axes
	var start_angle := -PI / 2.0  # Start from top

	# Draw grid rings
	for ring_pct in GRID_RINGS:
		var ring_points := PackedVector2Array()
		for i in num_axes:
			var angle := start_angle + i * angle_step
			var point: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius * ring_pct
			ring_points.append(point)
		ring_points.append(ring_points[0])  # Close ring
		draw_polyline(ring_points, GRID_COLOUR, 1.0)

	# Draw axis lines
	for i in num_axes:
		var angle := start_angle + i * angle_step
		var endpoint: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius
		draw_line(center, endpoint, AXIS_COLOUR, 1.0)

	# Draw filled polygon for scores
	var score_points := PackedVector2Array()
	for i in num_axes:
		var axis: String = AXES[i]
		var score_pct: float = _display_scores.get(axis, 0.0) / 100.0
		var angle := start_angle + i * angle_step
		var point: Vector2 = center + Vector2(cos(angle), sin(angle)) * radius * score_pct
		score_points.append(point)

	if score_points.size() >= 3:
		draw_colored_polygon(score_points, _get_fill_colour())
		# Outline
		var outline_points := score_points.duplicate()
		outline_points.append(outline_points[0])
		draw_polyline(outline_points, _get_outline_colour(), 2.0)

	# Draw data point dots
	for point: Vector2 in score_points:
		draw_circle(point, 4.0, _get_outline_colour())

	# Draw axis labels
	var default_font := ThemeDB.fallback_font
	var font_size := 13

	for i in num_axes:
		var axis: String = AXES[i]
		var label: String = AXIS_LABELS.get(axis, axis)
		var angle := start_angle + i * angle_step
		var label_pos := center + Vector2(cos(angle), sin(angle)) * (radius + 20.0)

		# Centre the label around the position
		var text_size := default_font.get_string_size(label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		label_pos.x -= text_size.x / 2.0
		label_pos.y += text_size.y / 4.0

		# Score value next to label
		var score_val: int = int(_display_scores.get(axis, 0.0))
		var full_label := "%s (%d)" % [label, score_val]
		text_size = default_font.get_string_size(full_label, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		label_pos.x = center.x + Vector2(cos(angle), sin(angle)).x * (radius + 20.0) - text_size.x / 2.0

		draw_string(default_font, label_pos, full_label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, LABEL_COLOUR)
