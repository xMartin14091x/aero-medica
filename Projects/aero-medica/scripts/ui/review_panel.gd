## ReviewPanel — AI performance review display panel.
## Left: scrollable narrative review. Right: quick metrics sidebar.
## Sections colour-coded: strengths (green), improvements (yellow),
## critical errors (red), recommendations (blue).
## Shows loading spinner while waiting for AI response.
extends Control

## Emitted when the player closes the review panel.
signal review_closed()

## Colour coding for review sections.
const COLOUR_OVERALL := Color(1.0, 1.0, 1.0)
const COLOUR_STRENGTHS := Color(0.3, 0.9, 0.3)
const COLOUR_IMPROVEMENTS := Color(1.0, 0.9, 0.2)
const COLOUR_ERRORS := Color(1.0, 0.3, 0.3)
const COLOUR_RECOMMENDATIONS := Color(0.4, 0.7, 1.0)

## Panel state.
enum PanelState { HIDDEN, LOADING, REVIEW, ERROR }
var _state: PanelState = PanelState.HIDDEN

## UI references — created in _ready.
var _background: ColorRect = null
var _content_container: HSplitContainer = null
var _narrative_scroll: ScrollContainer = null
var _narrative_vbox: VBoxContainer = null
var _metrics_vbox: VBoxContainer = null
var _loading_label: Label = null
var _continue_btn: Button = null
var _title_label: Label = null


func _ready() -> void:
	visible = false
	_build_ui()


## Construct the UI programmatically for flexibility.
func _build_ui() -> void:
	# Dark background overlay
	_background = ColorRect.new()
	_background.color = Color(0.08, 0.08, 0.12, 0.95)
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_background)

	# Main margin
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var outer_vbox := VBoxContainer.new()
	outer_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(outer_vbox)

	# Title
	_title_label = Label.new()
	_title_label.text = "AI Performance Review"
	_title_label.add_theme_font_size_override("font_size", 32)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_vbox.add_child(_title_label)

	# Separator
	var sep := HSeparator.new()
	outer_vbox.add_child(sep)

	# Loading label (shown during API wait)
	_loading_label = Label.new()
	_loading_label.text = "AI Reviewer is analysing your performance..."
	_loading_label.add_theme_font_size_override("font_size", 20)
	_loading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_loading_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_loading_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_loading_label.visible = false
	outer_vbox.add_child(_loading_label)

	# Content: left narrative + right metrics
	_content_container = HSplitContainer.new()
	_content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_container.split_offset = -280
	_content_container.visible = false
	outer_vbox.add_child(_content_container)

	# Left: scrollable narrative
	_narrative_scroll = ScrollContainer.new()
	_narrative_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_narrative_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_container.add_child(_narrative_scroll)

	_narrative_vbox = VBoxContainer.new()
	_narrative_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_narrative_scroll.add_child(_narrative_vbox)

	# Right: metrics sidebar
	var metrics_panel := PanelContainer.new()
	metrics_panel.custom_minimum_size.x = 260
	_content_container.add_child(metrics_panel)

	var metrics_margin := MarginContainer.new()
	metrics_margin.add_theme_constant_override("margin_left", 12)
	metrics_margin.add_theme_constant_override("margin_right", 12)
	metrics_margin.add_theme_constant_override("margin_top", 12)
	metrics_margin.add_theme_constant_override("margin_bottom", 12)
	metrics_panel.add_child(metrics_margin)

	_metrics_vbox = VBoxContainer.new()
	metrics_margin.add_child(_metrics_vbox)

	# Continue button
	_continue_btn = Button.new()
	_continue_btn.text = "Continue"
	_continue_btn.custom_minimum_size.y = 40
	_continue_btn.pressed.connect(_on_continue_pressed)
	outer_vbox.add_child(_continue_btn)


## Show loading state while waiting for AI review.
func show_loading() -> void:
	_state = PanelState.LOADING
	visible = true
	_loading_label.visible = true
	_content_container.visible = false
	_continue_btn.visible = false


## Show the parsed AI review data.
func show_review(review_data: Dictionary, metrics: Dictionary = {}) -> void:
	_state = PanelState.REVIEW
	visible = true
	_loading_label.visible = false
	_content_container.visible = true
	_continue_btn.visible = true

	_populate_narrative(review_data)
	_populate_metrics(metrics)


## Show error state when AI review fails.
func show_error(message: String = "") -> void:
	_state = PanelState.ERROR
	visible = true
	_loading_label.visible = true
	_content_container.visible = false
	_continue_btn.visible = true

	if message == "":
		message = "AI Review unavailable — showing quantitative results only"
	_loading_label.text = message


