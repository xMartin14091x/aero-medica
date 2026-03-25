## SettingsMenu -- Card-based settings panel with live theme switching.
## Settings persist to user://settings.json.
extends Control

const SETTINGS_PATH := "user://settings.json"
const AI_CONFIG_PATH := "user://ai_config.json"

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

## Theme singleton reference.
@onready var _theme: Node = get_node_or_null("/root/ThemeMedical")

## AI config cache.
var _ai_config := {
	"ollama_url": "http://localhost:11434",
	"model": "unknown",
}

## ── UI Node References (populated during build) ────────────────────
var _bg: ColorRect = null
var _scroll: ScrollContainer = null
var _content: VBoxContainer = null

# Header
var _header_panel: PanelContainer = null
var _back_btn: Button = null
var _title_label: Label = null

# Card 1 -- Appearance
var _appearance_card: PanelContainer = null
var _appearance_title: Label = null
var _theme_toggle_btn: Button = null
var _theme_mode_label: Label = null
var _theme_accent_bar: ColorRect = null

# Card 2 -- Language
var _language_card: PanelContainer = null
var _language_title: Label = null
var _locale_button: Button = null
var _locale_desc: Label = null

# Card 3 -- Audio
var _audio_card: PanelContainer = null
var _audio_title: Label = null
var _master_slider: HSlider = null
var _music_slider: HSlider = null
var _sfx_slider: HSlider = null
var _master_value_label: Label = null
var _music_value_label: Label = null
var _sfx_value_label: Label = null
var _master_label: Label = null
var _music_label: Label = null
var _sfx_label: Label = null

# Card 4 -- AI Configuration
var _ai_card: PanelContainer = null
var _ai_title: Label = null
var _ollama_status_dot: ColorRect = null
var _ollama_status_label: Label = null
var _ai_model_label: Label = null
var _ai_url_label: Label = null
var _ai_model_title: Label = null
var _ai_url_title: Label = null

# Card 5 -- About
var _about_card: PanelContainer = null
var _about_title: Label = null
var _version_label: Label = null
var _desc_label: Label = null
var _copyright_label: Label = null

# All slider track style references for re-theming
var _slider_nodes: Array[HSlider] = []


func _ready() -> void:
	_load_settings()
	_load_ai_config()
	_build_ui()
	_apply_all_styles()
	_apply_settings()

	# Connect to LocalisationManager
	var loc_mgr: Node = get_node_or_null("/root/LocalisationManager")
	if loc_mgr and loc_mgr.has_signal("locale_changed"):
		loc_mgr.locale_changed.connect(_on_locale_changed)

	# Connect to ThemeMedical for live theme switching
	if _theme and _theme.has_signal("theme_changed"):
		_theme.theme_changed.connect(_on_theme_changed)

	# Check Ollama status
	_check_ollama_status()


## ── UI Construction ─────────────────────────────────────────────────

func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Full-screen background
	_bg = ColorRect.new()
	_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_bg)

	# Main vertical layout
	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(main_vbox)

	# ── Header ──
	_build_header(main_vbox)

	# ── Scrollable card area ──
	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(_scroll)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 16)
	_scroll.add_child(_content)

	# Center wrapper -- constrains cards to a max width
	var center_margin := MarginContainer.new()
	center_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center_margin.add_theme_constant_override("margin_left", 48)
	center_margin.add_theme_constant_override("margin_right", 48)
	center_margin.add_theme_constant_override("margin_top", 16)
	center_margin.add_theme_constant_override("margin_bottom", 32)
	# Replace _content as direct child -- put center_margin inside scroll
	_scroll.remove_child(_content)
	_scroll.add_child(center_margin)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 16)
	center_margin.add_child(_content)

	# ── Cards ──
	_build_appearance_card()
	_build_language_card()
	_build_audio_card()
	_build_ai_card()
	_build_about_card()


