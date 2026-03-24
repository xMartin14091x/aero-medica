## InstructorDashboard — Aggregate cohort dashboard for B2B demo.
## Summary cards, class radar chart, weakest axis identifier, student list.
## Uses mock multi-student data for competition demo.
extends Control

## Emitted when user clicks a student row.
signal student_selected(student_data: Dictionary)

## Emitted when user wants to go back.
signal back_pressed()

## Colours.
const COLOUR_HEADER := Color(0.9, 0.9, 0.95)
const COLOUR_LABEL := Color(0.6, 0.6, 0.7)
const COLOUR_PASS := Color(0.2, 0.8, 0.3)
const COLOUR_FAIL := Color(1.0, 0.3, 0.3)
const COLOUR_WARN := Color(1.0, 0.85, 0.2)
const COLOUR_HIGHLIGHT := Color(1.0, 0.5, 0.2)

## Pass threshold.
const PASS_THRESHOLD := 60.0

## Axis keys + display names.
const AXES := ["triage_speed", "protocol_accuracy", "decision_quality", "equipment_handling", "patient_outcome"]
const AXIS_LABELS := {
	"triage_speed": "Triage Speed",
	"protocol_accuracy": "Protocol Accuracy",
	"decision_quality": "Decision Quality",
	"equipment_handling": "Equipment Handling",
	"patient_outcome": "Patient Outcome",
}

## UI references.
var _background: ColorRect = null
var _scroll: ScrollContainer = null
var _content_vbox: VBoxContainer = null
var _radar_chart: Control = null

## Mock student data for demo.
var _students: Array = []


func _ready() -> void:
	_build_ui()
	_generate_mock_students()
	# Auto-show on next frame (ensures current_scene is set)
	_auto_show.call_deferred()


func _auto_show() -> void:
	# If this node is the current scene (loaded standalone from main menu), show immediately
	# If embedded as a child, the parent controls visibility via show_dashboard()
	if self == get_tree().current_scene:
		show_dashboard()
	else:
		visible = false


