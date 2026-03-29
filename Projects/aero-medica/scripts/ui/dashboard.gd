## Dashboard -- Player-only 2-tab dashboard: My Performance, Scenario Breakdown.
## Reads personal history from HistoryManager autoload. No class/student data.
## Fully styled with ThemeMedical. Integrates DataExporter for CSV/JSON export.
extends Control

## Emitted when user wants to go back.
signal back_pressed()

## Pass threshold.
const PASS_THRESHOLD := 60.0

## Axis keys + display names.
const AXES: Array[String] = [
	"triage_speed", "protocol_accuracy", "decision_quality",
	"equipment_handling", "patient_outcome",
]
var AXIS_LABELS: Dictionary = {
	"triage_speed": tr("AXIS_TRIAGE_SPEED"),
	"protocol_accuracy": tr("AXIS_PROTOCOL_ACCURACY"),
	"decision_quality": tr("AXIS_DECISION_QUALITY"),
	"equipment_handling": tr("AXIS_EQUIPMENT_HANDLING"),
	"patient_outcome": tr("AXIS_PATIENT_OUTCOME"),
}

## Scenario definitions for Tab 2 pills.
const SCENARIOS: Array[Dictionary] = [
	{"id": "tutorial_01", "label": "Tutorial"},
	{"id": "rta_intersection_01", "label": "RTA"},
	{"id": "cardiac_arrest_01", "label": "Cardiac"},
	{"id": "mci_market_01", "label": "MCI"},
	{"id": "building_fire_01", "label": "Fire"},
]

## Tab identifiers.
const TAB_MY_PERFORMANCE := "my_performance"
const TAB_SCENARIO_BREAKDOWN := "scenario_breakdown"

## -- Internal State -------------------------------------------------------
var _dash_tabs: Dictionary = {}       ## name -> Control (tab content container)
var _dash_tab_btns: Dictionary = {}   ## name -> Button (tab pill)
var _current_dash_tab: String = TAB_MY_PERFORMANCE

var _selected_scenario: String = "tutorial_01"
var _scenario_pills: Dictionary = {}  ## id -> Button

## ThemeMedical reference (resolved at _ready).
var tm: Node = null

## HistoryManager reference (resolved at _ready).
var hm: Node = null

## DataExporter instance.
var _exporter: Node = null

## UI references.
var _background: ColorRect = null
var _outer_vbox: VBoxContainer = null
var _tab_bar: HBoxContainer = null
var _tab_content_parent: Control = null

## Scenario breakdown sub-references for rebuild.
var _scenario_radar: Control = null
var _scenario_table_container: VBoxContainer = null
var _scenario_stats_container: VBoxContainer = null
var _scenario_export_btn_csv: Button = null
var _scenario_export_btn_json: Button = null


func _ready() -> void:
	tm = get_node_or_null("/root/ThemeMedical")
	hm = get_node_or_null("/root/HistoryManager")

	# Add DataExporter as child
	var exporter_script: Resource = load("res://scripts/dashboard/data_exporter.gd")
	if exporter_script:
		_exporter = Node.new()
		_exporter.set_script(exporter_script)
		_exporter.name = "DataExporter"
		add_child(_exporter)

	_build_ui()
	_auto_show.call_deferred()


func _auto_show() -> void:
	if self == get_tree().current_scene:
		show_dashboard()
	else:
		visible = false


## -- Public API -----------------------------------------------------------

## Show dashboard. Re-reads ALL data from HistoryManager every time (fresh from disk).
func show_dashboard() -> void:
	visible = true
	_populate_all_tabs()
	_switch_tab(_current_dash_tab)


## -- UI Construction ------------------------------------------------------