func _build_header(parent: VBoxContainer) -> void:
	_header_panel = PanelContainer.new()
	parent.add_child(_header_panel)

	var header_margin := MarginContainer.new()
	header_margin.add_theme_constant_override("margin_left", 24)
	header_margin.add_theme_constant_override("margin_right", 24)
	header_margin.add_theme_constant_override("margin_top", 12)
	header_margin.add_theme_constant_override("margin_bottom", 12)
	_header_panel.add_child(header_margin)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	hbox.alignment = BoxContainer.ALIGNMENT_BEGIN
	header_margin.add_child(hbox)

	_back_btn = Button.new()
	_back_btn.text = "< Back"
	_back_btn.custom_minimum_size = Vector2(100, 40)
	_back_btn.pressed.connect(_on_back_pressed)
	hbox.add_child(_back_btn)

	_title_label = Label.new()
	_title_label.text = tr("MENU_SETTINGS")
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(_title_label)


## ── Card 1: Appearance ──────────────────────────────────────────────

func _build_appearance_card() -> void:
	var result := _make_card_container("Appearance")
	_appearance_card = result.card
	_appearance_title = result.title
	var vbox: VBoxContainer = result.content
	_content.add_child(_appearance_card)

	# Theme accent indicator bar
	_theme_accent_bar = ColorRect.new()
	_theme_accent_bar.custom_minimum_size = Vector2(0, 3)
	vbox.add_child(_theme_accent_bar)

	# Theme toggle row
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	vbox.add_child(row)

	_theme_mode_label = Label.new()
	_theme_mode_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(_theme_mode_label)

	_theme_toggle_btn = Button.new()
	_theme_toggle_btn.custom_minimum_size = Vector2(160, 44)
	_theme_toggle_btn.pressed.connect(_on_theme_toggle)
	row.add_child(_theme_toggle_btn)


## ── Card 2: Language ────────────────────────────────────────────────

func _build_language_card() -> void:
	var result := _make_card_container("Language")
	_language_card = result.card
	_language_title = result.title
	var vbox: VBoxContainer = result.content
	_content.add_child(_language_card)

	_locale_desc = Label.new()
	vbox.add_child(_locale_desc)

	_locale_button = Button.new()
	_locale_button.custom_minimum_size = Vector2(300, 48)
	_locale_button.pressed.connect(_on_locale_toggle)
	vbox.add_child(_locale_button)

	_update_locale_button_text()


## ── Card 3: Audio ───────────────────────────────────────────────────

func _build_audio_card() -> void:
	var result := _make_card_container("Audio")
	_audio_card = result.card
	_audio_title = result.title
	var vbox: VBoxContainer = result.content
	_content.add_child(_audio_card)

	var sliders_result := _create_volume_slider(vbox, "Master Volume", _settings.master_volume)
	_master_slider = sliders_result.slider
	_master_value_label = sliders_result.value_label
	_master_label = sliders_result.name_label
	_slider_nodes.append(_master_slider)

	sliders_result = _create_volume_slider(vbox, "Music Volume", _settings.music_volume)
	_music_slider = sliders_result.slider
	_music_value_label = sliders_result.value_label
	_music_label = sliders_result.name_label
	_slider_nodes.append(_music_slider)

	sliders_result = _create_volume_slider(vbox, "SFX Volume", _settings.sfx_volume)
	_sfx_slider = sliders_result.slider
	_sfx_value_label = sliders_result.value_label
	_sfx_label = sliders_result.name_label
	_slider_nodes.append(_sfx_slider)


## ── Card 4: AI Configuration ────────────────────────────────────────

