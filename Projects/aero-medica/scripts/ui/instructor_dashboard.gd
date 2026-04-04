## InstructorDashboard — 3-tab dashboard: My Performance, Class Overview, Scenario Breakdown.
## Reads personal history from HistoryManager autoload and mock cohort data for B2B demo.
## Fully styled with ThemeMedical. Preserves existing radar chart and student table logic.
extends Control

## Emitted when user clicks a student row.
signal student_selected(student_data: Dictionary)

## Emitted when user wants to go back.
signal back_pressed()

## Pass threshold.
const PASS_THRESHOLD := 60.0

## Axis keys + display names.
const AXES: Array[String] = ["triage_speed", "protocol_accuracy", "decision_quality", "equipment_handling", "patient_outcome"]
var AXIS_LABELS: Dictionary = {
	"triage_speed": tr("AXIS_TRIAGE_SPEED"),
	"protocol_accuracy": tr("AXIS_PROTOCOL_ACCURACY"),
	"decision_quality": tr("AXIS_DECISION_QUALITY"),
	"equipment_handling": tr("AXIS_EQUIPMENT_HANDLING"),
	"patient_outcome": tr("AXIS_PATIENT_OUTCOME"),
}

## Scenario definitions for Tab 3 pills.
const SCENARIOS: Array[Dictionary] = [
	{"id": "tutorial_01", "label": "Tutorial"},
	{"id": "rta_intersection_01", "label": "RTA"},
	{"id": "cardiac_arrest_01", "label": "Cardiac"},
	{"id": "mci_market_01", "label": "MCI"},
	{"id": "building_fire_01", "label": "Fire"},
]

## Tab identifiers.
const TAB_MY_PERFORMANCE := "my_performance"
const TAB_CLASS_OVERVIEW := "class_overview"
const TAB_SCENARIO_BREAKDOWN := "scenario_breakdown"

## ── Internal State ──────────────────────────────────────────────
var _dash_tabs: Dictionary = {}       # name -> Control (tab content container)
var _dash_tab_btns: Dictionary = {}   # name -> Button (tab pill)
var _current_dash_tab: String = TAB_MY_PERFORMANCE

var _selected_scenario: String = "tutorial_01"
var _scenario_pills: Dictionary = {}  # id -> Button

## Mock student data for demo.
var _students: Array = []

## ThemeMedical reference (resolved at _ready).
var tm: Node = null

## HistoryManager reference (resolved at _ready).
var hm: Node = null

## UI references.
var _background: ColorRect = null
var _outer_vbox: VBoxContainer = null
var _tab_bar: HBoxContainer = null
var _tab_content_parent: Control = null

## Scenario breakdown sub-references for rebuild.
var _scenario_radar: Control = null
var _scenario_table_container: VBoxContainer = null
var _scenario_stats_container: VBoxContainer = null


func _ready() -> void:
	tm = get_node_or_null("/root/ThemeMedical")
	hm = get_node_or_null("/root/HistoryManager")
	_generate_mock_students()
	_build_ui()
	_auto_show.call_deferred()


func _auto_show() -> void:
	if self == get_tree().current_scene:
		show_dashboard()
	else:
		visible = false


## ── Public API ──────────────────────────────────────────────────

## Show dashboard. If students_data provided, uses it; otherwise uses mock.
func show_dashboard(students_data: Array = []) -> void:
	if not students_data.is_empty():
		_students = students_data
	else:
		_inject_real_session_data()
	visible = true
	_populate_all_tabs()
	_switch_tab(_current_dash_tab)


## ── UI Construction ─────────────────────────────────────────────

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
	title.text = tr("DASHBOARD_INSTRUCTOR")
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
	_create_tab_button(TAB_CLASS_OVERVIEW, tr("DASHBOARD_CLASS_OVERVIEW"))
	_create_tab_button(TAB_SCENARIO_BREAKDOWN, tr("DASHBOARD_SCENARIO_BREAKDOWN"))

	# Tab content area (holds all 3 tab containers, only 1 visible at a time)
	_tab_content_parent = Control.new()
	_tab_content_parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tab_content_parent.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_outer_vbox.add_child(_tab_content_parent)

	# Create tab containers
	_dash_tabs[TAB_MY_PERFORMANCE] = _create_tab_scroll_container()
	_dash_tabs[TAB_CLASS_OVERVIEW] = _create_tab_scroll_container()
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