func _build_ui() -> void:
	# Background
	_background = ColorRect.new()
	if tm:
		_background.color = tm.c("bg_main")
	else:
		_background.color = Color(0.06, 0.06, 0.1, 0.97)
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_background)

	# Outer margin
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	add_child(margin)

	_outer_vbox = VBoxContainer.new()
	_outer_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_outer_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_outer_vbox.add_theme_constant_override("separation", 12)
	margin.add_child(_outer_vbox)

	# Top bar: back button + title
	var top_bar: HBoxContainer = HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 16)
	_outer_vbox.add_child(top_bar)

	var back_btn: Button = Button.new()
	back_btn.text = "< Back"
	back_btn.custom_minimum_size = Vector2(80, 36)
	back_btn.pressed.connect(_on_back_pressed)
	if tm:
		tm.style_button(back_btn, "small")
	top_bar.add_child(back_btn)

	var title: Label = Label.new()
	title.text = tr("DASHBOARD_TITLE")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if tm:
		tm.style_label(title, "title_large")
	else:
		title.add_theme_font_size_override("font_size", 28)
	top_bar.add_child(title)

	# Tab bar
	_tab_bar = HBoxContainer.new()
	_tab_bar.add_theme_constant_override("separation", 8)
	_outer_vbox.add_child(_tab_bar)

	_create_tab_button(TAB_MY_PERFORMANCE, tr("DASHBOARD_MY_PERFORMANCE"))
	_create_tab_button(TAB_SCENARIO_BREAKDOWN, tr("DASHBOARD_SCENARIO_BREAKDOWN"))

	# Tab content area (holds tab containers, only 1 visible at a time)
	_tab_content_parent = Control.new()
	_tab_content_parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_content_parent.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_outer_vbox.add_child(_tab_content_parent)

	# Create tab containers
	_dash_tabs[TAB_MY_PERFORMANCE] = _create_tab_scroll_container()
	_dash_tabs[TAB_SCENARIO_BREAKDOWN] = _create_tab_scroll_container()

	for tab_key: String in _dash_tabs:
		var tab_ctrl: Control = _dash_tabs[tab_key]
		tab_ctrl.visible = false
		_tab_content_parent.add_child(tab_ctrl)


func _create_tab_button(tab_id: String, label: String) -> void:
	var btn: Button = Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(160, 40)
	btn.pressed.connect(_switch_tab.bind(tab_id))
	if tm:
		btn.add_theme_stylebox_override("normal", tm.make_tab_inactive())
		btn.add_theme_stylebox_override("hover", tm.make_btn_hover())
		btn.add_theme_stylebox_override("pressed", tm.make_tab_active())
		btn.add_theme_color_override("font_color", tm.c("text_primary"))
		btn.add_theme_color_override("font_hover_color", tm.c("accent_blue"))
		btn.add_theme_font_size_override("font_size", 15)
	_tab_bar.add_child(btn)
	_dash_tab_btns[tab_id] = btn


func _create_tab_scroll_container() -> ScrollContainer:
	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	return scroll


## -- Tab Switching --------------------------------------------------------

func _switch_tab(tab_id: String) -> void:
	_current_dash_tab = tab_id

	# Update tab button styles
	for key: String in _dash_tab_btns:
		var btn: Button = _dash_tab_btns[key]
		if tm:
			if key == tab_id:
				btn.add_theme_stylebox_override("normal", tm.make_tab_active())
			else:
				btn.add_theme_stylebox_override("normal", tm.make_tab_inactive())

	# Show/hide tab content
	for key: String in _dash_tabs:
		var tab_ctrl: Control = _dash_tabs[key]
		tab_ctrl.visible = (key == tab_id)


## -- Populate All Tabs ----------------------------------------------------

func _populate_all_tabs() -> void:
	_populate_my_performance()
	_populate_scenario_breakdown()


## -- Tab 1: My Performance ------------------------------------------------

