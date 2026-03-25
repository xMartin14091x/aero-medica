## MainMenu — Dashboard-style title screen with ThemeMedical integration.
## Full-screen branded layout with animated navigation and live status bar.
extends Control

signal tutorial_requested
signal scenario_select_requested
signal dashboard_requested
signal settings_requested
signal quit_requested

## Theme singleton reference.
@onready var _theme: Node = get_node_or_null("/root/ThemeMedical")

## UI references — persistent across re-themes.
var _bg: ColorRect = null
var _gradient_overlay: TextureRect = null
var _logo_texture: TextureRect = null
var _title_label: Label = null
var _subtitle_label: Label = null
var _button_container: VBoxContainer = null
var _status_bar: HBoxContainer = null
var _version_label: Label = null
var _ollama_dot: ColorRect = null
var _ollama_label: Label = null
var _lang_label: Label = null
var _copyright_label: Label = null
var _quit_dialog: Window = null
var _quit_panel: PanelContainer = null
var _quit_title: Label = null
var _quit_msg: Label = null
var _quit_confirm_btn: Button = null
var _quit_cancel_btn: Button = null

## Button data: [translation_key, signal_name, prefix]
const MENU_ITEMS := [
	["MENU_START_TUTORIAL", "tutorial_requested", "> "],
	["MENU_SELECT_SCENARIO", "scenario_select_requested", "> "],
	["MENU_DASHBOARD", "dashboard_requested", "> "],
	["MENU_SETTINGS", "settings_requested", "> "],
	["MENU_QUIT", "quit_requested", ""],
]

const LOGO_PATH := "res://assets/ui/logo.png"
const VERSION_STRING := "INDEV v1.0.1"


func _ready() -> void:
	_build_ui()
	_apply_theme()
	_animate_entry()
	_connect_game_manager()

	# Locale change listener
	var loc_mgr: Node = get_node_or_null("/root/LocalisationManager")
	if loc_mgr and loc_mgr.has_signal("locale_changed"):
		loc_mgr.locale_changed.connect(_on_locale_changed)

	# Theme change listener
	if _theme and _theme.has_signal("theme_changed"):
		_theme.theme_changed.connect(_on_theme_changed)

	# Refresh Ollama status periodically
	_update_ollama_status()


## ---- BUILD UI STRUCTURE ------------------------------------------------

func _build_ui() -> void:
	# -- Full-screen background
	_bg = ColorRect.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	# -- Gradient overlay: top-dark to bottom-lighter via GradientTexture2D
	_gradient_overlay = TextureRect.new()
	_gradient_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_gradient_overlay.stretch_mode = TextureRect.STRETCH_SCALE
	_gradient_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var grad := GradientTexture2D.new()
	var g := Gradient.new()
	g.set_color(0, Color(0.0, 0.0, 0.0, 0.35))
	g.set_color(1, Color(0.0, 0.0, 0.0, 0.0))
	g.set_offset(0, 0.0)
	g.set_offset(1, 1.0)
	grad.gradient = g
	grad.fill_from = Vector2(0.5, 0.0)
	grad.fill_to = Vector2(0.5, 1.0)
	grad.width = 4
	grad.height = 256
	_gradient_overlay.texture = grad
	add_child(_gradient_overlay)

	# -- Main content column (centered vertically, fixed width)
	var outer_margin := MarginContainer.new()
	outer_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	outer_margin.add_theme_constant_override("margin_left", 0)
	outer_margin.add_theme_constant_override("margin_right", 0)
	outer_margin.add_theme_constant_override("margin_top", 0)
	outer_margin.add_theme_constant_override("margin_bottom", 0)
	add_child(outer_margin)

	var center_vbox := VBoxContainer.new()
	center_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	center_vbox.add_theme_constant_override("separation", 0)
	outer_margin.add_child(center_vbox)

	# Flexible top spacer
	var top_spacer := Control.new()
	top_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	top_spacer.size_flags_stretch_ratio = 1.2
	center_vbox.add_child(top_spacer)

	# -- Logo area
	var logo_container := CenterContainer.new()
	center_vbox.add_child(logo_container)
	_build_logo(logo_container)

	# -- Spacer between logo and subtitle
	var logo_spacer := Control.new()
	logo_spacer.custom_minimum_size = Vector2(0, 8)
	center_vbox.add_child(logo_spacer)

	# -- Subtitle
	_subtitle_label = Label.new()
	_subtitle_label.text = tr("GAME_SUBTITLE")
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_vbox.add_child(_subtitle_label)

	# -- Spacer between subtitle and buttons
	var btn_spacer := Control.new()
	btn_spacer.custom_minimum_size = Vector2(0, 48)
	center_vbox.add_child(btn_spacer)

	# -- Button container (centered)
	var btn_center := CenterContainer.new()
	center_vbox.add_child(btn_center)

	_button_container = VBoxContainer.new()
	_button_container.add_theme_constant_override("separation", 10)
	btn_center.add_child(_button_container)

	# Create menu buttons
	for item in MENU_ITEMS:
		var btn := Button.new()
		btn.text = item[2] + tr(item[0])
		btn.custom_minimum_size = Vector2(360, 56)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.set_meta("tr_key", item[0])
		btn.set_meta("prefix", item[2])
		btn.set_meta("signal_name", item[1])
		btn.pressed.connect(_on_menu_button_pressed.bind(item[1]))
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		# Start invisible for entry animation
		btn.modulate.a = 0.0
		_button_container.add_child(btn)

	# Flexible bottom spacer
	var bottom_spacer := Control.new()
	bottom_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	bottom_spacer.size_flags_stretch_ratio = 1.8
	center_vbox.add_child(bottom_spacer)

	# -- Status bar (pinned to bottom)
	_build_status_bar()

	# -- Quit dialog (custom themed)
	_build_quit_dialog()


