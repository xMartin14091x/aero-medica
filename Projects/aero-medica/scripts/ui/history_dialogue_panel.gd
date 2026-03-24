## HistoryDialoguePanel — 60% screen overlay for patient history taking (SAMPLE framework).
## Left side: category buttons + per-category question lists.
## Right side: scrolling conversation log showing asked questions and responses.
## Opened when player interacts with patient empty-handed alongside assessment menu.
extends PanelContainer

## Emitted when a question is selected by the player.
signal question_selected(category: String, question_key: String)

## Emitted when the panel is closed by the player.
signal panel_closed

## UI node references (built in _ready).
var _header_label: Label = null
var _close_btn: Button = null
var _category_container: VBoxContainer = null
var _question_container: VBoxContainer = null
var _response_log: RichTextLabel = null
var _category_buttons: Dictionary = {}
var _question_buttons: Array[Button] = []
var _selected_category: String = ""

## Data references set by HUDController.
var _history_mgr: Node = null
var _current_patient: Node = null


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP

	# Fill 60% of screen, centered
	set_anchors_preset(Control.PRESET_CENTER)
	anchor_left = 0.2
	anchor_right = 0.8
	anchor_top = 0.1
	anchor_bottom = 0.9
	offset_left = 0
	offset_right = 0
	offset_top = 0
	offset_bottom = 0

	# Panel style
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.08, 0.12, 0.95)
	style.border_color = Color(0.25, 0.45, 0.65, 0.7)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(16)
	add_theme_stylebox_override("panel", style)

	_build_ui()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_ESCAPE or event.physical_keycode == KEY_TAB:
			close_panel()
			get_viewport().set_input_as_handled()


## Build the full UI hierarchy programmatically.
func _build_ui() -> void:
	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 8)
	add_child(root_vbox)

	# Header bar
	var header := HBoxContainer.new()
	header.add_theme_constant_override("separation", 8)
	root_vbox.add_child(header)

	_header_label = Label.new()
	_header_label.text = "Patient History (SAMPLE)"
	_header_label.add_theme_font_size_override("font_size", 20)
	_header_label.add_theme_color_override("font_color", Color(0.7, 0.85, 1.0))
	_header_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_header_label)

	_close_btn = Button.new()
	_close_btn.text = "Close [Esc]"
	_close_btn.pressed.connect(close_panel)
	_close_btn.focus_mode = Control.FOCUS_NONE
	header.add_child(_close_btn)

	# Separator
	var sep := HSeparator.new()
	root_vbox.add_child(sep)

	# Main content: left (categories+questions) | right (response log)
	var content := HSplitContainer.new()
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.split_offset = -200
	root_vbox.add_child(content)

	# Left panel: categories + questions
	var left_panel := VBoxContainer.new()
	left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_panel.size_flags_stretch_ratio = 0.4
	left_panel.add_theme_constant_override("separation", 6)
	content.add_child(left_panel)

	var cat_label := Label.new()
	cat_label.text = "Categories"
	cat_label.add_theme_font_size_override("font_size", 16)
	cat_label.add_theme_color_override("font_color", Color(0.6, 0.75, 0.9))
	left_panel.add_child(cat_label)

	# Category buttons (horizontal flow)
	var cat_flow := HFlowContainer.new()
	cat_flow.add_theme_constant_override("h_separation", 4)
	cat_flow.add_theme_constant_override("v_separation", 4)
	left_panel.add_child(cat_flow)
	_category_container = VBoxContainer.new()
	cat_flow.add_child(_category_container)

	var q_sep := HSeparator.new()
	left_panel.add_child(q_sep)

	var q_label := Label.new()
	q_label.text = "Questions"
	q_label.add_theme_font_size_override("font_size", 16)
	q_label.add_theme_color_override("font_color", Color(0.6, 0.75, 0.9))
	left_panel.add_child(q_label)

	# Scrollable question list
	var q_scroll := ScrollContainer.new()
	q_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_panel.add_child(q_scroll)

	_question_container = VBoxContainer.new()
	_question_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_question_container.add_theme_constant_override("separation", 4)
	q_scroll.add_child(_question_container)

	# Right panel: response log
	var right_panel := VBoxContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.size_flags_stretch_ratio = 0.6
	right_panel.add_theme_constant_override("separation", 6)
	content.add_child(right_panel)

	var r_label := Label.new()
	r_label.text = "Responses"
	r_label.add_theme_font_size_override("font_size", 16)
	r_label.add_theme_color_override("font_color", Color(0.6, 0.75, 0.9))
	right_panel.add_child(r_label)

	# Response log style
	var log_panel := PanelContainer.new()
	log_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var log_style := StyleBoxFlat.new()
	log_style.bg_color = Color(0.04, 0.05, 0.08, 0.8)
	log_style.set_corner_radius_all(4)
	log_style.set_content_margin_all(8)
	log_panel.add_theme_stylebox_override("panel", log_style)
	right_panel.add_child(log_panel)

	var log_scroll := ScrollContainer.new()
	log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_panel.add_child(log_scroll)

	_response_log = RichTextLabel.new()
	_response_log.bbcode_enabled = true
	_response_log.fit_content = true
	_response_log.scroll_active = false
	_response_log.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_response_log.add_theme_font_size_override("normal_font_size", 15)
	log_scroll.add_child(_response_log)