func _build_ai_card() -> void:
	var result := _make_card_container("AI Configuration")
	_ai_card = result.card
	_ai_title = result.title
	var vbox: VBoxContainer = result.content
	_content.add_child(_ai_card)

	# Ollama status row
	var status_row := HBoxContainer.new()
	status_row.add_theme_constant_override("separation", 8)
	vbox.add_child(status_row)

	var status_label_prefix := Label.new()
	status_label_prefix.text = "Ollama Status:"
	status_row.add_child(status_label_prefix)

	_ollama_status_dot = ColorRect.new()
	_ollama_status_dot.custom_minimum_size = Vector2(12, 12)
	# Center the dot vertically in the row
	var dot_center := CenterContainer.new()
	dot_center.add_child(_ollama_status_dot)
	status_row.add_child(dot_center)

	_ollama_status_label = Label.new()
	_ollama_status_label.text = "Checking..."
	status_row.add_child(_ollama_status_label)

	# Model info
	var model_row := HBoxContainer.new()
	model_row.add_theme_constant_override("separation", 8)
	vbox.add_child(model_row)

	_ai_model_title = Label.new()
	_ai_model_title.text = "Model:"
	model_row.add_child(_ai_model_title)

	_ai_model_label = Label.new()
	_ai_model_label.text = _ai_config.get("model", "unknown")
	model_row.add_child(_ai_model_label)

	# URL info
	var url_row := HBoxContainer.new()
	url_row.add_theme_constant_override("separation", 8)
	vbox.add_child(url_row)

	_ai_url_title = Label.new()
	_ai_url_title.text = "Ollama URL:"
	url_row.add_child(_ai_url_title)

	_ai_url_label = Label.new()
	_ai_url_label.text = _ai_config.get("ollama_url", "http://localhost:11434")
	url_row.add_child(_ai_url_label)


## ── Card 5: About ───────────────────────────────────────────────────

func _build_about_card() -> void:
	var result := _make_card_container("About")
	_about_card = result.card
	_about_title = result.title
	var vbox: VBoxContainer = result.content
	_content.add_child(_about_card)

	_version_label = Label.new()
	_version_label.text = "Version: INDEV v1.0.1"
	vbox.add_child(_version_label)

	_desc_label = Label.new()
	_desc_label.text = "AeroMedica -- Emergency Response Training Simulation"
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(_desc_label)

	_copyright_label = Label.new()
	_copyright_label.text = "2026 Martin"
	vbox.add_child(_copyright_label)


## ── Card Builder Helper ─────────────────────────────────────────────

## Returns { card: PanelContainer, title: Label, content: VBoxContainer }
func _make_card_container(card_title: String) -> Dictionary:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var card_vbox := VBoxContainer.new()
	card_vbox.add_theme_constant_override("separation", 12)
	card.add_child(card_vbox)

	var title := Label.new()
	title.text = card_title
	card_vbox.add_child(title)

	# Separator under title
	var sep := HSeparator.new()
	card_vbox.add_child(sep)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 10)
	card_vbox.add_child(content)

	return { "card": card, "title": title, "content": content }


## ── Slider Builder ──────────────────────────────────────────────────

## Returns { slider: HSlider, value_label: Label, name_label: Label }
func _create_volume_slider(parent: VBoxContainer, label_text: String, initial_value: float) -> Dictionary:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	parent.add_child(row)

	var name_label := Label.new()
	name_label.text = label_text
	name_label.custom_minimum_size = Vector2(160, 0)
	row.add_child(name_label)

	var slider := HSlider.new()
	slider.min_value = 0
	slider.max_value = 100
	slider.step = 5
	slider.value = initial_value
	slider.custom_minimum_size = Vector2(200, 24)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(slider)

	var value_label := Label.new()
	value_label.text = "%d%%" % int(initial_value)
	value_label.custom_minimum_size = Vector2(50, 0)
	value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value_label)

	slider.value_changed.connect(func(val: float):
		value_label.text = "%d%%" % int(val)
		_on_slider_changed()
	)

	return { "slider": slider, "value_label": value_label, "name_label": name_label }


## ── Style Application (Theme-Aware) ─────────────────────────────────