func _build_ui() -> void:
	_background = ColorRect.new()
	_background.color = Color(0.06, 0.06, 0.1, 0.97)
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_background)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	var outer_vbox := VBoxContainer.new()
	outer_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(outer_vbox)

	# Top bar
	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 16)
	outer_vbox.add_child(top_bar)

	var back_btn := Button.new()
	back_btn.text = "< Back"
	back_btn.custom_minimum_size = Vector2(80, 32)
	back_btn.pressed.connect(_on_back_pressed)
	top_bar.add_child(back_btn)

	var title := Label.new()
	title.text = "Instructor Dashboard"
	title.add_theme_font_size_override("font_size", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(title)

	outer_vbox.add_child(HSeparator.new())

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_vbox.add_child(_scroll)

	_content_vbox = VBoxContainer.new()
	_content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_vbox.add_theme_constant_override("separation", 12)
	_scroll.add_child(_content_vbox)


## Show dashboard. If students_data provided, uses it; otherwise uses mock.
func show_dashboard(students_data: Array = []) -> void:
	if not students_data.is_empty():
		_students = students_data
	else:
		# Try to include real session data from last completed scenario
		_inject_real_session_data()
	visible = true
	_populate()


## Inject real session data from ScenarioManager into the student list.
func _inject_real_session_data() -> void:
	var scenario_mgr: Node = get_node_or_null("/root/ScenarioManager")
	if not scenario_mgr or not scenario_mgr.has_method("get_last_results"):
		return

	var results: Dictionary = scenario_mgr.get_last_results()
	if results.is_empty():
		return

	# Build a real "student" entry from the last session
	var events: Array = results.get("events", [])
	var duration: float = results.get("duration_seconds", 0.0)
	var time_limit: float = results.get("time_limit", 0.0)
	var patient_count: int = results.get("patient_count", 0)
	var triage_data: Dictionary = results.get("triage_summary", {})
	var diag_data: Dictionary = results.get("diagnosis_summary", {})

	# Compute per-axis scores from real data
	var triage_speed_score: float = 0.0
	if time_limit > 0.0 and duration > 0.0:
		triage_speed_score = clampf((1.0 - duration / time_limit) * 100.0, 10.0, 95.0)
	elif duration > 0.0:
		triage_speed_score = clampf(80.0 - duration / 10.0, 20.0, 90.0)

	var protocol_score: float = 50.0  # Default — would need protocol adherence tracker
	var action_count: int = 0
	for event: Dictionary in events:
		var etype: String = event.get("type", "")
		if etype.begins_with("assess_") or etype == "treatment_applied":
			action_count += 1
	if action_count > 0:
		protocol_score = clampf(float(action_count) / float(maxi(patient_count * 5, 1)) * 100.0, 20.0, 95.0)

	var decision_score: float = 50.0
	if diag_data.get("patients_diagnosed", 0) > 0:
		decision_score = clampf(float(diag_data.get("total_matches", 0)) / float(maxi(diag_data.get("patients_diagnosed", 1), 1)) * 100.0, 10.0, 95.0)

	var equipment_score: float = 50.0
	var summaries: Array = results.get("patient_summaries", [])
	var total_equip: int = 0
	for s: Dictionary in summaries:
		total_equip += s.get("deployed_equipment", []).size()
	if total_equip > 0:
		equipment_score = clampf(float(total_equip) / float(maxi(patient_count * 3, 1)) * 100.0, 20.0, 95.0)

	var outcome_score: float = 50.0
	var alive_count: int = 0
	for s: Dictionary in summaries:
		if s.get("final_state", "") in ["CONSCIOUS", "UNCONSCIOUS"]:
			alive_count += 1
	if patient_count > 0:
		outcome_score = clampf(float(alive_count) / float(patient_count) * 100.0, 10.0, 95.0)

	var scores := {
		"triage_speed": triage_speed_score,
		"protocol_accuracy": protocol_score,
		"decision_quality": decision_score,
		"equipment_handling": equipment_score,
		"patient_outcome": outcome_score,
	}
	var total := 0.0
	for axis: String in AXES:
		total += scores.get(axis, 0.0)
	scores["overall"] = total / AXES.size()

	var real_entry := {
		"name": "You (Last Session)",
		"scores": scores,
		"timestamp": Time.get_datetime_string_from_system(),
		"scenario_id": results.get("scenario_id", "unknown"),
	}

	# Put the real entry at the top of the list
	_students.insert(0, real_entry)


func _populate() -> void:
	for child in _content_vbox.get_children():
		child.queue_free()

	if _students.is_empty():
		var no_data := Label.new()
		no_data.text = "No student data available"
		no_data.add_theme_font_size_override("font_size", 18)
		no_data.add_theme_color_override("font_color", COLOUR_LABEL)
		_content_vbox.add_child(no_data)
		return

	# Summary cards row
	_add_summary_cards()

	_content_vbox.add_child(HSeparator.new())

	# Two columns: class radar chart + weakest axis
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_vbox.add_child(columns)

	# Left: class average radar chart
	var radar_vbox := VBoxContainer.new()
	radar_vbox.custom_minimum_size = Vector2(320, 320)
	columns.add_child(radar_vbox)

	var radar_title := Label.new()
	radar_title.text = "Class Average Performance"
	radar_title.add_theme_font_size_override("font_size", 18)
	radar_vbox.add_child(radar_title)

	_radar_chart = _create_radar_chart()
	_radar_chart.custom_minimum_size = Vector2(300, 300)
	radar_vbox.add_child(_radar_chart)

	var avg_scores := _calculate_averages()
	_radar_chart.set_scores(avg_scores)

	# Right: weakest axis + stats
	var stats_vbox := VBoxContainer.new()
	stats_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stats_vbox.add_theme_constant_override("separation", 10)
	columns.add_child(stats_vbox)

	_add_weakest_axis(stats_vbox, avg_scores)
	_add_class_stats(stats_vbox)

	_content_vbox.add_child(HSeparator.new())

	# Student list
	var student_header := Label.new()
	student_header.text = "Student Performance"
	student_header.add_theme_font_size_override("font_size", 20)
	_content_vbox.add_child(student_header)

	_add_student_table()


func _add_summary_cards() -> void:
	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 16)
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_vbox.add_child(cards)

	var total := _students.size()
	var pass_count := 0
	var total_overall := 0.0

	for student: Dictionary in _students:
		var overall: float = float(student.get("scores", {}).get("overall", 0.0))
		total_overall += overall
		if overall >= PASS_THRESHOLD:
			pass_count += 1

	var avg_overall := total_overall / maxf(float(total), 1.0)
	var pass_rate := float(pass_count) / maxf(float(total), 1.0) * 100.0

	_add_stat_card(cards, "Total Students", str(total))
	_add_stat_card(cards, "Average Score", "%d%%" % int(avg_overall))
	_add_stat_card(cards, "Pass Rate", "%d%%" % int(pass_rate))
	_add_stat_card(cards, "Attempts", str(total))


