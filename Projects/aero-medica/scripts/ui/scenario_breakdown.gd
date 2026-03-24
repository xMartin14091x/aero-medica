## ScenarioBreakdown — Detailed per-scenario score view.
## Header (name, date, score, PASS/FAIL), RadarChart, per-axis bars,
## per-patient cards, action timeline, AI review + export buttons.
extends Control

## Emitted when user wants to go back.
signal back_pressed()

## Pass threshold.
const PASS_THRESHOLD := 60.0

## Colours.
const COLOUR_PASS := Color(0.2, 0.8, 0.3)
const COLOUR_FAIL := Color(1.0, 0.3, 0.3)
const COLOUR_BAR_BG := Color(0.2, 0.2, 0.25)
const COLOUR_LABEL := Color(0.6, 0.6, 0.7)

## Axis display names.
const AXIS_NAMES := {
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
var _review_panel_ref: Control = null

## Stored data for AI review access.
var _session_data: Dictionary = {}


func _ready() -> void:
	visible = false
	_build_ui()


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

	# Top bar: back button + title
	var top_bar := HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 16)
	outer_vbox.add_child(top_bar)

	var back_btn := Button.new()
	back_btn.text = "< Back"
	back_btn.custom_minimum_size = Vector2(80, 32)
	back_btn.pressed.connect(func() -> void: visible = false; back_pressed.emit())
	top_bar.add_child(back_btn)

	var title := Label.new()
	title.text = "Scenario Breakdown"
	title.add_theme_font_size_override("font_size", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_bar.add_child(title)

	outer_vbox.add_child(HSeparator.new())

	# Scrollable content
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_vbox.add_child(_scroll)

	_content_vbox = VBoxContainer.new()
	_content_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_vbox.add_theme_constant_override("separation", 12)
	_scroll.add_child(_content_vbox)


## Show breakdown for a specific session.
func show_breakdown(session_data: Dictionary) -> void:
	_session_data = session_data
	visible = true
	_populate(session_data)


func _populate(data: Dictionary) -> void:
	for child in _content_vbox.get_children():
		child.queue_free()

	var scores: Dictionary = data.get("scores", {})
	var overall: float = float(scores.get("overall", 0.0))
	var is_pass: bool = overall >= PASS_THRESHOLD

	# Header: scenario name, date, overall score, PASS/FAIL
	_add_header(data, overall, is_pass)

	_content_vbox.add_child(HSeparator.new())

	# Two-column: radar chart left, per-axis bars right
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_vbox.add_child(columns)

	# Radar chart
	var radar_container := VBoxContainer.new()
	radar_container.custom_minimum_size = Vector2(300, 300)
	columns.add_child(radar_container)

	_radar_chart = _create_radar_chart()
	_radar_chart.custom_minimum_size = Vector2(300, 300)
	radar_container.add_child(_radar_chart)
	_radar_chart.set_scores(scores)

	# Per-axis bars
	var bars_container := VBoxContainer.new()
	bars_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bars_container.add_theme_constant_override("separation", 8)
	columns.add_child(bars_container)

	var bars_header := Label.new()
	bars_header.text = "Axis Scores"
	bars_header.add_theme_font_size_override("font_size", 18)
	bars_container.add_child(bars_header)

	for axis: String in AXIS_NAMES:
		var score: float = float(scores.get(axis, 0.0))
		_add_score_bar(bars_container, AXIS_NAMES[axis], score)

	_content_vbox.add_child(HSeparator.new())

	# Per-patient cards
	var patients_header := Label.new()
	patients_header.text = "Patient Results"
	patients_header.add_theme_font_size_override("font_size", 20)
	_content_vbox.add_child(patients_header)

	var patient_summaries: Array = data.get("patient_summaries", [])
	if patient_summaries.is_empty():
		patient_summaries = _build_patient_summaries(data)

	for summary: Dictionary in patient_summaries:
		_add_patient_card(summary)

	_content_vbox.add_child(HSeparator.new())

	# Action timeline (simplified)
	var timeline_header := Label.new()
	timeline_header.text = "Key Actions"
	timeline_header.add_theme_font_size_override("font_size", 20)
	_content_vbox.add_child(timeline_header)

	_add_action_timeline(data)

	_content_vbox.add_child(HSeparator.new())

	# Buttons row
	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 16)
	_content_vbox.add_child(btn_row)

	var review_btn := Button.new()
	review_btn.text = "View AI Review"
	review_btn.custom_minimum_size = Vector2(160, 36)
	review_btn.pressed.connect(_on_view_ai_review)
	btn_row.add_child(review_btn)

	var export_btn := Button.new()
	export_btn.text = "Export Data"
	export_btn.custom_minimum_size = Vector2(140, 36)
	export_btn.pressed.connect(_on_export)
	btn_row.add_child(export_btn)