func _populate_my_performance() -> void:
	var scroll: ScrollContainer = _dash_tabs[TAB_MY_PERFORMANCE]
	_clear_children(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)

	# Pull personal history from HistoryManager (fresh from disk)
	var all_history: Array = []
	if hm and hm.has_method("get_all_history"):
		all_history = hm.get_all_history()

	if all_history.is_empty():
		_add_empty_state(content, tr("DASHBOARD_EMPTY_STATE"))
		return

	# Two-column layout: radar (40%) | sessions (60%)
	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(columns)

	# -- Left Column: Personal Radar + Score + LineChart --
	var left_vbox: VBoxContainer = VBoxContainer.new()
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.size_flags_stretch_ratio = 0.4
	left_vbox.add_theme_constant_override("separation", 12)
	columns.add_child(left_vbox)

	# Personal radar chart card
	var radar_card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(radar_card)
	left_vbox.add_child(radar_card)

	var radar_vbox: VBoxContainer = VBoxContainer.new()
	radar_vbox.add_theme_constant_override("separation", 8)
	radar_card.add_child(radar_vbox)

	var radar_title: Label = Label.new()
	radar_title.text = tr("DASHBOARD_YOUR_PERFORMANCE")
	if tm:
		tm.style_label(radar_title, "subtitle")
	else:
		radar_title.add_theme_font_size_override("font_size", 18)
	radar_vbox.add_child(radar_title)

	var personal_radar: Control = _create_radar_chart()
	personal_radar.custom_minimum_size = Vector2(280, 280)
	radar_vbox.add_child(personal_radar)

	# Compute personal averages from all history
	var personal_avg: Dictionary = _compute_personal_averages(all_history)
	personal_radar.set_scores(personal_avg)

	# Overall score hero number
	var overall_val: float = 0.0
	for axis: String in AXES:
		overall_val += personal_avg.get(axis, 0.0)
	overall_val /= AXES.size()

	var score_card: PanelContainer = PanelContainer.new()
	if tm:
		var severity: String = "good" if overall_val >= 70.0 else ("normal" if overall_val >= PASS_THRESHOLD else "critical")
		tm.style_panel(score_card, severity)
	left_vbox.add_child(score_card)

	var score_inner: VBoxContainer = VBoxContainer.new()
	score_inner.add_theme_constant_override("separation", 4)
	score_card.add_child(score_inner)

	var score_label: Label = Label.new()
	score_label.text = tr("DASHBOARD_OVERALL_SCORE")
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if tm:
		tm.style_label(score_label, "label", "text_secondary")
	score_inner.add_child(score_label)

	var score_hero: Label = Label.new()
	score_hero.text = "%d%%" % int(overall_val)
	score_hero.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if tm:
		tm.style_label(score_hero, "hero_number")
	else:
		score_hero.add_theme_font_size_override("font_size", 36)
	score_inner.add_child(score_hero)

	# Best + Weakest axis callouts with trend indicators
	var best_axis: String = ""
	var best_val: float = -1.0
	var weak_axis: String = ""
	var weak_val: float = 101.0
	for axis: String in AXES:
		var v: float = personal_avg.get(axis, 0.0)
		if v > best_val:
			best_val = v
			best_axis = axis
		if v < weak_val:
			weak_val = v
			weak_axis = axis

	var callout_card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(callout_card)
	left_vbox.add_child(callout_card)

	var callout_vbox: VBoxContainer = VBoxContainer.new()
	callout_vbox.add_theme_constant_override("separation", 6)
	callout_card.add_child(callout_vbox)

	# Best axis with trend
	var best_trend_arrow: String = _get_overall_trend_arrow(best_axis, all_history)
	var best_lbl: Label = Label.new()
	best_lbl.text = tr("DASHBOARD_BEST_FORMAT") % [AXIS_LABELS.get(best_axis, best_axis), int(best_val)] + " " + best_trend_arrow
	if tm:
		tm.style_label(best_lbl, "body", "accent_green")
	callout_vbox.add_child(best_lbl)

	# Weakest axis with trend
	var weak_trend_arrow: String = _get_overall_trend_arrow(weak_axis, all_history)
	var weak_lbl: Label = Label.new()
	weak_lbl.text = tr("DASHBOARD_WEAKEST_FORMAT") % [AXIS_LABELS.get(weak_axis, weak_axis), int(weak_val)] + " " + weak_trend_arrow
	if tm:
		tm.style_label(weak_lbl, "body", "accent_red")
	callout_vbox.add_child(weak_lbl)

	# -- LineChart: Score Progression --
	var line_card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(line_card)
	left_vbox.add_child(line_card)

	var line_vbox: VBoxContainer = VBoxContainer.new()
	line_vbox.add_theme_constant_override("separation", 8)
	line_card.add_child(line_vbox)

	var line_title: Label = Label.new()
	line_title.text = tr("DASHBOARD_PROGRESSION")
	if tm:
		tm.style_label(line_title, "subtitle")
	else:
		line_title.add_theme_font_size_override("font_size", 16)
	line_vbox.add_child(line_title)

	var line_chart: Control = _create_line_chart()
	line_chart.custom_minimum_size = Vector2(280, 200)
	line_vbox.add_child(line_chart)

	# Build points per axis from history reversed (chronological order)
	var chronological: Array = all_history.duplicate()
	chronological.reverse()
	for axis: String in AXES:
		var points: Array = []
		for entry: Dictionary in chronological:
			points.append(float(entry.get(axis, 0.0)))
		if not points.is_empty():
			line_chart.add_series(axis, points)

	# -- Right Column: Recent Sessions --
	var right_vbox: VBoxContainer = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_stretch_ratio = 0.6
	right_vbox.add_theme_constant_override("separation", 8)
	columns.add_child(right_vbox)

	var sessions_title: Label = Label.new()
	sessions_title.text = tr("DASHBOARD_RECENT_SESSIONS")
	if tm:
		tm.style_label(sessions_title, "subtitle")
	else:
		sessions_title.add_theme_font_size_override("font_size", 18)
	right_vbox.add_child(sessions_title)

	var sessions_scroll: ScrollContainer = ScrollContainer.new()
	sessions_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sessions_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sessions_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	right_vbox.add_child(sessions_scroll)

	var sessions_list: VBoxContainer = VBoxContainer.new()
	sessions_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sessions_list.add_theme_constant_override("separation", 6)
	sessions_scroll.add_child(sessions_list)

	# Show up to 20 recent sessions
	var display_count: int = mini(all_history.size(), 20)
	for i: int in display_count:
		var entry: Dictionary = all_history[i]
		_add_session_card(sessions_list, entry)

	# -- Bottom: Export Buttons --
	var export_row: HBoxContainer = HBoxContainer.new()
	export_row.add_theme_constant_override("separation", 12)
	content.add_child(export_row)

	var csv_btn: Button = Button.new()
	csv_btn.text = tr("DASHBOARD_EXPORT_CSV")
	csv_btn.custom_minimum_size = Vector2(140, 40)
	csv_btn.pressed.connect(_on_export_all_csv)
	if tm:
		tm.style_button(csv_btn, "small")
	export_row.add_child(csv_btn)

	var json_btn: Button = Button.new()
	json_btn.text = tr("DASHBOARD_EXPORT_JSON")
	json_btn.custom_minimum_size = Vector2(140, 40)
	json_btn.pressed.connect(_on_export_all_json)
	if tm:
		tm.style_button(json_btn, "small")
	export_row.add_child(json_btn)