func _build_logo(parent: Control) -> void:
	# Try loading logo texture
	if ResourceLoader.exists(LOGO_PATH):
		_logo_texture = TextureRect.new()
		_logo_texture.texture = load(LOGO_PATH)
		_logo_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		_logo_texture.custom_minimum_size = Vector2(320, 80)
		parent.add_child(_logo_texture)
		# Title label hidden when logo exists
		_title_label = null
	else:
		# Fallback: styled text title
		_title_label = Label.new()
		_title_label.text = "AeroMedica"
		_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_title_label.add_theme_font_size_override("font_size", 48)
		parent.add_child(_title_label)
		_logo_texture = null


func _build_status_bar() -> void:
	var bar_margin := MarginContainer.new()
	bar_margin.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	bar_margin.offset_top = -40
	bar_margin.add_theme_constant_override("margin_left", 24)
	bar_margin.add_theme_constant_override("margin_right", 24)
	bar_margin.add_theme_constant_override("margin_bottom", 12)
	add_child(bar_margin)

	_status_bar = HBoxContainer.new()
	_status_bar.add_theme_constant_override("separation", 24)
	_status_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	bar_margin.add_child(_status_bar)

	# Version
	_version_label = Label.new()
	_version_label.text = VERSION_STRING
	_status_bar.add_child(_version_label)

	# Separator
	_status_bar.add_child(_make_status_separator())

	# Ollama status: dot + label
	var ollama_box := HBoxContainer.new()
	ollama_box.add_theme_constant_override("separation", 6)
	_status_bar.add_child(ollama_box)

	# Green/red dot via small ColorRect
	var dot_center := CenterContainer.new()
	ollama_box.add_child(dot_center)
	_ollama_dot = ColorRect.new()
	_ollama_dot.custom_minimum_size = Vector2(8, 8)
	dot_center.add_child(_ollama_dot)

	_ollama_label = Label.new()
	_ollama_label.text = "AI Offline"
	ollama_box.add_child(_ollama_label)

	# Separator
	_status_bar.add_child(_make_status_separator())

	# Language indicator
	_lang_label = Label.new()
	_lang_label.text = "TH/EN"
	_status_bar.add_child(_lang_label)

	# Separator
	_status_bar.add_child(_make_status_separator())

	# Copyright
	_copyright_label = Label.new()
	_copyright_label.text = "© 2026"
	_status_bar.add_child(_copyright_label)


func _make_status_separator() -> Label:
	var sep := Label.new()
	sep.text = "|"
	sep.add_theme_font_size_override("font_size", 11)
	sep.set_meta("is_separator", true)
	return sep