func _add_header(data: Dictionary, overall: float, is_pass: bool) -> void:
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 20)
	_content_vbox.add_child(header)

	var info_vbox := VBoxContainer.new()
	info_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(info_vbox)

	var scenario_name := Label.new()
	scenario_name.text = data.get("scenario_id", "Unknown Scenario").replace("_", " ").capitalize()
	scenario_name.add_theme_font_size_override("font_size", 24)
	info_vbox.add_child(scenario_name)

	var date_lbl := Label.new()
	var timestamp: String = data.get("timestamp", "")
	date_lbl.text = timestamp if timestamp != "" else "No date"
	date_lbl.add_theme_font_size_override("font_size", 14)
	date_lbl.add_theme_color_override("font_color", COLOUR_LABEL)
	info_vbox.add_child(date_lbl)

	# Overall score display
	var score_vbox := VBoxContainer.new()
	score_vbox.custom_minimum_size.x = 120
	header.add_child(score_vbox)

	var score_lbl := Label.new()
	score_lbl.text = "%d%%" % int(overall)
	score_lbl.add_theme_font_size_override("font_size", 36)
	score_lbl.add_theme_color_override("font_color", COLOUR_PASS if is_pass else COLOUR_FAIL)
	score_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_vbox.add_child(score_lbl)

	var badge := Label.new()
	badge.text = "PASS" if is_pass else "FAIL"
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", COLOUR_PASS if is_pass else COLOUR_FAIL)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score_vbox.add_child(badge)


func _add_score_bar(container: VBoxContainer, label: String, score: float) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	container.add_child(row)

	var name_lbl := Label.new()
	name_lbl.text = label
	name_lbl.custom_minimum_size.x = 140
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", COLOUR_LABEL)
	row.add_child(name_lbl)

	# Bar background
	var bar_bg := ColorRect.new()
	bar_bg.color = COLOUR_BAR_BG
	bar_bg.custom_minimum_size = Vector2(150, 16)
	bar_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(bar_bg)

	# Bar fill
	var bar_fill := ColorRect.new()
	var fill_colour := COLOUR_PASS if score >= PASS_THRESHOLD else COLOUR_FAIL
	bar_fill.color = fill_colour
	bar_fill.custom_minimum_size = Vector2(150.0 * score / 100.0, 16)
	bar_bg.add_child(bar_fill)

	# Score value
	var val_lbl := Label.new()
	val_lbl.text = "%d" % int(score)
	val_lbl.custom_minimum_size.x = 30
	val_lbl.add_theme_font_size_override("font_size", 13)
	val_lbl.add_theme_color_override("font_color", fill_colour)
	row.add_child(val_lbl)

	# Pass/fail indicator
	var pf_lbl := Label.new()
	pf_lbl.text = "✓" if score >= PASS_THRESHOLD else "✗"
	pf_lbl.add_theme_font_size_override("font_size", 14)
	pf_lbl.add_theme_color_override("font_color", fill_colour)
	row.add_child(pf_lbl)