## Populate the narrative section from parsed review data.
func _populate_narrative(review_data: Dictionary) -> void:
	# Clear existing content
	for child in _narrative_vbox.get_children():
		child.queue_free()

	# Overall Assessment
	var overall: String = review_data.get("overall_assessment", "")
	if overall != "":
		_add_section_header("Overall Assessment", COLOUR_OVERALL)
		_add_section_text(overall, COLOUR_OVERALL)

	# Strengths
	var strengths: Array = review_data.get("strengths", [])
	if strengths.size() > 0:
		_add_section_header("Strengths", COLOUR_STRENGTHS)
		for item: String in strengths:
			_add_bullet(item, COLOUR_STRENGTHS)

	# Areas for Improvement
	var improvements: Array = review_data.get("improvements", [])
	if improvements.size() > 0:
		_add_section_header("Areas for Improvement", COLOUR_IMPROVEMENTS)
		for item: String in improvements:
			_add_bullet(item, COLOUR_IMPROVEMENTS)

	# Critical Errors
	var errors: Array = review_data.get("critical_errors", [])
	if errors.size() > 0:
		_add_section_header("Critical Errors", COLOUR_ERRORS)
		for item: String in errors:
			_add_bullet(item, COLOUR_ERRORS)

	# Recommendations
	var recommendations: Array = review_data.get("recommendations", [])
	if recommendations.size() > 0:
		_add_section_header("Recommendations", COLOUR_RECOMMENDATIONS)
		for item: String in recommendations:
			_add_bullet(item, COLOUR_RECOMMENDATIONS)

	# Fallback: raw text if no structured sections
	if overall == "" and strengths.is_empty() and improvements.is_empty():
		var raw: String = review_data.get("raw_text", "No review data available.")
		_add_section_text(raw, COLOUR_OVERALL)


## Populate the metrics sidebar.
func _populate_metrics(metrics: Dictionary) -> void:
	for child in _metrics_vbox.get_children():
		child.queue_free()

	var header := Label.new()
	header.text = "Quick Metrics"
	header.add_theme_font_size_override("font_size", 20)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_metrics_vbox.add_child(header)

	_metrics_vbox.add_child(HSeparator.new())

	_add_metric("Scenario Time", metrics.get("scenario_time", "—"))
	_add_metric("Patients Treated", metrics.get("patients_treated", "—"))
	_add_metric("Triage Accuracy", metrics.get("triage_accuracy", "—"))
	_add_metric("Protocol Adherence", metrics.get("protocol_adherence", "—"))


## Add a coloured section header to the narrative.
func _add_section_header(text: String, colour: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", 22)
	lbl.add_theme_color_override("font_color", colour)
	_narrative_vbox.add_child(lbl)


## Add section body text.
func _add_section_text(text: String, colour: Color) -> void:
	var lbl := RichTextLabel.new()
	lbl.bbcode_enabled = false
	lbl.text = text
	lbl.fit_content = true
	lbl.add_theme_color_override("default_color", colour.lerp(Color.WHITE, 0.3))
	lbl.add_theme_font_size_override("normal_font_size", 16)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_narrative_vbox.add_child(lbl)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 8
	_narrative_vbox.add_child(spacer)


## Add a coloured bullet point.
func _add_bullet(text: String, colour: Color) -> void:
	var hbox := HBoxContainer.new()

	var bullet := Label.new()
	bullet.text = "•"
	bullet.add_theme_color_override("font_color", colour)
	bullet.add_theme_font_size_override("font_size", 18)
	hbox.add_child(bullet)

	var lbl := Label.new()
	lbl.text = " " + text
	lbl.add_theme_color_override("font_color", colour.lerp(Color.WHITE, 0.2))
	lbl.add_theme_font_size_override("font_size", 16)
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	_narrative_vbox.add_child(hbox)


## Add a metric row to the sidebar.
func _add_metric(label_text: String, value) -> void:
	var vbox := VBoxContainer.new()

	var name_lbl := Label.new()
	name_lbl.text = label_text
	name_lbl.add_theme_font_size_override("font_size", 13)
	name_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	vbox.add_child(name_lbl)

	var val_lbl := Label.new()
	val_lbl.text = str(value)
	val_lbl.add_theme_font_size_override("font_size", 18)
	vbox.add_child(val_lbl)

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 6
	vbox.add_child(spacer)

	_metrics_vbox.add_child(vbox)


func _on_continue_pressed() -> void:
	visible = false
	_state = PanelState.HIDDEN
	review_closed.emit()
