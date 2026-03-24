## LineChart — Reusable line graph for historical score progression.
## Supports multiple overlaid series with colour-coded lines and trend indicator.
## Usage: add_series("triage_speed", [80, 75, 85, 90], Color.GREEN)
extends Control

## Series data structure: {name: {points: Array[float], color: Color, visible: bool}}
var _series: Dictionary = {}

## Display config.
const MARGIN_LEFT := 50.0
const MARGIN_RIGHT := 20.0
const MARGIN_TOP := 20.0
const MARGIN_BOTTOM := 40.0

const GRID_COLOUR := Color(0.3, 0.3, 0.4, 0.3)
const AXIS_COLOUR := Color(0.5, 0.5, 0.6, 0.6)
const LABEL_COLOUR := Color(0.7, 0.7, 0.8)
const DOT_RADIUS := 4.0
const LINE_WIDTH := 2.0
const TREND_LINE_WIDTH := 1.0

## Y-axis range.
const Y_MIN := 0.0
const Y_MAX := 100.0

## Default axis colours for the 5 skill axes.
const DEFAULT_COLOURS := {
	"triage_speed": Color(0.2, 0.8, 0.3),
	"protocol_accuracy": Color(0.3, 0.6, 1.0),
	"decision_quality": Color(1.0, 0.85, 0.2),
	"equipment_handling": Color(0.9, 0.4, 0.9),
	"patient_outcome": Color(1.0, 0.5, 0.2),
	"overall": Color(1.0, 1.0, 1.0),
}


## Add or update a data series.
func add_series(series_name: String, data_points: Array, colour: Color = Color.WHITE) -> void:
	if colour == Color.WHITE and series_name in DEFAULT_COLOURS:
		colour = DEFAULT_COLOURS[series_name]

	_series[series_name] = {
		"points": data_points,
		"color": colour,
		"visible": true,
	}
	queue_redraw()


## Remove a data series.
func remove_series(series_name: String) -> void:
	_series.erase(series_name)
	queue_redraw()


## Toggle series visibility.
func toggle_series(series_name: String) -> void:
	if series_name in _series:
		_series[series_name]["visible"] = not _series[series_name]["visible"]
		queue_redraw()


## Clear all series.
func clear() -> void:
	_series.clear()
	queue_redraw()


## Set data from HistoryManager format: Array of session Dictionaries.
func set_history_data(history: Array, axes: Array = []) -> void:
	clear()
	if axes.is_empty():
		axes = ["triage_speed", "protocol_accuracy", "decision_quality", "equipment_handling", "patient_outcome", "overall"]

	for axis: String in axes:
		var points: Array = []
		for session: Dictionary in history:
			var scores: Dictionary = session.get("scores", {})
			points.append(float(scores.get(axis, 0.0)))
		if not points.is_empty():
			add_series(axis, points)


func _draw() -> void:
	var chart_rect := Rect2(
		MARGIN_LEFT, MARGIN_TOP,
		size.x - MARGIN_LEFT - MARGIN_RIGHT,
		size.y - MARGIN_TOP - MARGIN_BOTTOM
	)

	if chart_rect.size.x <= 0.0 or chart_rect.size.y <= 0.0:
		return

	# Draw background grid
	_draw_grid(chart_rect)

	# Draw each visible series
	for series_name: String in _series:
		var series: Dictionary = _series[series_name]
		if series["visible"]:
			_draw_series(chart_rect, series)

	# Draw legend
	_draw_legend(chart_rect)


func _draw_grid(rect: Rect2) -> void:
	var default_font := ThemeDB.fallback_font
	var font_size := 11

	# Horizontal grid lines at 0, 25, 50, 75, 100
	for val in [0, 25, 50, 75, 100]:
		var y := rect.position.y + rect.size.y * (1.0 - float(val) / Y_MAX)
		draw_line(
			Vector2(rect.position.x, y),
			Vector2(rect.position.x + rect.size.x, y),
			GRID_COLOUR, 1.0
		)
		# Y-axis label
		draw_string(default_font,
			Vector2(rect.position.x - 30, y + 4),
			str(val), HORIZONTAL_ALIGNMENT_RIGHT, 28, font_size, LABEL_COLOUR
		)

	# X-axis labels (attempt numbers)
	var max_points := _get_max_point_count()
	if max_points > 0:
		for i in max_points:
			var x := rect.position.x + rect.size.x * float(i) / maxf(float(max_points - 1), 1.0)
			# Tick mark
			draw_line(
				Vector2(x, rect.position.y + rect.size.y),
				Vector2(x, rect.position.y + rect.size.y + 5),
				AXIS_COLOUR, 1.0
			)
			draw_string(default_font,
				Vector2(x - 4, rect.position.y + rect.size.y + 18),
				str(i + 1), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, LABEL_COLOUR
			)

	# Axes
	draw_line(rect.position, Vector2(rect.position.x, rect.position.y + rect.size.y), AXIS_COLOUR, 1.0)
	draw_line(
		Vector2(rect.position.x, rect.position.y + rect.size.y),
		Vector2(rect.position.x + rect.size.x, rect.position.y + rect.size.y),
		AXIS_COLOUR, 1.0
	)


