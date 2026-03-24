## SettingsMenu — Audio, language, controls, and accessibility settings.
## Settings persist to user://settings.json.
extends Control

const SETTINGS_PATH := "user://settings.json"

## Current settings.
var _settings := {
	"master_volume": 80,
	"music_volume": 70,
	"sfx_volume": 80,
	"locale": "th",
	"ui_scale": 1.0,
	"high_contrast": false,
	"colourblind_patterns": false,
}

## UI references.
var _tab_container: TabContainer = null
var _master_slider: HSlider = null
var _music_slider: HSlider = null
var _sfx_slider: HSlider = null
var _locale_button: Button = null
var _scale_slider: HSlider = null
var _contrast_check: CheckBox = null
var _colourblind_check: CheckBox = null


func _ready() -> void:
	_load_settings()
	_build_ui()
	_apply_settings()

	var loc_mgr: Node = get_node_or_null("/root/LocalisationManager")
	if loc_mgr and loc_mgr.has_signal("locale_changed"):
		loc_mgr.locale_changed.connect(_on_locale_changed)


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.08, 0.1, 0.15)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var main := VBoxContainer.new()
	main.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	main.add_theme_constant_override("separation", 16)
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
	title.text = tr("MENU_SETTINGS")
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.4, 0.7, 1.0))
	header.add_child(title)

	# Tab container
	_tab_container = TabContainer.new()
	_tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_child(_tab_container)

	_build_audio_tab()
	_build_language_tab()
	_build_controls_tab()
	_build_accessibility_tab()

	# Apply button
	var apply_btn := Button.new()
	apply_btn.text = tr("MENU_APPLY")
	apply_btn.custom_minimum_size = Vector2(200, 48)
	apply_btn.add_theme_font_size_override("font_size", 18)
	apply_btn.pressed.connect(_on_apply_pressed)
	main.add_child(apply_btn)


func _build_audio_tab() -> void:
	var tab := VBoxContainer.new()
	tab.name = tr("SETTINGS_AUDIO")
	tab.add_theme_constant_override("separation", 20)
	_tab_container.add_child(tab)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 24)
	tab.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	margin.add_child(vbox)

	_master_slider = _create_slider_row(vbox, "SETTINGS_MASTER_VOLUME", _settings.master_volume)
	_music_slider = _create_slider_row(vbox, "SETTINGS_MUSIC_VOLUME", _settings.music_volume)
	_sfx_slider = _create_slider_row(vbox, "SETTINGS_SFX_VOLUME", _settings.sfx_volume)


func _build_language_tab() -> void:
	var tab := VBoxContainer.new()
	tab.name = tr("SETTINGS_LANGUAGE")
	tab.add_theme_constant_override("separation", 20)
	_tab_container.add_child(tab)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 24)
	tab.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)

	var label := Label.new()
	label.text = tr("SETTINGS_LANGUAGE")
	label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(label)

	_locale_button = Button.new()
	_locale_button.custom_minimum_size = Vector2(300, 48)
	_locale_button.add_theme_font_size_override("font_size", 20)
	_update_locale_button_text()
	_locale_button.pressed.connect(_on_locale_toggle)
	vbox.add_child(_locale_button)


func _build_controls_tab() -> void:
	var tab := VBoxContainer.new()
	tab.name = tr("SETTINGS_CONTROLS")
	tab.add_theme_constant_override("separation", 12)
	_tab_container.add_child(tab)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 24)
	tab.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	margin.add_child(vbox)

	var controls := [
		"CONTROLS_WASD",
		"CONTROLS_INTERACT",
		"CONTROLS_CANCEL",
		"CONTROLS_PAUSE",
		"CONTROLS_NUMBERS",
	]

	for key in controls:
		var row := Label.new()
		row.text = tr(key)
		row.add_theme_font_size_override("font_size", 16)
		row.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
		vbox.add_child(row)