## ── Tab Switching ───────────────────────────────────────────────

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


## ── Populate All Tabs ───────────────────────────────────────────

func _populate_all_tabs() -> void:
	_populate_my_performance()
	_populate_class_overview()
	_populate_scenario_breakdown()


## ── Tab 1: My Performance ───────────────────────────────────────

func _populate_my_performance() -> void:
	var scroll: ScrollContainer = _dash_tabs[TAB_MY_PERFORMANCE]
	_clear_children(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)

	# Pull personal history from HistoryManager
	var all_history: Array = []
	if hm and hm.has_method("get_all_history"):
		all_history = hm.get_all_history()

	if all_history.is_empty():
		_add_empty_state(content, "No sessions recorded yet. Complete a scenario to see your performance here.")
		return

	# Two-column layout: radar (40%) | sessions (60%)
	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(columns)

	# ── Left Column: Personal Radar + Score ──
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

	# Best + Weakest axis callouts
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

	var best_lbl: Label = Label.new()
	best_lbl.text = "Best: %s (%d%%)" % [AXIS_LABELS.get(best_axis, best_axis), int(best_val)]
	if tm:
		tm.style_label(best_lbl, "body", "accent_green")
	callout_vbox.add_child(best_lbl)

	var weak_lbl: Label = Label.new()
	weak_lbl.text = "Weakest: %s (%d%%)" % [AXIS_LABELS.get(weak_axis, weak_axis), int(weak_val)]
	if tm:
		tm.style_label(weak_lbl, "body", "accent_red")
	callout_vbox.add_child(weak_lbl)

	# ── Right Column: Recent Sessions ──
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
	for i in display_count:
		var entry: Dictionary = all_history[i]
		_add_session_card(sessions_list, entry)


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


## ── Tab 2: Class Overview ───────────────────────────────────────

func _populate_class_overview() -> void:
	var scroll: ScrollContainer = _dash_tabs[TAB_CLASS_OVERVIEW]
	_clear_children(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 16)
	scroll.add_child(content)

	if _students.is_empty():
		_add_empty_state(content, "No student data available.")
		return

	# ── Summary stat cards row ──
	_add_summary_cards(content)

	# ── Two columns: class radar + weakest axis ──
	var columns: HBoxContainer = HBoxContainer.new()
	columns.add_theme_constant_override("separation", 24)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(columns)

	# Left: class average radar chart
	var radar_card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(radar_card)
	radar_card.custom_minimum_size = Vector2(340, 360)
	columns.add_child(radar_card)

	var radar_vbox: VBoxContainer = VBoxContainer.new()
	radar_vbox.add_theme_constant_override("separation", 8)
	radar_card.add_child(radar_vbox)

	var radar_title: Label = Label.new()
	radar_title.text = tr("DASHBOARD_CLASS_AVG_PERF")
	if tm:
		tm.style_label(radar_title, "subtitle")
	else:
		radar_title.add_theme_font_size_override("font_size", 18)
	radar_vbox.add_child(radar_title)

	var class_radar: Control = _create_radar_chart()
	class_radar.custom_minimum_size = Vector2(300, 300)
	radar_vbox.add_child(class_radar)

	var avg_scores: Dictionary = _calculate_averages()
	class_radar.set_scores(avg_scores)

	# Right: weakest axis + all axis averages
	var stats_card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(stats_card)
	stats_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(stats_card)

	var stats_vbox: VBoxContainer = VBoxContainer.new()
	stats_vbox.add_theme_constant_override("separation", 10)
	stats_card.add_child(stats_vbox)

	_add_weakest_axis(stats_vbox, avg_scores)
	_add_all_axis_averages(stats_vbox, avg_scores)

	# ── Student Performance table ──
	var table_header_lbl: Label = Label.new()
	table_header_lbl.text = tr("DASHBOARD_STUDENT_PERF")
	if tm:
		tm.style_label(table_header_lbl, "subtitle")
	else:
		table_header_lbl.add_theme_font_size_override("font_size", 20)
	content.add_child(table_header_lbl)

	_add_student_table(content, _students)