func _add_stat_card(container: HBoxContainer, label: String, value: String) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	var label_lbl := Label.new()
	label_lbl.text = label
	label_lbl.add_theme_font_size_override("font_size", 12)
	label_lbl.add_theme_color_override("font_color", COLOUR_LABEL)
	label_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label_lbl)

	var val_lbl := Label.new()
	val_lbl.text = value
	val_lbl.add_theme_font_size_override("font_size", 24)
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(val_lbl)

	container.add_child(card)


func _add_weakest_axis(container: VBoxContainer, avg_scores: Dictionary) -> void:
	var weakest_axis := ""
	var weakest_score := 101.0

	for axis: String in AXES:
		var score: float = float(avg_scores.get(axis, 0.0))
		if score < weakest_score:
			weakest_score = score
			weakest_axis = axis

	if weakest_axis == "":
		return

	var header := Label.new()
	header.text = "Weakest Axis"
	header.add_theme_font_size_override("font_size", 18)
	container.add_child(header)

	var highlight := Label.new()
	highlight.text = "Your class struggles most with %s" % AXIS_LABELS.get(weakest_axis, weakest_axis)
	highlight.add_theme_font_size_override("font_size", 16)
	highlight.add_theme_color_override("font_color", COLOUR_HIGHLIGHT)
	highlight.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(highlight)

	var score_lbl := Label.new()
	score_lbl.text = "Class average: %d%%" % int(weakest_score)
	score_lbl.add_theme_font_size_override("font_size", 14)
	score_lbl.add_theme_color_override("font_color", COLOUR_FAIL if weakest_score < PASS_THRESHOLD else COLOUR_WARN)
	container.add_child(score_lbl)

	# Per-axis averages list
	container.add_child(HSeparator.new())

	var axes_header := Label.new()
	axes_header.text = "All Axis Averages"
	axes_header.add_theme_font_size_override("font_size", 16)
	container.add_child(axes_header)

	for axis: String in AXES:
		var score: float = float(avg_scores.get(axis, 0.0))
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var name_lbl := Label.new()
		name_lbl.text = AXIS_LABELS.get(axis, axis)
		name_lbl.custom_minimum_size.x = 140
		name_lbl.add_theme_font_size_override("font_size", 13)
		name_lbl.add_theme_color_override("font_color", COLOUR_LABEL)
		row.add_child(name_lbl)

		var val_lbl := Label.new()
		val_lbl.text = "%d%%" % int(score)
		val_lbl.add_theme_font_size_override("font_size", 14)
		var c := COLOUR_PASS if score >= 70.0 else (COLOUR_WARN if score >= PASS_THRESHOLD else COLOUR_FAIL)
		val_lbl.add_theme_color_override("font_color", c)
		row.add_child(val_lbl)

		container.add_child(row)


func _add_class_stats(container: VBoxContainer) -> void:
	# Intentionally empty — stats covered by summary cards and axis averages
	pass


