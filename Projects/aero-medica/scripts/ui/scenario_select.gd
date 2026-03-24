## ScenarioSelect — Grid view of available scenarios with difficulty and unlock progression.
## Tutorial must be completed to unlock other scenarios.
extends Control

signal scenario_selected(scenario_id: String)

## Scenario data.
const SCENARIOS := [
	{
		"id": "tutorial",
		"name_key": "SCENARIO_TUTORIAL",
		"desc_key": "SCENARIO_TUTORIAL_DESC",
		"difficulty": 1,
		"patients": 1,
		"time_limit": 0,
		"scene_path": "res://scenes/gameplay/Tutorial.tscn",
		"always_unlocked": true,
	},
	{
		"id": "rta",
		"name_key": "SCENARIO_RTA",
		"desc_key": "SCENARIO_RTA_DESC",
		"difficulty": 2,
		"patients": 3,
		"time_limit": 600,
		"scene_path": "res://scenes/gameplay/RoadTrafficAccidentV2.tscn",
		"always_unlocked": false,
	},
	{
		"id": "cardiac",
		"name_key": "SCENARIO_CARDIAC",
		"desc_key": "SCENARIO_CARDIAC_DESC",
		"difficulty": 3,
		"patients": 1,
		"time_limit": 300,
		"scene_path": "res://scenes/gameplay/CardiacArrest.tscn",
		"always_unlocked": false,
	},
	{
		"id": "mce",
		"name_key": "SCENARIO_MCE",
		"desc_key": "SCENARIO_MCE_DESC",
		"difficulty": 5,
		"patients": 6,
		"time_limit": 900,
		"scene_path": "res://scenes/gameplay/MassCasualty.tscn",
		"always_unlocked": false,
	},
	{
		"id": "fire",
		"name_key": "SCENARIO_FIRE",
		"desc_key": "SCENARIO_FIRE_DESC",
		"difficulty": 4,
		"patients": 3,
		"time_limit": 480,
		"scene_path": "res://scenes/gameplay/BuildingFire.tscn",
		"always_unlocked": false,
	},
]

var _tutorial_completed: bool = false
var _grid_container: GridContainer = null
var _detail_panel: PanelContainer = null
var _detail_name: Label = null
var _detail_desc: Label = null
var _detail_info: Label = null
var _start_button: Button = null
var _selected_scenario: Dictionary = {}


func _ready() -> void:
	_check_tutorial_completion()
	_build_ui()

	var loc_mgr := get_node_or_null("/root/LocalisationManager")
	if loc_mgr and loc_mgr.has_signal("locale_changed"):
		loc_mgr.locale_changed.connect(_on_locale_changed)


func _check_tutorial_completion() -> void:
	# Check via HistoryManager if tutorial has been completed
	var history_mgr := get_node_or_null("/root/HistoryManager")
	if history_mgr and history_mgr.has_method("get_scenario_history"):
		var history = history_mgr.get_scenario_history("tutorial")
		_tutorial_completed = not history.is_empty()
	else:
		# Default: unlock all for demo
		_tutorial_completed = true


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.1, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main layout
	var main := VBoxContainer.new()
	main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.add_theme_constant_override("separation", 16)
	var margin_vals := [40, 40, 24, 24]
	add_child(main)

	# Header
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 16)
	main.add_child(header)

	var back_btn := Button.new()
	back_btn.text = tr("MENU_BACK")
	back_btn.custom_minimum_size = Vector2(100, 40)
	back_btn.pressed.connect(_on_back_pressed)
	header.add_child(back_btn)

	var title := Label.new()
	title.text = tr("MENU_SELECT_SCENARIO")
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	header.add_child(title)

	# Content split: grid left, detail right
	var split := HSplitContainer.new()
	split.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(split)

	# Scenario grid
	var grid_scroll := ScrollContainer.new()
	grid_scroll.custom_minimum_size = Vector2(500, 0)
	split.add_child(grid_scroll)

	_grid_container = GridContainer.new()
	_grid_container.columns = 2
	_grid_container.add_theme_constant_override("h_separation", 12)
	_grid_container.add_theme_constant_override("v_separation", 12)
	grid_scroll.add_child(_grid_container)

	# Create scenario cards
	for scenario in SCENARIOS:
		_create_scenario_card(scenario)

	# Detail panel
	_detail_panel = PanelContainer.new()
	_detail_panel.custom_minimum_size = Vector2(350, 0)
	split.add_child(_detail_panel)

	var detail_vbox := VBoxContainer.new()
	detail_vbox.add_theme_constant_override("separation", 12)
	_detail_panel.add_child(detail_vbox)

	var detail_margin := MarginContainer.new()
	detail_margin.add_theme_constant_override("margin_left", 16)
	detail_margin.add_theme_constant_override("margin_right", 16)
	detail_margin.add_theme_constant_override("margin_top", 16)
	detail_margin.add_theme_constant_override("margin_bottom", 16)
	_detail_panel.add_child(detail_margin)

	var detail_inner := VBoxContainer.new()
	detail_inner.add_theme_constant_override("separation", 12)
	detail_margin.add_child(detail_inner)

	_detail_name = Label.new()
	_detail_name.add_theme_font_size_override("font_size", 24)
	_detail_name.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	_detail_name.text = tr("MENU_SELECT_SCENARIO")
	detail_inner.add_child(_detail_name)

	_detail_desc = Label.new()
	_detail_desc.add_theme_font_size_override("font_size", 14)
	_detail_desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	_detail_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_inner.add_child(_detail_desc)

	_detail_info = Label.new()
	_detail_info.add_theme_font_size_override("font_size", 14)
	_detail_info.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
	detail_inner.add_child(_detail_info)

	_start_button = Button.new()
	_start_button.text = tr("MENU_START")
	_start_button.custom_minimum_size = Vector2(200, 48)
	_start_button.add_theme_font_size_override("font_size", 20)
	_start_button.pressed.connect(_on_start_pressed)
	_start_button.disabled = true
	detail_inner.add_child(_start_button)