## ── Tab 3: Scenario Breakdown ───────────────────────────────────

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

	# Left: scenario-specific radar
	var radar_card: PanelContainer = PanelContainer.new()
	if tm:
		tm.style_panel(radar_card)
	radar_card.custom_minimum_size = Vector2(340, 360)
	columns.add_child(radar_card)

	var radar_inner: VBoxContainer = VBoxContainer.new()
	radar_inner.add_theme_constant_override("separation", 8)
	radar_card.add_child(radar_inner)

	var radar_title: Label = Label.new()
	radar_title.text = tr("DASHBOARD_SCENARIO_AVG")
	if tm:
		tm.style_label(radar_title, "subtitle")
	radar_inner.add_child(radar_title)

	_scenario_radar = _create_radar_chart()
	_scenario_radar.custom_minimum_size = Vector2(300, 300)
	radar_inner.add_child(_scenario_radar)

	# Stats below radar
	_scenario_stats_container = VBoxContainer.new()
	_scenario_stats_container.add_theme_constant_override("separation", 8)
	radar_inner.add_child(_scenario_stats_container)

	# Right: filtered student table
	var right_vbox: VBoxContainer = VBoxContainer.new()
	right_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_vbox.add_theme_constant_override("separation", 8)
	columns.add_child(right_vbox)

	var table_title: Label = Label.new()
	table_title.text = tr("DASHBOARD_STUDENT_RESULTS")
	if tm:
		tm.style_label(table_title, "subtitle")
	right_vbox.add_child(table_title)

	_scenario_table_container = VBoxContainer.new()
	_scenario_table_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_scenario_table_container.add_theme_constant_override("separation", 4)
	right_vbox.add_child(_scenario_table_container)

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

	# Filter students who have data for the selected scenario
	var filtered_students: Array = []
	for student: Dictionary in _students:
		var sid: String = student.get("scenario_id", "")
		if sid == _selected_scenario:
			filtered_students.append(student)

	# Update radar with scenario-filtered averages
	var scenario_avg: Dictionary = _calculate_averages_from(filtered_students)
	_scenario_radar.set_scores(scenario_avg)

	# Update stats
	_clear_children(_scenario_stats_container)
	if filtered_students.is_empty():
		var no_data_lbl: Label = Label.new()
		no_data_lbl.text = tr("DASHBOARD_NO_DATA_SCENARIO")
		if tm:
			tm.style_label(no_data_lbl, "body", "text_muted")
		_scenario_stats_container.add_child(no_data_lbl)
	else:
		_add_scenario_quick_stats(_scenario_stats_container, filtered_students)

	# Update table
	_clear_children(_scenario_table_container)
	if filtered_students.is_empty():
		var empty_lbl: Label = Label.new()
		empty_lbl.text = tr("DASHBOARD_NO_RESULTS_YET")
		if tm:
			tm.style_label(empty_lbl, "body", "text_muted")
		_scenario_table_container.add_child(empty_lbl)
	else:
		_add_student_table(_scenario_table_container, filtered_students)


## ── Shared UI Components ────────────────────────────────────────

func _add_summary_cards(container: VBoxContainer) -> void:
	var cards: HBoxContainer = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 12)
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.add_child(cards)

	var total: int = _students.size()
	var pass_count: int = 0
	var total_overall: float = 0.0

	for student: Dictionary in _students:
		var overall: float = float(student.get("scores", {}).get("overall", 0.0))
		total_overall += overall
		if overall >= PASS_THRESHOLD:
			pass_count += 1

	var avg_overall: float = total_overall / maxf(float(total), 1.0)
	var pass_rate: float = float(pass_count) / maxf(float(total), 1.0) * 100.0

	_add_stat_card(cards, "Total Students", str(total))
	_add_stat_card(cards, "Average Score", "%d%%" % int(avg_overall))
	_add_stat_card(cards, "Pass Rate", "%d%%" % int(pass_rate))
	_add_stat_card(cards, "Attempts", str(total))