func _add_session_card(container: VBoxContainer, entry: Dictionary) -> void:
	var card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(card)
	container.add_child(card)

	var hbox: HBoxContainer = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	card.add_child(hbox)

	# Scenario name
	var scenario_id: String = entry.get("scenario_id", "unknown")
	var scenario_label: String = _get_scenario_display_name(scenario_id)

	var name_lbl: Label = Label.new()
	name_lbl.text = scenario_label
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if tm:
		tm.style_label(name_lbl, "body")
	else:
		name_lbl.add_theme_font_size_override("font_size", 14)
	hbox.add_child(name_lbl)

	# Score percentage
	var overall: float = float(entry.get("overall", 0.0))
	var score_lbl: Label = Label.new()
	score_lbl.text = "%d%%" % int(overall)
	score_lbl.custom_minimum_size.x = 60
	if tm:
		var color_key: String = "accent_green" if overall >= 70.0 else ("accent_yellow" if overall >= PASS_THRESHOLD else "accent_red")
		tm.style_label(score_lbl, "body", color_key)
	hbox.add_child(score_lbl)

	# Pass/Fail badge
	var badge: Label = Label.new()
	badge.text = tr("DEBRIEF_PASS") if overall >= PASS_THRESHOLD else tr("DEBRIEF_FAIL")
	badge.custom_minimum_size.x = 50
	if tm:
		var badge_color: String = "accent_green" if overall >= PASS_THRESHOLD else "accent_red"
		tm.style_label(badge, "body_small", badge_color)
	hbox.add_child(badge)

	# Date
	var date_str: String = entry.get("date", "")
	var date_lbl: Label = Label.new()
	date_lbl.text = date_str
	date_lbl.custom_minimum_size.x = 140
	if tm:
		tm.style_label(date_lbl, "body_small", "text_secondary")
	hbox.add_child(date_lbl)


## -- Tab 2: Scenario Breakdown --------------------------------------------