func _add_student_table() -> void:
	# Table header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	_content_vbox.add_child(header)

	var columns := ["Student", "Overall", "Triage", "Protocol", "Decision", "Equipment", "Outcome", "Status"]
	var widths := [160, 60, 60, 60, 60, 70, 60, 60]

	for i in columns.size():
		var lbl := Label.new()
		lbl.text = columns[i]
		lbl.custom_minimum_size.x = widths[i]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", COLOUR_LABEL)
		header.add_child(lbl)

	# Sort by overall score descending
	var sorted_students: Array = _students.duplicate()
	sorted_students.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("scores", {}).get("overall", 0.0)) > float(b.get("scores", {}).get("overall", 0.0))
	)

	# Student rows
	for student: Dictionary in sorted_students:
		var row_btn := Button.new()
		row_btn.flat = true
		row_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_btn.pressed.connect(func() -> void: student_selected.emit(student))
		_content_vbox.add_child(row_btn)

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row_btn.add_child(row)

		var scores: Dictionary = student.get("scores", {})
		var overall: float = float(scores.get("overall", 0.0))

		# Name
		var name_lbl := Label.new()
		name_lbl.text = student.get("name", "Unknown")
		name_lbl.custom_minimum_size.x = 160
		name_lbl.add_theme_font_size_override("font_size", 14)
		row.add_child(name_lbl)

		# Overall
		var overall_lbl := Label.new()
		overall_lbl.text = "%d" % int(overall)
		overall_lbl.custom_minimum_size.x = 60
		overall_lbl.add_theme_font_size_override("font_size", 14)
		overall_lbl.add_theme_color_override("font_color", COLOUR_PASS if overall >= PASS_THRESHOLD else COLOUR_FAIL)
		row.add_child(overall_lbl)

		# Per-axis scores
		for axis: String in AXES:
			var score: float = float(scores.get(axis, 0.0))
			var axis_lbl := Label.new()
			axis_lbl.text = "%d" % int(score)
			axis_lbl.custom_minimum_size.x = 60
			axis_lbl.add_theme_font_size_override("font_size", 13)
			var c := COLOUR_PASS if score >= 70.0 else (COLOUR_WARN if score >= PASS_THRESHOLD else COLOUR_FAIL)
			axis_lbl.add_theme_color_override("font_color", c)
			row.add_child(axis_lbl)

		# Pass/Fail
		var status_lbl := Label.new()
		status_lbl.text = "PASS" if overall >= PASS_THRESHOLD else "FAIL"
		status_lbl.custom_minimum_size.x = 60
		status_lbl.add_theme_font_size_override("font_size", 14)
		status_lbl.add_theme_color_override("font_color", COLOUR_PASS if overall >= PASS_THRESHOLD else COLOUR_FAIL)
		row.add_child(status_lbl)


func _calculate_averages() -> Dictionary:
	var totals: Dictionary = {}
	for axis: String in AXES:
		totals[axis] = 0.0

	for student: Dictionary in _students:
		var scores: Dictionary = student.get("scores", {})
		for axis: String in AXES:
			totals[axis] += float(scores.get(axis, 0.0))

	var count := maxf(float(_students.size()), 1.0)
	var averages: Dictionary = {}
	for axis: String in AXES:
		averages[axis] = totals[axis] / count

	return averages


## Generate realistic mock student data for competition demo.
func _generate_mock_students() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 42  # Deterministic for demo

	var names := [
		"Somchai K.", "Nattaya P.", "Worawit S.", "Pimchanok R.", "Thanakrit L."
	]

	_students.clear()

	for i in names.size():
		var base_skill: float = rng.randf_range(35.0, 90.0)
		var scores: Dictionary = {}

		for axis: String in AXES:
			var variation := rng.randf_range(-15.0, 15.0)
			scores[axis] = clampf(base_skill + variation, 10.0, 98.0)

		# Calculate overall
		var total := 0.0
		for axis: String in AXES:
			total += scores[axis]
		scores["overall"] = total / AXES.size()

		_students.append({
			"name": names[i],
			"scores": scores,
			"timestamp": "08-03-2026",
			"scenario_id": "scenario_rta",
		})


func _create_radar_chart() -> Control:
	var radar_scene := load("res://scenes/ui/dashboard/RadarChart.tscn")
	if radar_scene:
		return radar_scene.instantiate()

	var radar_script := load("res://scripts/ui/radar_chart.gd")
	if radar_script:
		var chart := Control.new()
		chart.set_script(radar_script)
		return chart

	return Control.new()


func _on_back_pressed() -> void:
	back_pressed.emit()
	visible = false
	# Navigate back to main menu if loaded as standalone scene
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene("res://scenes/main/MainMenu.tscn")
