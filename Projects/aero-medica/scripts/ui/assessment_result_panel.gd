## AssessmentResultPanel — Shows assessment results for 3 seconds with fade.
## Positioned at center-bottom of screen. Does not overlap with ActionMenu.
extends PanelContainer

## How long the result stays visible before fading.
const DISPLAY_DURATION := 3.0

## Fade-out duration in seconds.
const FADE_DURATION := 0.5

## UI references.
var _action_label: Label = null
var _result_label: RichTextLabel = null
var _fade_tween: Tween = null


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Position at center-bottom
	set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	offset_top = -100
	offset_bottom = -16
	offset_left = -200
	offset_right = 200
	custom_minimum_size = Vector2(400, 80)

	# Semi-transparent background
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.1, 0.14, 0.85)
	style.border_color = Color(0.3, 0.5, 0.7, 0.6)
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(12)
	add_theme_stylebox_override("panel", style)

	# Build UI
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	add_child(vbox)

	_action_label = Label.new()
	_action_label.add_theme_font_size_override("font_size", 14)
	_action_label.add_theme_color_override("font_color", Color(0.6, 0.75, 0.9))
	_action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(_action_label)

	_result_label = RichTextLabel.new()
	_result_label.bbcode_enabled = true
	_result_label.fit_content = true
	_result_label.scroll_active = false
	_result_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_result_label.add_theme_font_size_override("normal_font_size", 18)
	vbox.add_child(_result_label)


## Show an assessment result. action_type is the telemetry name, result is the data dict.
func show_result(action_type: String, result: Dictionary) -> void:
	# Cancel any existing fade
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	# Format the display
	_action_label.text = _format_action_name(action_type)
	_result_label.text = ""
	_result_label.append_text(_format_result(action_type, result))

	# Show immediately
	modulate.a = 1.0
	visible = true

	# Auto-hide after duration
	_fade_tween = create_tween()
	_fade_tween.tween_interval(DISPLAY_DURATION)
	_fade_tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	_fade_tween.tween_callback(_on_fade_complete)


func _on_fade_complete() -> void:
	visible = false
	modulate.a = 1.0


## Convert telemetry action name to display name.
func _format_action_name(action_type: String) -> String:
	match action_type:
		"assess_airway": return "Airway Assessment"
		"assess_breathing": return "Breathing Assessment"
		"assess_pulse": return "Pulse Assessment"
		"assess_consciousness": return "Consciousness Assessment"
		"assess_bleeding": return "Bleeding Assessment"
	return action_type.capitalize()


## Format the result dictionary into readable BBCode text.
func _format_result(action_type: String, result: Dictionary) -> String:
	match action_type:
		"assess_airway":
			var status: String = result.get("airway_status", "UNKNOWN")
			var color := "green" if status == "CLEAR" else "red"
			return "[center][color=%s][b]Airway: %s[/b][/color][/center]" % [color, status]

		"assess_breathing":
			var rate: float = result.get("breathing_rate", 0.0)
			var normal: bool = result.get("breathing_normal", false)
			var color := "green" if normal else "red"
			var label := "Normal" if normal else "Abnormal"
			return "[center][color=%s][b]Breathing: %.0f bpm (%s)[/b][/color][/center]" % [color, rate, label]

		"assess_pulse":
			var present: bool = result.get("pulse_present", false)
			var color := "green" if present else "red"
			var label := "Present" if present else "Absent"
			return "[center][color=%s][b]Pulse: %s[/b][/color][/center]" % [color, label]

		"assess_consciousness":
			var avpu: String = result.get("consciousness", "UNKNOWN")
			var state: String = result.get("state", "")
			var color := "green" if avpu == "ALERT" else "red"
			var letter := avpu[0] if avpu.length() > 0 else "?"
			return "[center][color=%s][b]Consciousness: %s (%s)[/b][/color][/center]" % [color, avpu.capitalize(), letter]

		"assess_bleeding":
			var severity: int = result.get("bleeding_severity", 0)
			var present: bool = result.get("bleeding_present", false)
			if not present:
				return "[center][color=green][b]Bleeding: None[/b][/color][/center]"
			var label := "Minor" if severity == 1 else ("Moderate" if severity == 2 else "Severe")
			return "[center][color=red][b]Bleeding: %s (%d)[/b][/color][/center]" % [label, severity]

	return "[center]%s[/center]" % str(result)
