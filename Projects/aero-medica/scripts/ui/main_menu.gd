## MainMenu — Title screen with navigation to all game features.
## Professional layout with AeroMedica branding and menu buttons.
extends Control

signal tutorial_requested
signal scenario_select_requested
signal dashboard_requested
signal settings_requested
signal quit_requested

## UI references.
var _title_label: Label = null
var _subtitle_label: Label = null
var _button_container: VBoxContainer = null
var _quit_dialog: AcceptDialog = null

## Button data: [translation_key, signal_name]
const MENU_ITEMS := [
	["MENU_START_TUTORIAL", "tutorial_requested"],
	["MENU_SELECT_SCENARIO", "scenario_select_requested"],
	["MENU_DASHBOARD", "dashboard_requested"],
	["MENU_SETTINGS", "settings_requested"],
	["MENU_QUIT", "quit_requested"],
]


func _ready() -> void:
	_build_ui()
	_connect_game_manager()

	# Update locale if LocalisationManager exists
	var loc_mgr: Node = get_node_or_null("/root/LocalisationManager")
	if loc_mgr and loc_mgr.has_signal("locale_changed"):
		loc_mgr.locale_changed.connect(_on_locale_changed)


func _build_ui() -> void:
	# Full-screen background
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.1, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Gradient overlay (medical blue theme)
	var gradient_bg := ColorRect.new()
	gradient_bg.color = Color(0.05, 0.12, 0.25, 0.6)
	gradient_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(gradient_bg)

	# Center container for content
	var center := VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.offset_top = -200
	center.offset_bottom = 200
	center.offset_left = -250
	center.offset_right = 250
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 12)
	add_child(center)

	# Title
	_title_label = Label.new()
	_title_label.text = tr("GAME_TITLE")
	_title_label.add_theme_font_size_override("font_size", 48)
	_title_label.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_title_label)

	# Subtitle
	_subtitle_label = Label.new()
	_subtitle_label.text = tr("GAME_SUBTITLE")
	_subtitle_label.add_theme_font_size_override("font_size", 16)
	_subtitle_label.add_theme_color_override("font_color", Color(0.6, 0.65, 0.75))
	_subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(_subtitle_label)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 40)
	center.add_child(spacer)

	# Button container
	_button_container = VBoxContainer.new()
	_button_container.add_theme_constant_override("separation", 8)
	_button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(_button_container)

	# Create menu buttons
	for item in MENU_ITEMS:
		var btn := Button.new()
		btn.text = tr(item[0])
		btn.custom_minimum_size = Vector2(300, 48)
		btn.add_theme_font_size_override("font_size", 20)
		btn.set_meta("tr_key", item[0])
		btn.set_meta("signal_name", item[1])
		btn.pressed.connect(_on_menu_button_pressed.bind(item[1]))
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		_button_container.add_child(btn)

	# Version label
	var version := Label.new()
	version.text = "INDEV v1.0.0"
	version.add_theme_font_size_override("font_size", 12)
	version.add_theme_color_override("font_color", Color(0.4, 0.4, 0.5))
	version.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	version.offset_right = -16
	version.offset_bottom = -8
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(version)

	# Quit confirmation dialog
	_quit_dialog = AcceptDialog.new()
	_quit_dialog.title = tr("QUIT_CONFIRM_TITLE")
	_quit_dialog.dialog_text = tr("QUIT_CONFIRM_MSG")
	_quit_dialog.ok_button_text = tr("MENU_CONFIRM")
	_quit_dialog.add_cancel_button(tr("MENU_CANCEL"))
	_quit_dialog.confirmed.connect(_on_quit_confirmed)
	add_child(_quit_dialog)


func _on_menu_button_pressed(signal_name: String) -> void:
	_play_click_sound()

	match signal_name:
		"tutorial_requested":
			tutorial_requested.emit()
			# Load tutorial scene via GameManager
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
			_quit_dialog.popup_centered()


func _on_quit_confirmed() -> void:
	get_tree().quit()


func _on_button_hover(_btn: Button) -> void:
	_play_click_sound()


func _play_click_sound() -> void:
	var audio: Node = _find_node_by_method(get_tree().current_scene, "play_ui_click") if get_tree().current_scene else null
	if audio:
		audio.play_ui_click()


func _connect_game_manager() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("set_state"):
		# GameManager.GameState.MENU = 0
		gm.set_state(0)


func _on_locale_changed(_locale: String) -> void:
	_update_texts()


func _update_texts() -> void:
	if _title_label:
		_title_label.text = tr("GAME_TITLE")
	if _subtitle_label:
		_subtitle_label.text = tr("GAME_SUBTITLE")
	if _quit_dialog:
		_quit_dialog.title = tr("QUIT_CONFIRM_TITLE")
		_quit_dialog.dialog_text = tr("QUIT_CONFIRM_MSG")

	if _button_container:
		for btn in _button_container.get_children():
			if btn is Button and btn.has_meta("tr_key"):
				btn.text = tr(btn.get_meta("tr_key"))


func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null