func _populate_scenario_breakdown() -> void:
	var scroll: ScrollContainer = _dash_tabs[TAB_SCENARIO_BREAKDOWN]
	_clear_children(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)

	# Scenario pills row
	var pill_row: HBoxContainer = HBoxContainer.new()
	pill_row.add_theme_constant_override("separation", 8)
	content.add_child(pill_row)

	_scenario_pills.clear()
	for scenario: Dictionary in SCENARIOS:
		var sid: String = scenario["id"]
		var pill_btn: Button = Button.new()
		pill_btn.text = scenario["label"]
		pill_btn.custom_minimum_size = Vector2(100, 36)
		pill_btn.pressed.connect(_switch_scenario_filter.bind(sid))
		if tm:
			if sid == _selected_scenario:
				pill_btn.add_theme_stylebox_override("normal", tm.make_tab_active())
			else:
				pill_btn.add_theme_stylebox_override("normal", tm.make_tab_inactive())
			pill_btn.add_theme_stylebox_override("hover", tm.make_btn_hover())
			pill_btn.add_theme_color_override("font_color", tm.c("text_primary"))
			pill_btn.add_theme_color_override("font_hover_color", tm.c("accent_blue"))
			pill_btn.add_theme_font_size_override("font_size", 14)
		pill_row.add_child(pill_btn)
		_scenario_pills[sid] = pill_btn

	# Two-column layout below pills
	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(columns)

	# Left: scenario-specific radar + stats
	var left_vbox: VBoxContainer = VBoxContainer.new()
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.size_flags_stretch_ratio = 0.4
	left_vbox.add_theme_constant_override("separation", 12)
	columns.add_child(left_vbox)

	var radar_card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(radar_card)
	radar_card.custom_minimum_size = Vector2(340, 360)
	left_vbox.add_child(radar_card)

	var radar_inner: VBoxContainer = VBoxContainer.new()
	radar_inner.add_theme_constant_override("separation", 8)
	radar_card.add_child(radar_inner)

	var radar_title: Label = Label.new()
	radar_title.text = tr("DASHBOARD_SCENARIO_BREAKDOWN")
	if tm:
		tm.style_label(radar_title, "subtitle")
	radar_inner.add_child(radar_title)

	_scenario_radar = _create_radar_chart()
	_scenario_radar.custom_minimum_size = Vector2(300, 300)
	radar_inner.add_child(_scenario_radar)

	# Scenario stats card below radar
	_scenario_stats_container = VBoxContainer.new()
	_scenario_stats_container.add_theme_constant_override("separation", 8)
	left_vbox.add_child(_scenario_stats_container)

	# Right: player session history table
	var right_vbox: VBoxContainer = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.size_flags_stretch_ratio = 0.6
	right_vbox.add_theme_constant_override("separation", 8)
	columns.add_child(right_vbox)

	var table_title: Label = Label.new()
	table_title.text = tr("DASHBOARD_RECENT_SESSIONS")
	if tm:
		tm.style_label(table_title, "subtitle")
	right_vbox.add_child(table_title)

	_scenario_table_container = VBoxContainer.new()
	_scenario_table_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scenario_table_container.add_theme_constant_override("separation", 4)
	right_vbox.add_child(_scenario_table_container)

	# Bottom: Export buttons for filtered scenario
	var export_row: HBoxContainer = HBoxContainer.new()
	export_row.add_theme_constant_override("separation", 12)
	content.add_child(export_row)

	_scenario_export_btn_csv = Button.new()
	_scenario_export_btn_csv.text = tr("DASHBOARD_EXPORT_CSV")
	_scenario_export_btn_csv.custom_minimum_size = Vector2(140, 40)
	_scenario_export_btn_csv.pressed.connect(_on_export_scenario_csv)
	if tm:
		tm.style_button(_scenario_export_btn_csv, "small")
	export_row.add_child(_scenario_export_btn_csv)

	_scenario_export_btn_json = Button.new()
	_scenario_export_btn_json.text = tr("DASHBOARD_EXPORT_JSON")
	_scenario_export_btn_json.custom_minimum_size = Vector2(140, 40)
	_scenario_export_btn_json.pressed.connect(_on_export_scenario_json)
	if tm:
		tm.style_button(_scenario_export_btn_json, "small")
	export_row.add_child(_scenario_export_btn_json)

	# Initial population
	_rebuild_scenario_view()