func _build_quit_dialog() -> void:
	_quit_dialog = Window.new()
	_quit_dialog.title = ""
	_quit_dialog.unresizable = true
	_quit_dialog.borderless = true
	_quit_dialog.transparent = true
	_quit_dialog.size = Vector2i(420, 220)
	_quit_dialog.transient = true
	_quit_dialog.exclusive = true
	add_child(_quit_dialog)

	# Dark overlay background inside the Window
	var overlay_bg := ColorRect.new()
	overlay_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_bg.color = Color(0.0, 0.0, 0.0, 0.5)
	_quit_dialog.add_child(overlay_bg)

	# Card panel centered
	var card_center := CenterContainer.new()
	card_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_quit_dialog.add_child(card_center)

	_quit_panel = PanelContainer.new()
	_quit_panel.custom_minimum_size = Vector2(380, 180)
	card_center.add_child(_quit_panel)

	var card_vbox := VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 16)
	card_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_quit_panel.add_child(card_vbox)

	# Title
	_quit_title = Label.new()
	_quit_title.text = tr("QUIT_CONFIRM_TITLE")
	_quit_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card_vbox.add_child(_quit_title)

	# Message
	_quit_msg = Label.new()
	_quit_msg.text = tr("QUIT_CONFIRM_MSG")
	_quit_msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_quit_msg.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	card_vbox.add_child(_quit_msg)

	# Spacer
	var dialog_spacer := Control.new()
	dialog_spacer.custom_minimum_size = Vector2(0, 4)
	card_vbox.add_child(dialog_spacer)

	# Button row
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 12)
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	card_vbox.add_child(btn_row)

	_quit_cancel_btn = Button.new()
	_quit_cancel_btn.text = tr("MENU_CANCEL")
	_quit_cancel_btn.custom_minimum_size = Vector2(140, 44)
	_quit_cancel_btn.pressed.connect(_on_quit_cancel)
	btn_row.add_child(_quit_cancel_btn)

	_quit_confirm_btn = Button.new()
	_quit_confirm_btn.text = tr("MENU_CONFIRM")
	_quit_confirm_btn.custom_minimum_size = Vector2(140, 44)
	_quit_confirm_btn.pressed.connect(_on_quit_confirmed)
	btn_row.add_child(_quit_confirm_btn)


## ---- THEME APPLICATION ------------------------------------------------

func _apply_theme() -> void:
	if not _theme:
		return

	# Background
	_bg.color = _theme.c("bg_main")

	# Title label (fallback mode)
	if _title_label:
		_theme.style_label(_title_label, "title_large", "accent_blue")
		_title_label.add_theme_font_size_override("font_size", 48)

	# Subtitle
	if _subtitle_label:
		_theme.style_label(_subtitle_label, "body", "text_secondary")

	# Menu buttons
	if _button_container:
		for btn in _button_container.get_children():
			if btn is Button:
				_theme.style_button(btn, "large")
				btn.custom_minimum_size = Vector2(360, 56)
				btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
				# Quit button gets red text
				if btn.has_meta("signal_name") and btn.get_meta("signal_name") == "quit_requested":
					btn.add_theme_color_override("font_color", _theme.c("accent_red"))
					btn.add_theme_color_override("font_hover_color", _theme.c("accent_red"))

	# Status bar labels
	if _version_label:
		_theme.style_label(_version_label, "caption", "text_muted")
	if _ollama_label:
		_theme.style_label(_ollama_label, "caption", "text_muted")
	if _lang_label:
		_theme.style_label(_lang_label, "caption", "text_muted")
	if _copyright_label:
		_theme.style_label(_copyright_label, "caption", "text_muted")

	# Status bar separators
	if _status_bar:
		for child in _status_bar.get_children():
			if child is Label and child.has_meta("is_separator"):
				child.add_theme_color_override("font_color", _theme.c("text_muted"))

	# Ollama dot color
	_update_ollama_status()

	# Quit dialog theming
	if _quit_panel:
		_theme.style_panel(_quit_panel, "normal")
	if _quit_title:
		_theme.style_label(_quit_title, "title", "text_primary")
	if _quit_msg:
		_theme.style_label(_quit_msg, "body", "text_secondary")
	if _quit_cancel_btn:
		_theme.style_button(_quit_cancel_btn, "normal")
	if _quit_confirm_btn:
		_theme.style_button(_quit_confirm_btn, "normal")
		_quit_confirm_btn.add_theme_color_override("font_color", _theme.c("accent_red"))
		_quit_confirm_btn.add_theme_color_override("font_hover_color", _theme.c("accent_red"))