func _apply_all_styles() -> void:
	if not _theme:
		return

	# Background
	_bg.color = _theme.c("bg_main")

	# Header
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = _theme.c("bg_card")
	header_style.shadow_color = _theme.c("shadow")
	header_style.shadow_size = 2
	header_style.shadow_offset = Vector2(0, 1)
	_header_panel.add_theme_stylebox_override("panel", header_style)

	_theme.style_button(_back_btn, "small")
	_theme.style_label(_title_label, "title_large", "accent_blue")

	# ── Card 1: Appearance ──
	_theme.style_panel(_appearance_card)
	_theme.style_label(_appearance_title, "subtitle", "text_primary")
	_theme_accent_bar.color = _theme.c("accent_blue")
	_update_theme_toggle_display()

	# ── Card 2: Language ──
	_theme.style_panel(_language_card)
	_theme.style_label(_language_title, "subtitle", "text_primary")
	_theme.style_label(_locale_desc, "body_small", "text_secondary")
	_theme.style_button(_locale_button)

	# ── Card 3: Audio ──
	_theme.style_panel(_audio_card)
	_theme.style_label(_audio_title, "subtitle", "text_primary")
	_theme.style_label(_master_label, "body", "text_primary")
	_theme.style_label(_music_label, "body", "text_primary")
	_theme.style_label(_sfx_label, "body", "text_primary")
	_theme.style_label(_master_value_label, "body_small", "accent_blue")
	_theme.style_label(_music_value_label, "body_small", "accent_blue")
	_theme.style_label(_sfx_value_label, "body_small", "accent_blue")
	_style_all_sliders()

	# ── Card 4: AI Configuration ──
	_theme.style_panel(_ai_card)
	_theme.style_label(_ai_title, "subtitle", "text_primary")
	_theme.style_label(_ai_model_label, "body", "accent_blue")
	_theme.style_label(_ai_url_label, "body", "text_secondary")
	_theme.style_label(_ai_model_title, "body", "text_primary")
	_theme.style_label(_ai_url_title, "body", "text_primary")

	# ── Card 5: About ──
	_theme.style_panel(_about_card)
	_theme.style_label(_about_title, "subtitle", "text_primary")
	_theme.style_label(_version_label, "body", "accent_blue")
	_theme.style_label(_desc_label, "body", "text_secondary")
	_theme.style_label(_copyright_label, "body_small", "text_muted")


func _style_all_sliders() -> void:
	if not _theme:
		return
	for slider in _slider_nodes:
		_style_slider(slider)


func _style_slider(slider: HSlider) -> void:
	# Track (background bar)
	var track := StyleBoxFlat.new()
	track.bg_color = _theme.c("bg_input")
	track.corner_radius_top_left = 4
	track.corner_radius_top_right = 4
	track.corner_radius_bottom_left = 4
	track.corner_radius_bottom_right = 4
	track.content_margin_top = 4
	track.content_margin_bottom = 4
	slider.add_theme_stylebox_override("slider", track)

	# Filled portion (grabber area highlight)
	var grabber_area := StyleBoxFlat.new()
	grabber_area.bg_color = _theme.c("accent_blue")
	grabber_area.corner_radius_top_left = 4
	grabber_area.corner_radius_top_right = 4
	grabber_area.corner_radius_bottom_left = 4
	grabber_area.corner_radius_bottom_right = 4
	grabber_area.content_margin_top = 4
	grabber_area.content_margin_bottom = 4
	slider.add_theme_stylebox_override("grabber_area", grabber_area)
	slider.add_theme_stylebox_override("grabber_area_highlight", grabber_area)

	# Grabber icon color
	slider.add_theme_icon_override("grabber", _make_circle_texture(_theme.c("accent_blue"), 16))
	slider.add_theme_icon_override("grabber_highlight", _make_circle_texture(_theme.c("border_hover"), 18))


## Creates a simple circle texture for slider grabbers.
func _make_circle_texture(color: Color, diameter: int) -> ImageTexture:
	var img := Image.create(diameter, diameter, false, Image.FORMAT_RGBA8)
	var center := Vector2(diameter / 2.0, diameter / 2.0)
	var radius := diameter / 2.0
	for x in range(diameter):
		for y in range(diameter):
			var dist := Vector2(x + 0.5, y + 0.5).distance_to(center)
			if dist <= radius:
				img.set_pixel(x, y, color)
			else:
				img.set_pixel(x, y, Color(0, 0, 0, 0))
	return ImageTexture.create_from_image(img)


## ── Theme Toggle Display ────────────────────────────────────────────