func _switch_scenario_filter(scenario_id: String) -> void:
	_selected_scenario = scenario_id

	# Update pill styles
	for sid: String in _scenario_pills:
		var btn: Button = _scenario_pills[sid]
		if tm:
			if sid == scenario_id:
				btn.add_theme_stylebox_override("normal", tm.make_tab_active())
			else:
				btn.add_theme_stylebox_override("normal", tm.make_tab_inactive())

	_rebuild_scenario_view()


func _rebuild_scenario_view() -> void:
	if not _scenario_radar or not _scenario_table_container:
		return

	# Get player's history for the selected scenario
	var scenario_history: Array = []
	if hm and hm.has_method("get_history"):
		scenario_history = hm.get_history(_selected_scenario)

	# Update radar with scenario averages
	if scenario_history.is_empty():
		var empty_scores: Dictionary = {}
		for axis: String in AXES:
			empty_scores[axis] = 0.0
		_scenario_radar.set_scores(empty_scores)
	else:
		var scenario_avg: Dictionary = _compute_personal_averages(scenario_history)
		_scenario_radar.set_scores(scenario_avg)

	# Update stats card
	_clear_children(_scenario_stats_container)
	if scenario_history.is_empty():
		var no_data_lbl: Label = Label.new()
		no_data_lbl.text = tr("DASHBOARD_NO_DATA_SCENARIO")
		if tm:
			tm.style_label(no_data_lbl, "body", "text_muted")
		_scenario_stats_container.add_child(no_data_lbl)
	else:
		_add_scenario_stats_card(_scenario_stats_container, scenario_history)

	# Update session history table
	_clear_children(_scenario_table_container)
	if scenario_history.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = tr("DASHBOARD_NO_DATA_SCENARIO")
		if tm:
			tm.style_label(empty_lbl, "body", "text_muted")
		_scenario_table_container.add_child(empty_lbl)
	else:
		_add_session_history_table(_scenario_table_container, scenario_history)


## -- Scenario Stats Card --------------------------------------------------

func _add_scenario_stats_card(container: VBoxContainer, history: Array) -> void:
	var stats_card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(stats_card)
	container.add_child(stats_card)

	var stats_vbox: VBoxContainer = VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 6)
	stats_card.add_child(stats_vbox)

	var stats_title: Label = Label.new()
	stats_title.text = tr("DASHBOARD_SCENARIO_STATS")
	if tm:
		tm.style_label(stats_title, "subtitle")
	stats_vbox.add_child(stats_title)

	# Session count
	var count_lbl: Label = Label.new()
	count_lbl.text = "%s: %d" % [tr("DASHBOARD_SESSIONS_COUNT"), history.size()]
	if tm:
		tm.style_label(count_lbl, "body_small", "text_secondary")
	stats_vbox.add_child(count_lbl)

	# Best score
	var best_overall: float = 0.0
	for entry: Dictionary in history:
		var ov: float = float(entry.get("overall", 0.0))
		if ov > best_overall:
			best_overall = ov

	var best_lbl: Label = Label.new()
	best_lbl.text = "%s: %d%%" % [tr("DASHBOARD_BEST_SCORE"), int(best_overall)]
	if tm:
		var best_color: String = "accent_green" if best_overall >= 70.0 else ("accent_yellow" if best_overall >= PASS_THRESHOLD else "accent_red")
		tm.style_label(best_lbl, "body_small", best_color)
	stats_vbox.add_child(best_lbl)

	# Latest score
	var latest: Dictionary = history[0] if not history.is_empty() else {}
	var latest_overall: float = float(latest.get("overall", 0.0))
	var latest_lbl: Label = Label.new()
	latest_lbl.text = "%s: %d%%" % [tr("DASHBOARD_LATEST_SCORE"), int(latest_overall)]
	if tm:
		var latest_color: String = "accent_green" if latest_overall >= 70.0 else ("accent_yellow" if latest_overall >= PASS_THRESHOLD else "accent_red")
		tm.style_label(latest_lbl, "body_small", latest_color)
	stats_vbox.add_child(latest_lbl)

	# Trend per axis
	if hm and hm.has_method("get_improvement"):
		var sep: HSeparator = HSeparator.new()
		stats_vbox.add_child(sep)

		for axis: String in AXES:
			var improvement: Dictionary = hm.get_improvement(_selected_scenario, axis)
			var trend: String = improvement.get("trend", "STABLE")
			var arrow: String = _trend_to_arrow(trend)
			var trend_label: String = _trend_to_label(trend)

			var trend_row: HBoxContainer = HBoxContainer.new()
			trend_row.add_theme_constant_override("separation", 8)

			var axis_name: Label = Label.new()
			axis_name.text = AXIS_LABELS.get(axis, axis)
			axis_name.custom_minimum_size.x = 140
			if tm:
				tm.style_label(axis_name, "body_small", "text_secondary")
			trend_row.add_child(axis_name)

			var trend_lbl: Label = Label.new()
			trend_lbl.text = "%s %s" % [arrow, trend_label]
			if tm:
				var trend_color: String = "accent_green" if trend == "IMPROVING" else ("accent_red" if trend == "DECLINING" else "text_secondary")
				tm.style_label(trend_lbl, "body_small", trend_color)
			trend_row.add_child(trend_lbl)

			stats_vbox.add_child(trend_row)