func _build_accessibility_tab() -> void:
	var tab := VBoxContainer.new()
	tab.name = tr("SETTINGS_ACCESSIBILITY")
	tab.add_theme_constant_override("separation", 20)
	_tab_container.add_child(tab)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 24)
	tab.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	margin.add_child(vbox)

	# UI Scale slider
	var scale_label := Label.new()
	scale_label.text = tr("SETTINGS_UI_SCALE")
	scale_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(scale_label)

	_scale_slider = HSlider.new()
	_scale_slider.min_value = 0.8
	_scale_slider.max_value = 1.5
	_scale_slider.step = 0.1
	_scale_slider.value = _settings.ui_scale
	_scale_slider.custom_minimum_size = Vector2(300, 24)
	vbox.add_child(_scale_slider)

	# High contrast
	_contrast_check = CheckBox.new()
	_contrast_check.text = tr("SETTINGS_HIGH_CONTRAST")
	_contrast_check.button_pressed = _settings.high_contrast
	_contrast_check.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_contrast_check)

	# Colourblind patterns
	_colourblind_check = CheckBox.new()
	_colourblind_check.text = tr("SETTINGS_COLOURBLIND")
	_colourblind_check.button_pressed = _settings.colourblind_patterns
	_colourblind_check.add_theme_font_size_override("font_size", 16)
	vbox.add_child(_colourblind_check)


func _create_slider_row(parent: VBoxContainer, label_key: String, initial_value: float) -> HSlider:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	parent.add_child(row)

	var label := Label.new()
	label.text = tr(label_key)
	label.add_theme_font_size_override("font_size", 16)
	label.custom_minimum_size = Vector2(200, 0)
	row.add_child(label)

	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 5
	slider.value = initial_value
	slider.custom_minimum_size = Vector2(300, 24)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)

	var value_label := Label.new()
	value_label.text = "%d%%" % int(initial_value)
	value_label.custom_minimum_size = Vector2(50, 0)
	value_label.add_theme_font_size_override("font_size", 14)
	row.add_child(value_label)

	slider.value_changed.connect(func(val: float): value_label.text = "%d%%" % int(val))

	return slider


func _on_locale_toggle() -> void:
	var loc_mgr: Node = get_node_or_null("/root/LocalisationManager")
	if loc_mgr and loc_mgr.has_method("toggle_locale"):
		loc_mgr.toggle_locale()
		_settings.locale = loc_mgr.current_locale
		_update_locale_button_text()


func _update_locale_button_text() -> void:
	if _locale_button:
		if _settings.locale == "th":
			_locale_button.text = "ไทย (Thai) -> Press to switch to English"
		else:
			_locale_button.text = "English -> กดเพื่อเปลี่ยนเป็นภาษาไทย"


func _on_apply_pressed() -> void:
	_settings.master_volume = int(_master_slider.value)
	_settings.music_volume = int(_music_slider.value)
	_settings.sfx_volume = int(_sfx_slider.value)
	_settings.ui_scale = _scale_slider.value
	_settings.high_contrast = _contrast_check.button_pressed
	_settings.colourblind_patterns = _colourblind_check.button_pressed

	_apply_settings()
	_save_settings()


func _apply_settings() -> void:
	# Apply audio volumes
	var audio_sys: Node = _find_audio_system()
	if audio_sys:
		var master_db := linear_to_db(_settings.master_volume / 100.0)
		var music_db := linear_to_db(_settings.music_volume / 100.0)
		var sfx_db := linear_to_db(_settings.sfx_volume / 100.0)
		if audio_sys.has_method("set_master_volume"):
			audio_sys.set_master_volume(master_db)
		if audio_sys.has_method("set_music_volume"):
			audio_sys.set_music_volume(music_db)
		if audio_sys.has_method("set_sfx_volume"):
			audio_sys.set_sfx_volume(sfx_db)

	# Apply UI scale
	get_tree().root.content_scale_factor = _settings.ui_scale

	# Apply locale
	var loc_mgr: Node = get_node_or_null("/root/LocalisationManager")
	if loc_mgr and loc_mgr.has_method("set_locale"):
		loc_mgr.set_locale(_settings.locale)


func _save_settings() -> void:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_settings, "\t"))


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return

	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err == OK and json.data is Dictionary:
		for key in json.data:
			if key in _settings:
				_settings[key] = json.data[key]


func _on_back_pressed() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene("res://scenes/main/MainMenu.tscn")


func _on_locale_changed(_locale: String) -> void:
	_update_locale_button_text()


func _find_audio_system() -> Node:
	var root: Node = get_tree().current_scene
	if root:
		return _find_node_by_method(root, "set_master_volume")
	return null


func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null