func _update_theme_toggle_display() -> void:
	if not _theme:
		return

	var is_dark: bool = _theme.current_mode == "dark"
	_theme_toggle_btn.text = "Light Mode" if is_dark else "Dark Mode"
	_theme_mode_label.text = "Current: Dark Mode" if is_dark else "Current: Light Mode"

	_theme.style_label(_theme_mode_label, "body", "text_secondary")

	# Style toggle button with accent
	var btn_style := _theme.make_btn_normal()
	btn_style.border_color = _theme.c("accent_blue")
	btn_style.border_width_left = 2
	btn_style.border_width_right = 2
	btn_style.border_width_top = 2
	btn_style.border_width_bottom = 2
	_theme_toggle_btn.add_theme_stylebox_override("normal", btn_style)

	var btn_hover := _theme.make_btn_hover()
	btn_hover.border_color = _theme.c("accent_blue")
	btn_hover.border_width_left = 2
	btn_hover.border_width_right = 2
	btn_hover.border_width_top = 2
	btn_hover.border_width_bottom = 2
	_theme_toggle_btn.add_theme_stylebox_override("hover", btn_hover)

	_theme_toggle_btn.add_theme_stylebox_override("pressed", _theme.make_btn_pressed())
	_theme_toggle_btn.add_theme_color_override("font_color", _theme.c("accent_blue"))
	_theme_toggle_btn.add_theme_color_override("font_hover_color", Color.WHITE)
	_theme_toggle_btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	_theme_toggle_btn.add_theme_font_size_override("font_size", _theme.FONT_SIZES.body)

	_theme_accent_bar.color = _theme.c("accent_blue")


## ── Event Handlers ──────────────────────────────────────────────────

func _on_theme_toggle() -> void:
	if _theme:
		_theme.toggle_mode()


func _on_theme_changed(_mode: String) -> void:
	_apply_all_styles()


func _on_locale_toggle() -> void:
	var loc_mgr: Node = get_node_or_null("/root/LocalisationManager")
	if loc_mgr and loc_mgr.has_method("toggle_locale"):
		loc_mgr.toggle_locale()
		_settings.locale = loc_mgr.current_locale
		_update_locale_button_text()
		_save_settings()


func _update_locale_button_text() -> void:
	if _locale_button:
		if _settings.locale == "th":
			_locale_button.text = "Thai / English  ->  Press to switch to English"
			_locale_desc.text = "Currently displaying in Thai"
		else:
			_locale_button.text = "English / Thai  ->  Press to switch to Thai"
			_locale_desc.text = "Currently displaying in English"


func _on_slider_changed() -> void:
	_settings.master_volume = int(_master_slider.value)
	_settings.music_volume = int(_music_slider.value)
	_settings.sfx_volume = int(_sfx_slider.value)
	_apply_settings()
	_save_settings()


func _on_back_pressed() -> void:
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene("res://scenes/main/MainMenu.tscn")


func _on_locale_changed(_locale: String) -> void:
	_update_locale_button_text()


## ── Settings Persistence ────────────────────────────────────────────

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


## ── AI Config ───────────────────────────────────────────────────────

func _load_ai_config() -> void:
	if not FileAccess.file_exists(AI_CONFIG_PATH):
		return

	var file := FileAccess.open(AI_CONFIG_PATH, FileAccess.READ)
	if not file:
		return

	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err == OK and json.data is Dictionary:
		_ai_config = json.data


func _check_ollama_status() -> void:
	var url: String = _ai_config.get("ollama_url", "http://localhost:11434")
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_ollama_check_complete.bind(http))
	var error := http.request(url + "/api/tags")
	if error != OK:
		_set_ollama_status(false)
		http.queue_free()


func _on_ollama_check_complete(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()
	_set_ollama_status(result == HTTPRequest.RESULT_SUCCESS and response_code == 200)


func _set_ollama_status(online: bool) -> void:
	if not _theme:
		_ollama_status_dot.color = Color.GREEN if online else Color.RED
		_ollama_status_label.text = "Online" if online else "Offline"
		return

	if online:
		_ollama_status_dot.color = _theme.c("accent_green")
		_ollama_status_label.text = "Online"
		_theme.style_label(_ollama_status_label, "body", "accent_green")
	else:
		_ollama_status_dot.color = _theme.c("accent_red")
		_ollama_status_label.text = "Offline"
		_theme.style_label(_ollama_status_label, "body", "accent_red")


## ── Audio System Discovery ──────────────────────────────────────────

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