## -- Session History Table (Scenario Breakdown) ---------------------------

func _add_session_history_table(container: VBoxContainer, history: Array) -> void:
	# Table header
	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	container.add_child(header)

	var col_names: Array[String] = [
		"Date",
		tr("DASHBOARD_OVERALL_SCORE"),
		tr("AXIS_TRIAGE_SPEED"),
		tr("AXIS_PROTOCOL_ACCURACY"),
		tr("AXIS_DECISION_QUALITY"),
		tr("AXIS_EQUIPMENT_HANDLING"),
		tr("AXIS_PATIENT_OUTCOME"),
		"Pass/Fail",
	]
	var col_widths: Array[int] = [140, 60, 60, 60, 60, 70, 60, 60]

	for i: int in col_names.size():
		var lbl: Label = Label.new()
		lbl.text = col_names[i]
		lbl.custom_minimum_size.x = col_widths[i]
		if tm:
			tm.style_label(lbl, "label", "text_secondary")
		else:
			lbl.add_theme_font_size_override("font_size", 12)
			lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		header.add_child(lbl)

	# Data rows
	for entry: Dictionary in history:
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		container.add_child(row)

		var overall: float = float(entry.get("overall", 0.0))

		# Date
		var date_lbl: Label = Label.new()
		date_lbl.text = entry.get("date", "")
		date_lbl.custom_minimum_size.x = 140
		if tm:
			tm.style_label(date_lbl, "body_small", "text_secondary")
		row.add_child(date_lbl)

		# Overall
		var overall_lbl: Label = Label.new()
		overall_lbl.text = "%d" % int(overall)
		overall_lbl.custom_minimum_size.x = 60
		if tm:
			var c_key: String = "accent_green" if overall >= PASS_THRESHOLD else "accent_red"
			tm.style_label(overall_lbl, "body_small", c_key)
		row.add_child(overall_lbl)

		# Per-axis scores
		for axis: String in AXES:
			var score: float = float(entry.get(axis, 0.0))
			var axis_lbl: Label = Label.new()
			axis_lbl.text = "%d" % int(score)
			axis_lbl.custom_minimum_size.x = 60
			if tm:
				var c_key: String = "accent_green" if score >= 70.0 else ("accent_yellow" if score >= PASS_THRESHOLD else "accent_red")
				tm.style_label(axis_lbl, "label", c_key)
			row.add_child(axis_lbl)

		# Pass/Fail badge
		var status_lbl: Label = Label.new()
		status_lbl.text = tr("DEBRIEF_PASS") if overall >= PASS_THRESHOLD else tr("DEBRIEF_FAIL")
		status_lbl.custom_minimum_size.x = 60
		if tm:
			var c_key: String = "accent_green" if overall >= PASS_THRESHOLD else "accent_red"
			tm.style_label(status_lbl, "body_small", c_key)
		row.add_child(status_lbl)


## -- Data Computation -----------------------------------------------------

func _compute_personal_averages(history: Array) -> Dictionary:
	var totals: Dictionary = {}
	for axis: String in AXES:
		totals[axis] = 0.0

	for entry: Dictionary in history:
		for axis: String in AXES:
			totals[axis] += float(entry.get(axis, 0.0))

	var count: float = maxf(float(history.size()), 1.0)
	var averages: Dictionary = {}
	for axis: String in AXES:
		averages[axis] = totals[axis] / count

	return averages


## -- Trend Helpers --------------------------------------------------------