## ---- ENTRY ANIMATION --------------------------------------------------

func _animate_entry() -> void:
	if not _button_container:
		return
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	var buttons := _button_container.get_children()
	for i in range(buttons.size()):
		var btn: Button = buttons[i]
		btn.modulate.a = 0.0
		btn.position.x = -20.0
		tween.tween_property(btn, "modulate:a", 1.0, 0.25).set_delay(0.1 * i)
		tween.parallel().tween_property(btn, "position:x", 0.0, 0.25).set_delay(0.1 * i)


## ---- OLLAMA STATUS ----------------------------------------------------

func _update_ollama_status() -> void:
	var client: Node = get_node_or_null("/root/OllamaDialogueClient")
	var is_online := false
	if client and "ollama_available" in client:
		is_online = client.ollama_available

	if _ollama_dot:
		if _theme:
			_ollama_dot.color = _theme.c("accent_green") if is_online else _theme.c("accent_red")
		else:
			_ollama_dot.color = Color.GREEN if is_online else Color.RED
	if _ollama_label:
		_ollama_label.text = "AI Online" if is_online else "AI Offline"


## ---- SIGNAL HANDLERS --------------------------------------------------

func _on_menu_button_pressed(signal_name: String) -> void:
	_play_click_sound()

	match signal_name:
		"tutorial_requested":
			tutorial_requested.emit()
			var gm: Node = get_node_or_null("/root/GameManager")
			if gm and gm.has_method("change_scene"):
				gm.change_scene("res://scenes/gameplay/Tutorial.tscn")
		"scenario_select_requested":
			scenario_select_requested.emit()
			var gm: Node = get_node_or_null("/root/GameManager")
			if gm and gm.has_method("change_scene"):
				gm.change_scene("res://scenes/main/ScenarioSelect.tscn")
		"dashboard_requested":
			dashboard_requested.emit()
			var gm: Node = get_node_or_null("/root/GameManager")
			if gm and gm.has_method("change_scene"):
				gm.change_scene("res://scenes/ui/dashboard/InstructorDashboard.tscn")
		"settings_requested":
			settings_requested.emit()
			var gm: Node = get_node_or_null("/root/GameManager")
			if gm and gm.has_method("change_scene"):
				gm.change_scene("res://scenes/main/Settings.tscn")
		"quit_requested":
			_show_quit_dialog()


func _show_quit_dialog() -> void:
	if _quit_dialog:
		_quit_dialog.popup_centered()


func _on_quit_confirmed() -> void:
	get_tree().quit()


func _on_quit_cancel() -> void:
	if _quit_dialog:
		_quit_dialog.hide()


func _on_button_hover(_btn: Button) -> void:
	_play_click_sound()


func _on_theme_changed(_mode: String) -> void:
	_apply_theme()


func _on_locale_changed(_locale: String) -> void:
	_update_texts()


## ---- TEXT UPDATES ------------------------------------------------------

func _update_texts() -> void:
	if _title_label:
		_title_label.text = "AeroMedica"
	if _subtitle_label:
		_subtitle_label.text = tr("GAME_SUBTITLE")
	if _quit_title:
		_quit_title.text = tr("QUIT_CONFIRM_TITLE")
	if _quit_msg:
		_quit_msg.text = tr("QUIT_CONFIRM_MSG")
	if _quit_cancel_btn:
		_quit_cancel_btn.text = tr("MENU_CANCEL")
	if _quit_confirm_btn:
		_quit_confirm_btn.text = tr("MENU_CONFIRM")

	if _button_container:
		for btn in _button_container.get_children():
			if btn is Button and btn.has_meta("tr_key"):
				var prefix: String = btn.get_meta("prefix") if btn.has_meta("prefix") else ""
				btn.text = prefix + tr(btn.get_meta("tr_key"))


## ---- UTILITIES ---------------------------------------------------------

func _play_click_sound() -> void:
	var scene := get_tree().current_scene if get_tree() else null
	if not scene:
		return
	var audio: Node = _find_node_by_method(scene, "play_ui_click")
	if audio:
		audio.play_ui_click()


func _connect_game_manager() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("set_state"):
		gm.set_state(0)


func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null
