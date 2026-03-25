## ScenarioSelect -- Card-grid view of available scenarios with difficulty and unlock progression.
## Uses ThemeMedical singleton for all styling. Supports live theme switching.
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

## Theme singleton reference.
@onready var _theme: Node = get_node("/root/ThemeMedical")

var _tutorial_completed: bool = false
var _bg: ColorRect = null
var _header_bar: PanelContainer = null
var _grid_container: GridContainer = null
var _bottom_bar: PanelContainer = null
var _card_panels: Array[PanelContainer] = []


func _ready() -> void:
	_check_tutorial_completion()
	_build_ui()

	var loc_mgr := get_node_or_null("/root/LocalisationManager")
	if loc_mgr and loc_mgr.has_signal("locale_changed"):
		loc_mgr.locale_changed.connect(_on_locale_changed)

	if _theme.has_signal("theme_changed"):
		_theme.theme_changed.connect(_on_theme_changed)


func _check_tutorial_completion() -> void:
	var history_mgr := get_node_or_null("/root/HistoryManager")
	if history_mgr and history_mgr.has_method("get_scenario_history"):
		var history = history_mgr.get_scenario_history("tutorial")
		_tutorial_completed = not history.is_empty()
	else:
		_tutorial_completed = true


## ---- Full UI Build --------------------------------------------------------

func _build_ui() -> void:
	# Full-screen background
	_bg = ColorRect.new()
	_bg.color = _theme.c("bg_main")
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	# Root margin container for page padding
	var root_margin := MarginContainer.new()
	root_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_margin.add_theme_constant_override("margin_left", 48)
	root_margin.add_theme_constant_override("margin_right", 48)
	root_margin.add_theme_constant_override("margin_top", 0)
	root_margin.add_theme_constant_override("margin_bottom", 0)
	add_child(root_margin)

	# Main vertical layout: header | cards | bottom
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 0)
	root_margin.add_child(main_vbox)

	# -- Header bar --
	_header_bar = _build_header_bar()
	main_vbox.add_child(_header_bar)

	# Spacer between header and grid
	var header_spacer := Control.new()
	header_spacer.custom_minimum_size = Vector2(0, _theme.SPACING.section_gap)
	main_vbox.add_child(header_spacer)

	# -- Scrollable card grid --
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll)

	_grid_container = GridContainer.new()
	_grid_container.columns = 3
	_grid_container.add_theme_constant_override("h_separation", _theme.SPACING.card_margin * 2)
	_grid_container.add_theme_constant_override("v_separation", _theme.SPACING.card_margin * 2)
	_grid_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_grid_container)

	_card_panels.clear()
	for scenario in SCENARIOS:
		_create_scenario_card(scenario)

	# Spacer between grid and bottom
	var bottom_spacer := Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, _theme.SPACING.section_gap)
	main_vbox.add_child(bottom_spacer)

	# -- Bottom bar: best scores --
	_bottom_bar = _build_bottom_bar()
	main_vbox.add_child(_bottom_bar)


## ---- Header Bar -----------------------------------------------------------

func _build_header_bar() -> PanelContainer:
	var panel := PanelContainer.new()
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = _theme.c("bg_card")
	header_style.border_width_bottom = 1
	header_style.border_color = _theme.c("border")
	header_style.content_margin_left = 16
	header_style.content_margin_right = 16
	header_style.content_margin_top = 12
	header_style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", header_style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	panel.add_child(hbox)

	# Back button
	var back_btn := Button.new()
	back_btn.text = "< %s" % tr("MENU_BACK")
	_theme.style_button(back_btn, "small")
	back_btn.add_theme_color_override("font_color", _theme.c("accent_blue"))
	back_btn.add_theme_color_override("font_hover_color", _theme.c("text_primary"))
	back_btn.pressed.connect(_on_back_pressed)
	hbox.add_child(back_btn)

	# Flexible spacer to push title to center
	var spacer_left := Control.new()
	spacer_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer_left)

	# Title
	var title := Label.new()
	title.text = tr("MENU_SELECT_SCENARIO")
	_theme.style_label(title, "title_large", "text_primary")
	hbox.add_child(title)

	# Matching spacer for centering
	var spacer_right := Control.new()
	spacer_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(spacer_right)

	return panel


## ---- Scenario Card --------------------------------------------------------