func _add_patient_card(summary: Dictionary) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	card.add_child(margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	margin.add_child(hbox)

	# Name
	var name_lbl := Label.new()
	name_lbl.text = summary.get("name", "Unknown")
	name_lbl.add_theme_font_size_override("font_size", 15)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(name_lbl)

	# State
	var state: String = summary.get("final_state", "Unknown")
	var state_lbl := Label.new()
	state_lbl.text = state
	state_lbl.add_theme_font_size_override("font_size", 13)
	var state_colour := Color.WHITE
	match state:
		"CONSCIOUS":
			state_colour = Color(0.3, 0.9, 0.3)
		"UNCONSCIOUS":
			state_colour = Color(1.0, 0.9, 0.2)
		"CARDIAC_ARREST":
			state_colour = Color(1.0, 0.3, 0.3)
		"DEAD":
			state_colour = Color(0.4, 0.4, 0.4)
	state_lbl.add_theme_color_override("font_color", state_colour)
	hbox.add_child(state_lbl)

	# Triage tag
	var tag: String = summary.get("triage_tag", "")
	if tag != "":
		var tag_lbl := Label.new()
		tag_lbl.text = "[%s]" % tag
		tag_lbl.add_theme_font_size_override("font_size", 13)
		var tag_colours := {
			"GREEN": Color(0.0, 1.0, 0.0),
			"YELLOW": Color(1.0, 1.0, 0.0),
			"RED": Color(1.0, 0.0, 0.0),
			"BLACK": Color(0.5, 0.5, 0.5),
		}
		tag_lbl.add_theme_color_override("font_color", tag_colours.get(tag, Color.WHITE))
		hbox.add_child(tag_lbl)

		var correct: bool = summary.get("triage_correct", true)
		var check_lbl := Label.new()
		check_lbl.text = "✓" if correct else "✗"
		check_lbl.add_theme_font_size_override("font_size", 14)
		check_lbl.add_theme_color_override("font_color", COLOUR_PASS if correct else COLOUR_FAIL)
		hbox.add_child(check_lbl)

	# Treatment applied
	var treatment: String = summary.get("treatment", "")
	if treatment != "":
		var treat_lbl := Label.new()
		treat_lbl.text = treatment
		treat_lbl.add_theme_font_size_override("font_size", 12)
		treat_lbl.add_theme_color_override("font_color", COLOUR_LABEL)
		hbox.add_child(treat_lbl)

	_content_vbox.add_child(card)


func _add_action_timeline(data: Dictionary) -> void:
	var events: Array = data.get("events", [])
	var key_events: Array = []

	# Filter to key actions only
	for event: Dictionary in events:
		var event_type: String = event.get("type", "")
		if event_type in ["assess_airway", "assess_breathing", "assess_pulse", "assess_consciousness", "assess_bleeding",
				"treatment_applied", "triage_assign", "equipment_pickup", "equipment_use"]:
			key_events.append(event)

	if key_events.is_empty():
		var no_data := Label.new()
		no_data.text = "No action data available"
		no_data.add_theme_font_size_override("font_size", 14)
		no_data.add_theme_color_override("font_color", COLOUR_LABEL)
		_content_vbox.add_child(no_data)
		return

	# Show up to 20 key events
	var max_events := mini(key_events.size(), 20)
	for i in max_events:
		var event: Dictionary = key_events[i]
		var hbox := HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)

		var time_lbl := Label.new()
		var timestamp: float = event.get("timestamp", 0.0)
		time_lbl.text = "%02d:%02d" % [int(timestamp) / 60, int(timestamp) % 60]
		time_lbl.custom_minimum_size.x = 50
		time_lbl.add_theme_font_size_override("font_size", 12)
		time_lbl.add_theme_color_override("font_color", COLOUR_LABEL)
		hbox.add_child(time_lbl)

		var type_lbl := Label.new()
		type_lbl.text = event.get("type", "").replace("_", " ").capitalize()
		type_lbl.custom_minimum_size.x = 140
		type_lbl.add_theme_font_size_override("font_size", 12)
		hbox.add_child(type_lbl)

		var target_lbl := Label.new()
		target_lbl.text = event.get("target", "")
		target_lbl.add_theme_font_size_override("font_size", 12)
		target_lbl.add_theme_color_override("font_color", COLOUR_LABEL)
		hbox.add_child(target_lbl)

		_content_vbox.add_child(hbox)


func _build_patient_summaries(data: Dictionary) -> Array:
	var summaries: Array = []
	var events: Array = data.get("events", [])
	var seen: Dictionary = {}

	for event: Dictionary in events:
		var target: String = event.get("target", "")
		if target == "" or target in seen:
			continue
		var event_type: String = event.get("type", "")
		if event_type.begins_with("assess_") or event_type == "triage_assign":
			seen[target] = true
			summaries.append({
				"name": target,
				"final_state": event.get("details", {}).get("state", "Unknown"),
				"triage_tag": event.get("details", {}).get("assigned_tag", ""),
				"triage_correct": event.get("details", {}).get("is_correct", true),
			})
	return summaries


func _on_view_ai_review() -> void:
	# Find ReviewPanel in scene tree and show stored review
	var root: Node = get_tree().current_scene
	if root:
		var review_panel: Node = _find_node_by_method(root, "show_review")
		if review_panel:
			var review_data: Dictionary = _session_data.get("review_data", {})
			if not review_data.is_empty():
				review_panel.show_review(review_data, _session_data.get("scores", {}))
			else:
				review_panel.show_error("No AI review available for this session")


func _on_export() -> void:
	# Find DataExporter in scene tree
	var root: Node = get_tree().current_scene
	if root:
		var exporter: Node = _find_node_by_method(root, "quick_export_json")
		if exporter:
			exporter.quick_export_json()


func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null


func _create_radar_chart() -> Control:
	# Try to load RadarChart scene, fallback to script-only
	var radar_scene := load("res://scenes/ui/dashboard/RadarChart.tscn")
	if radar_scene:
		return radar_scene.instantiate()

	# Fallback: create from script
	var radar_script := load("res://scripts/ui/radar_chart.gd")
	if radar_script:
		var chart := Control.new()
		chart.set_script(radar_script)
		return chart

	# Last resort: empty control
	return Control.new()