func _add_stat_card(container: HBoxContainer, label_text: String, value: String) -> void:
	var card: PanelContainer = PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if tm:
		tm.style_panel(card)
	container.add_child(card)

	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)

	var label_lbl: Label = Label.new()
	label_lbl.text = label_text
	label_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if tm:
		tm.style_label(label_lbl, "label", "text_secondary")
	else:
		label_lbl.add_theme_font_size_override("font_size", 12)
		label_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	vbox.add_child(label_lbl)

	var val_lbl: Label = Label.new()
	val_lbl.text = value
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if tm:
		tm.style_label(val_lbl, "hero_number")
	else:
		val_lbl.add_theme_font_size_override("font_size", 32)
	vbox.add_child(val_lbl)


func _add_weakest_axis(container: VBoxContainer, avg_scores: Dictionary) -> void:
	var weakest_axis: String = ""
	var weakest_score: float = 101.0

	for axis: String in AXES:
		var score: float = float(avg_scores.get(axis, 0.0))
		if score < weakest_score:
			weakest_score = score
			weakest_axis = axis

	if weakest_axis == "":
		return

	var header: Label = Label.new()
	header.text = tr("DASHBOARD_WEAKEST_AXIS")
	if tm:
		tm.style_label(header, "subtitle")
	else:
		header.add_theme_font_size_override("font_size", 18)
	container.add_child(header)

	var highlight: Label = Label.new()
	highlight.text = "Your class struggles most with %s" % AXIS_LABELS.get(weakest_axis, weakest_axis)
	highlight.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if tm:
		tm.style_label(highlight, "body", "accent_yellow")
	else:
		highlight.add_theme_font_size_override("font_size", 16)
		highlight.add_theme_color_override("font_color", Color(1.0, 0.5, 0.2))
	container.add_child(highlight)

	var score_lbl: Label = Label.new()
	score_lbl.text = "Class average: %d%%" % int(weakest_score)
	if tm:
		var color_key: String = "accent_red" if weakest_score < PASS_THRESHOLD else "accent_yellow"
		tm.style_label(score_lbl, "body", color_key)
	container.add_child(score_lbl)


func _add_all_axis_averages(container: VBoxContainer, avg_scores: Dictionary) -> void:
	var sep: HSeparator = HSeparator.new()
	container.add_child(sep)

	var axes_header: Label = Label.new()
	axes_header.text = tr("DASHBOARD_ALL_AXES")
	if tm:
		tm.style_label(axes_header, "body")
	else:
		axes_header.add_theme_font_size_override("font_size", 16)
	container.add_child(axes_header)

	for axis: String in AXES:
		var score: float = float(avg_scores.get(axis, 0.0))
		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var name_lbl: Label = Label.new()
		name_lbl.text = AXIS_LABELS.get(axis, axis)
		name_lbl.custom_minimum_size.x = 160
		if tm:
			tm.style_label(name_lbl, "body_small", "text_secondary")
		row.add_child(name_lbl)

		var val_lbl: Label = Label.new()
		val_lbl.text = "%d%%" % int(score)
		if tm:
			var color_key: String = "accent_green" if score >= 70.0 else ("accent_yellow" if score >= PASS_THRESHOLD else "accent_red")
			tm.style_label(val_lbl, "body_small", color_key)
		row.add_child(val_lbl)

		container.add_child(row)


func _add_student_table(container: Control, students: Array) -> void:
	# Table header
	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 12)
	container.add_child(header)

	var col_names: Array[String] = [tr("DASHBOARD_TOTAL_STUDENTS"), tr("DASHBOARD_OVERALL_SCORE"), tr("AXIS_TRIAGE"), tr("AXIS_PROTOCOL_ACCURACY"), tr("AXIS_DECISION_QUALITY"), tr("AXIS_EQUIPMENT_HANDLING"), tr("AXIS_PATIENT_OUTCOME"), "Status"]
	var col_widths: Array[int] = [160, 60, 60, 60, 60, 70, 60, 60]

	for i in col_names.size():
		var lbl: Label = Label.new()
		lbl.text = col_names[i]
		lbl.custom_minimum_size.x = col_widths[i]
		if tm:
			tm.style_label(lbl, "label", "text_secondary")
		else:
			lbl.add_theme_font_size_override("font_size", 12)
			lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
		header.add_child(lbl)

	# Sort by overall score descending
	var sorted_students: Array = students.duplicate()
	sorted_students.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a.get("scores", {}).get("overall", 0.0)) > float(b.get("scores", {}).get("overall", 0.0))
	)

	# Student rows
	for student: Dictionary in sorted_students:
		var row_btn: Button = Button.new()
		row_btn.flat = true
		row_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row_btn.pressed.connect(func() -> void: student_selected.emit(student))
		container.add_child(row_btn)

		var row: HBoxContainer = HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		row_btn.add_child(row)

		var scores: Dictionary = student.get("scores", {})
		var overall: float = float(scores.get("overall", 0.0))

		# Name
		var name_lbl: Label = Label.new()
		name_lbl.text = student.get("name", "Unknown")
		name_lbl.custom_minimum_size.x = 160
		if tm:
			tm.style_label(name_lbl, "body_small")
		else:
			name_lbl.add_theme_font_size_override("font_size", 14)
		row.add_child(name_lbl)

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
			var score: float = float(scores.get(axis, 0.0))
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