## Open the panel for a specific patient + history manager.
func open_panel(patient: Node, history_mgr: Node) -> void:
	_current_patient = patient
	_history_mgr = history_mgr
	_response_log.text = ""
	_selected_category = ""

	# Update header with patient name
	var patient_name := "Unknown"
	if "persona" in patient and patient.persona:
		patient_name = patient.persona.patient_name
	_header_label.text = "Patient History — %s" % patient_name

	_build_categories()
	_clear_questions()
	visible = true


## Close the panel.
func close_panel() -> void:
	visible = false
	_current_patient = null
	panel_closed.emit()


## Build category buttons from the history manager's question data.
func _build_categories() -> void:
	# Clear existing
	for child in _category_container.get_children():
		child.queue_free()
	_category_buttons.clear()

	if not _history_mgr:
		return

	var categories: Array = _history_mgr.get_categories()
	for cat: String in categories:
		var btn := Button.new()
		btn.text = _format_category_name(cat)
		btn.pressed.connect(_on_category_pressed.bind(cat))
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(120, 32)
		_category_container.add_child(btn)
		_category_buttons[cat] = btn


## When a category is selected, show its questions.
func _on_category_pressed(category: String) -> void:
	_selected_category = category
	_build_questions(category)

	# Highlight selected category
	for cat: String in _category_buttons:
		var btn: Button = _category_buttons[cat]
		if cat == category:
			btn.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
		else:
			btn.remove_theme_color_override("font_color")


## Build question buttons for the selected category.
func _build_questions(category: String) -> void:
	_clear_questions()

	if not _history_mgr:
		return

	var questions: Array = _history_mgr.get_questions_for_category(category)
	for q: Dictionary in questions:
		var key: String = q.get("key", "")
		var label: String = q.get("label", key)
		var asked: bool = _history_mgr.is_question_asked(category, key)

		var btn := Button.new()
		btn.text = label
		btn.focus_mode = Control.FOCUS_NONE
		btn.custom_minimum_size = Vector2(0, 28)

		if asked:
			btn.text = "[Asked] " + label
			btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		else:
			btn.pressed.connect(_on_question_pressed.bind(category, key, label))

		_question_container.add_child(btn)
		_question_buttons.append(btn)


## Clear question buttons.
func _clear_questions() -> void:
	for btn in _question_buttons:
		if is_instance_valid(btn):
			btn.queue_free()
	_question_buttons.clear()


## When a question is pressed, ask it and display the response.
func _on_question_pressed(category: String, key: String, label: String) -> void:
	if not _history_mgr:
		return

	var response: String = _history_mgr.ask_question(category, key)

	# Add to response log
	_response_log.append_text("[color=#6699cc][b]Q: %s[/b][/color]\n" % label)
	_response_log.append_text("[color=#cccccc]A: %s[/color]\n\n" % response)

	# Refresh question list to show asked state
	_build_questions(_selected_category)

	question_selected.emit(category, key)


## Format category key to display name.
func _format_category_name(category: String) -> String:
	match category:
		"symptoms": return "Symptoms"
		"allergies": return "Allergies"
		"medications": return "Medications"
		"past_history": return "Past History"
		"last_meal": return "Last Meal"
		"events": return "Events"
	return category.capitalize()