## Get a trend arrow for a specific axis across all scenarios.
## Uses the first available scenario that has history.
func _get_overall_trend_arrow(axis: String, all_history: Array) -> String:
	if not hm or not hm.has_method("get_scenario_ids"):
		return ""

	# Aggregate trend across scenarios that have data
	var scenario_ids: Array = hm.get_scenario_ids()
	var improving_count: int = 0
	var declining_count: int = 0
	var total_count: int = 0

	for sid: String in scenario_ids:
		if hm.has_method("get_improvement"):
			var improvement: Dictionary = hm.get_improvement(sid, axis)
			var trend: String = improvement.get("trend", "STABLE")
			total_count += 1
			if trend == "IMPROVING":
				improving_count += 1
			elif trend == "DECLINING":
				declining_count += 1

	if total_count == 0:
		return ""
	if improving_count > declining_count:
		return _trend_to_arrow("IMPROVING")
	elif declining_count > improving_count:
		return _trend_to_arrow("DECLINING")
	return _trend_to_arrow("STABLE")


func _trend_to_arrow(trend: String) -> String:
	match trend:
		"IMPROVING":
			return "^"
		"DECLINING":
			return "v"
		_:
			return "->"


func _trend_to_label(trend: String) -> String:
	match trend:
		"IMPROVING":
			return tr("DASHBOARD_TREND_UP")
		"DECLINING":
			return tr("DASHBOARD_TREND_DOWN")
		_:
			return tr("DASHBOARD_TREND_STABLE")


## -- Export Handlers ------------------------------------------------------

func _on_export_all_csv() -> void:
	if not _exporter:
		return
	DirAccess.make_dir_recursive_absolute("user://exports/")
	_exporter.export_csv("user://exports/aeromedica_all.csv")


func _on_export_all_json() -> void:
	if not _exporter:
		return
	DirAccess.make_dir_recursive_absolute("user://exports/")
	_exporter.export_json("user://exports/aeromedica_all.json")


func _on_export_scenario_csv() -> void:
	if not _exporter:
		return
	DirAccess.make_dir_recursive_absolute("user://exports/")
	_exporter.export_csv("user://exports/aeromedica_%s.csv" % _selected_scenario, _selected_scenario)


func _on_export_scenario_json() -> void:
	if not _exporter:
		return
	DirAccess.make_dir_recursive_absolute("user://exports/")
	_exporter.export_json("user://exports/aeromedica_%s.json" % _selected_scenario, _selected_scenario)


## -- Empty State ----------------------------------------------------------

func _add_empty_state(container: VBoxContainer, message: String) -> void:
	var card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(card)
	container.add_child(card)

	var lbl: Label = Label.new()
	lbl.text = message
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if tm:
		tm.style_label(lbl, "body", "text_muted")
	else:
		lbl.add_theme_font_size_override("font_size", 16)
		lbl.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6))
	card.add_child(lbl)


## -- Utility --------------------------------------------------------------

func _get_scenario_display_name(scenario_id: String) -> String:
	for scenario: Dictionary in SCENARIOS:
		if scenario["id"] == scenario_id:
			return scenario["label"]
	# Fallback: clean up the ID
	return scenario_id.replace("_", " ").capitalize()


func _clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()


func _create_radar_chart() -> Control:
	var radar_scene: Resource = load("res://scenes/ui/dashboard/RadarChart.tscn")
	if radar_scene:
		return radar_scene.instantiate()

	var radar_script: Resource = load("res://scripts/ui/radar_chart.gd")
	if radar_script:
		var chart: Control = Control.new()
		chart.set_script(radar_script)
		return chart

	# Fallback: bare Control (no chart rendering)
	return Control.new()


func _create_line_chart() -> Control:
	var line_scene: Resource = load("res://scenes/ui/dashboard/LineChart.tscn")
	if line_scene:
		return line_scene.instantiate()

	var line_script: Resource = load("res://scripts/ui/line_chart.gd")
	if line_script:
		var chart: Control = Control.new()
		chart.set_script(line_script)
		return chart

	# Fallback: bare Control (no chart rendering)
	return Control.new()


func _on_back_pressed() -> void:
	back_pressed.emit()
	visible = false
	# Navigate back to main menu if loaded as standalone scene
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene("res://scenes/main/MainMenu.tscn")