func _draw_series(rect: Rect2, series: Dictionary) -> void:
	var points: Array = series["points"]
	var colour: Color = series["color"]

	if points.size() < 1:
		return

	var max_points := _get_max_point_count()
	var screen_points := PackedVector2Array()

	for i in points.size():
		var x := rect.position.x + rect.size.x * float(i) / maxf(float(max_points - 1), 1.0)
		var val: float = clampf(float(points[i]), Y_MIN, Y_MAX)
		var y := rect.position.y + rect.size.y * (1.0 - val / Y_MAX)
		screen_points.append(Vector2(x, y))

	# Draw line segments
	if screen_points.size() >= 2:
		draw_polyline(screen_points, colour, LINE_WIDTH, true)

	# Draw data point dots
	for point in screen_points:
		draw_circle(point, DOT_RADIUS, colour)

	# Draw trend line if enough points
	if points.size() >= 3:
		_draw_trend_line(rect, points, colour, max_points)


func _draw_trend_line(rect: Rect2, points: Array, colour: Color, max_points: int) -> void:
	# Simple linear regression
	var n := points.size()
	var sum_x := 0.0
	var sum_y := 0.0
	var sum_xy := 0.0
	var sum_xx := 0.0

	for i in n:
		var x := float(i)
		var y: float = float(points[i])
		sum_x += x
		sum_y += y
		sum_xy += x * y
		sum_xx += x * x

	var denom := n * sum_xx - sum_x * sum_x
	if absf(denom) < 0.001:
		return

	var slope := (n * sum_xy - sum_x * sum_y) / denom
	var intercept := (sum_y - slope * sum_x) / n

	# Draw dashed trend line from first to last point
	var trend_colour := Color(colour.r, colour.g, colour.b, 0.4)

	var x0 := rect.position.x
	var y0_val := clampf(intercept, Y_MIN, Y_MAX)
	var y0 := rect.position.y + rect.size.y * (1.0 - y0_val / Y_MAX)

	var x1 := rect.position.x + rect.size.x * float(n - 1) / maxf(float(max_points - 1), 1.0)
	var y1_val := clampf(intercept + slope * float(n - 1), Y_MIN, Y_MAX)
	var y1 := rect.position.y + rect.size.y * (1.0 - y1_val / Y_MAX)

	# Dashed line approximation
	var dash_len := 8.0
	var gap_len := 6.0
	var total_len := Vector2(x1 - x0, y1 - y0).length()
	var dir := Vector2(x1 - x0, y1 - y0).normalized()
	var pos := 0.0

	while pos < total_len:
		var seg_start := Vector2(x0, y0) + dir * pos
		var seg_end := Vector2(x0, y0) + dir * minf(pos + dash_len, total_len)
		draw_line(seg_start, seg_end, trend_colour, TREND_LINE_WIDTH)
		pos += dash_len + gap_len


func _draw_legend(rect: Rect2) -> void:
	var default_font := ThemeDB.fallback_font
	var font_size := 11
	var x := rect.position.x + 8.0
	var y := rect.position.y + 14.0
	var spacing := 14.0

	for series_name: String in _series:
		var series: Dictionary = _series[series_name]
		if not series["visible"]:
			continue

		var colour: Color = series["color"]
		# Small colour square
		draw_rect(Rect2(x, y - 8, 8, 8), colour)
		# Label
		var label: String = series_name.replace("_", " ").capitalize()
		draw_string(default_font, Vector2(x + 12, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, LABEL_COLOUR)
		y += spacing


func _get_max_point_count() -> int:
	var max_count := 0
	for series_name: String in _series:
		var points: Array = _series[series_name]["points"]
		max_count = maxi(max_count, points.size())
	return max_count