func _create_scenario_card(scenario: Dictionary) -> void:
	var is_unlocked: bool = scenario.always_unlocked or _tutorial_completed

	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _theme.make_card())
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 180)

	if not is_unlocked:
		card.modulate.a = 0.4

	# Hover border feedback (unlocked only)
	if is_unlocked:
		card.mouse_entered.connect(_on_card_mouse_entered.bind(card))
		card.mouse_exited.connect(_on_card_mouse_exited.bind(card))

	# Card content
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", _theme.SPACING.item_gap)
	card.add_child(vbox)

	# Scenario title
	var name_label := Label.new()
	name_label.text = tr(scenario.name_key) if is_unlocked else tr("SCENARIO_LOCKED")
	_theme.style_label(name_label, "subtitle", "text_primary")
	vbox.add_child(name_label)

	# Difficulty stars (RichTextLabel for dual-color filled/empty)
	var filled := ""
	var empty := ""
	for i in 5:
		if i < scenario.difficulty:
			filled += "\u2605"
		else:
			empty += "\u2606"
	var stars_rtl := RichTextLabel.new()
	stars_rtl.bbcode_enabled = true
	stars_rtl.fit_content = true
	stars_rtl.scroll_active = false
	stars_rtl.custom_minimum_size = Vector2(0, 24)
	var filled_hex := _theme.c("accent_yellow").to_html(false)
	var empty_hex := _theme.c("text_muted").to_html(false)
	stars_rtl.text = "[color=#%s]%s[/color][color=#%s]%s[/color]" % [
		filled_hex, filled, empty_hex, empty
	]
	stars_rtl.add_theme_font_size_override("normal_font_size", _theme.FONT_SIZES.subtitle)
	vbox.add_child(stars_rtl)

	# Patient count
	var patients_label := Label.new()
	patients_label.text = "%d %s" % [scenario.patients, tr("SCENARIO_PATIENTS").to_lower()]
	_theme.style_label(patients_label, "body_small", "text_secondary")
	vbox.add_child(patients_label)

	# Time limit
	var time_label := Label.new()
	if scenario.time_limit > 0:
		time_label.text = "%d:%02d" % [scenario.time_limit / 60, scenario.time_limit % 60]
	else:
		time_label.text = "--:--"
	_theme.style_label(time_label, "body_small", "text_secondary")
	vbox.add_child(time_label)

	if is_unlocked:
		# Start button
		var start_btn := Button.new()
		start_btn.text = tr("MENU_START")
		_theme.style_button(start_btn, "small")
		start_btn.add_theme_color_override("font_color", _theme.c("accent_blue"))
		start_btn.add_theme_color_override("font_hover_color", Color.WHITE)
		start_btn.pressed.connect(_on_start_scenario.bind(scenario))
		vbox.add_child(start_btn)
	else:
		# LOCKED overlay label
		var locked_label := Label.new()
		locked_label.text = tr("SCENARIO_LOCKED")
		_theme.style_label(locked_label, "subtitle", "text_muted")
		locked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(locked_label)

	_card_panels.append(card)
	_grid_container.add_child(card)


## ---- Bottom Bar: Best Scores ---------------------------------------------

func _build_bottom_bar() -> PanelContainer:
	var panel := PanelContainer.new()
	var bar_style := StyleBoxFlat.new()
	bar_style.bg_color = _theme.c("bg_card")
	bar_style.border_width_top = 1
	bar_style.border_color = _theme.c("border")
	bar_style.content_margin_left = 16
	bar_style.content_margin_right = 16
	bar_style.content_margin_top = 12
	bar_style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", bar_style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 32)
	panel.add_child(hbox)

	var history_mgr := get_node_or_null("/root/HistoryManager")

	for scenario in SCENARIOS:
		var is_unlocked: bool = scenario.always_unlocked or _tutorial_completed
		if not is_unlocked:
			continue

		var score_vbox := VBoxContainer.new()
		score_vbox.add_theme_constant_override("separation", 2)
		hbox.add_child(score_vbox)

		var name_lbl := Label.new()
		name_lbl.text = tr(scenario.name_key)
		_theme.style_label(name_lbl, "caption", "text_secondary")
		score_vbox.add_child(name_lbl)

		var score_lbl := Label.new()
		var best_score := _get_best_score(history_mgr, scenario.id)
		if best_score >= 0:
			score_lbl.text = "%d" % best_score
			_theme.style_label(score_lbl, "body", "accent_green")
		else:
			score_lbl.text = "--"
			_theme.style_label(score_lbl, "body", "text_muted")
		score_vbox.add_child(score_lbl)

	return panel


func _get_best_score(history_mgr: Node, scenario_id: String) -> int:
	if not history_mgr or not history_mgr.has_method("get_scenario_history"):
		return -1
	var history: Array = history_mgr.get_scenario_history(scenario_id)
	if history.is_empty():
		return -1
	var best := -1
	for entry in history:
		if entry is Dictionary and entry.has("score"):
			var s: int = entry.score
			if s > best:
				best = s
	return best


## ---- Hover Feedback -------------------------------------------------------

func _on_card_mouse_entered(card: PanelContainer) -> void:
	card.add_theme_stylebox_override("panel", _theme.make_card("active"))


func _on_card_mouse_exited(card: PanelContainer) -> void:
	card.add_theme_stylebox_override("panel", _theme.make_card())


## ---- Actions --------------------------------------------------------------

func _on_start_scenario(scenario: Dictionary) -> void:
	scenario_selected.emit(scenario.id)
	var gm := get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene(scenario.scene_path)


func _on_back_pressed() -> void:
	var gm := get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene("res://scenes/main/MainMenu.tscn")


## ---- Theme / Locale Reactivity -------------------------------------------

func _on_theme_changed(_mode: String) -> void:
	_rebuild_all()


func _on_locale_changed(_locale: String) -> void:
	_rebuild_all()


func _rebuild_all() -> void:
	# Clear all children and rebuild from scratch
	for child in get_children():
		child.queue_free()
	_card_panels.clear()
	_build_ui.call_deferred()