func _create_scenario_card(scenario: Dictionary) -> void:
	var is_unlocked: bool = scenario.always_unlocked or _tutorial_completed

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(230, 140)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(margin)

	var inner := VBoxContainer.new()
	inner.add_theme_constant_override("separation", 6)
	margin.add_child(inner)

	# Name
	var name_label := Label.new()
	name_label.text = tr(scenario.name_key) if is_unlocked else tr("SCENARIO_LOCKED")
	name_label.add_theme_font_size_override("font_size", 18)
	var name_color := Color(0.9, 0.95, 1.0) if is_unlocked else Color(0.5, 0.5, 0.55)
	name_label.add_theme_color_override("font_color", name_color)
	inner.add_child(name_label)

	# Difficulty stars
	var stars := Label.new()
	var star_text := ""
	for i in 5:
		star_text += "*" if i < scenario.difficulty else "."
	stars.text = star_text + " (%d/5)" % scenario.difficulty
	stars.add_theme_font_size_override("font_size", 14)
	stars.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2) if is_unlocked else Color(0.4, 0.4, 0.4))
	inner.add_child(stars)

	# Patients count
	var patients := Label.new()
	patients.text = "%s: %d" % [tr("SCENARIO_PATIENTS"), scenario.patients]
	patients.add_theme_font_size_override("font_size", 12)
	patients.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75) if is_unlocked else Color(0.35, 0.35, 0.4))
	inner.add_child(patients)

	# Make card clickable
	if is_unlocked:
		var click_btn := Button.new()
		click_btn.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		click_btn.flat = true
		click_btn.modulate = Color(1, 1, 1, 0)  # Transparent button overlay
		click_btn.pressed.connect(_on_scenario_card_clicked.bind(scenario))
		card.add_child(click_btn)
	else:
		card.modulate = Color(0.5, 0.5, 0.5, 0.7)

	_grid_container.add_child(card)


func _on_scenario_card_clicked(scenario: Dictionary) -> void:
	_selected_scenario = scenario
	_detail_name.text = tr(scenario.name_key)
	_detail_desc.text = tr(scenario.desc_key)

	var time_str := ""
	if scenario.time_limit > 0:
		time_str = "%d:%02d" % [scenario.time_limit / 60, scenario.time_limit % 60]
	else:
		time_str = "--:--"

	_detail_info.text = "%s: %d\n%s: %s\n%s: %s" % [
		tr("SCENARIO_PATIENTS"), scenario.patients,
		tr("SCENARIO_TIME_LIMIT"), time_str,
		tr("SCENARIO_BEST_SCORE"), tr("SCENARIO_NONE_PLAYED"),
	]

	_start_button.disabled = false


func _on_start_pressed() -> void:
	if _selected_scenario.is_empty():
		return

	scenario_selected.emit(_selected_scenario.id)

	var gm := get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene(_selected_scenario.scene_path)


func _on_back_pressed() -> void:
	var gm := get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene("res://scenes/main/MainMenu.tscn")


func _on_locale_changed(_locale: String) -> void:
	# Rebuild cards with new locale
	if _grid_container:
		for child in _grid_container.get_children():
			child.queue_free()
		for scenario in SCENARIOS:
			_create_scenario_card.call_deferred(scenario)