func _add_scenario_quick_stats(container: VBoxContainer, students: Array) -> void:
	var total: int = students.size()
	var pass_count: int = 0
	var total_overall: float = 0.0

	for student: Dictionary in students:
		var overall: float = float(student.get("scores", {}).get("overall", 0.0))
		total_overall += overall
		if overall >= PASS_THRESHOLD:
			pass_count += 1

	var avg_overall: float = total_overall / maxf(float(total), 1.0)

	var stats_lbl: Label = Label.new()
	stats_lbl.text = "%d students | Avg: %d%% | Pass: %d/%d" % [total, int(avg_overall), pass_count, total]
	if tm:
		tm.style_label(stats_lbl, "body_small", "text_secondary")
	container.add_child(stats_lbl)


## ── Data Computation ────────────────────────────────────────────

func _calculate_averages() -> Dictionary:
	return _calculate_averages_from(_students)


func _calculate_averages_from(students: Array) -> Dictionary:
	var totals: Dictionary = {}
	for axis: String in AXES:
		totals[axis] = 0.0

	for student: Dictionary in students:
		var scores: Dictionary = student.get("scores", {})
		for axis: String in AXES:
			totals[axis] += float(scores.get(axis, 0.0))

	var count: float = maxf(float(students.size()), 1.0)
	var averages: Dictionary = {}
	for axis: String in AXES:
		averages[axis] = totals[axis] / count

	return averages


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


## ── Empty State ─────────────────────────────────────────────────

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


## ── Utility ─────────────────────────────────────────────────────

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


## ── Mock Data & Real Session Injection ──────────────────────────

func _generate_mock_students() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = 42  # Deterministic for demo

	var names: Array[String] = [
		"Somchai K.", "Nattaya P.", "Worawit S.", "Pimchanok R.", "Thanakrit L."
	]

	_students.clear()

	# Generate mock entries across multiple scenarios
	for scenario: Dictionary in SCENARIOS:
		var sid: String = scenario["id"]
		for i in names.size():
			var base_skill: float = rng.randf_range(35.0, 90.0)
			var scores: Dictionary = {}

			for axis: String in AXES:
				var variation: float = rng.randf_range(-15.0, 15.0)
				scores[axis] = clampf(base_skill + variation, 10.0, 98.0)

			# Calculate overall
			var total: float = 0.0
			for axis: String in AXES:
				total += scores[axis]
			scores["overall"] = total / AXES.size()

			_students.append({
				"name": names[i],
				"scores": scores,
				"timestamp": "28-03-2026",
				"scenario_id": sid,
			})


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

	var protocol_score: float = 50.0
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

	var scores: Dictionary = {
		"triage_speed": triage_speed_score,
		"protocol_accuracy": protocol_score,
		"decision_quality": decision_score,
		"equipment_handling": equipment_score,
		"patient_outcome": outcome_score,
	}
	var total: float = 0.0
	for axis: String in AXES:
		total += scores.get(axis, 0.0)
	scores["overall"] = total / AXES.size()

	var real_entry: Dictionary = {
		"name": "You (Last Session)",
		"scores": scores,
		"timestamp": Time.get_datetime_string_from_system(),
		"scenario_id": results.get("scenario_id", "unknown"),
	}

	# Put the real entry at the top of the list
	_students.insert(0, real_entry)


func _on_back_pressed() -> void:
	back_pressed.emit()
	visible = false
	# Navigate back to main menu if loaded as standalone scene
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene("res://scenes/main/MainMenu.tscn")
