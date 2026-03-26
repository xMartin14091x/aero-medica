## ThemeMedical — Centralized theme system for AeroMedica UI.
## Provides dark and light themes via StyleBoxFlat + font overrides.
## All UI components read from this singleton instead of hardcoding styles.
## Toggle with set_mode("dark") or set_mode("light"). Persists to user_data.
extends Node

## Emitted when the theme mode changes. UI components should reconnect styles.
signal theme_changed(mode: String)

## Current theme mode.
var current_mode: String = "dark"

## Config persistence path.
const CONFIG_PATH := "user://theme_config.json"

## ── Color Palettes ──────────────────────────────────────────────

const PALETTE := {
	"dark": {
		"bg_main":        Color(0.059, 0.067, 0.090),   # #0F1117
		"bg_card":        Color(0.102, 0.114, 0.153),   # #1A1D27
		"bg_card_hover":  Color(0.133, 0.145, 0.227),   # #22253A
		"bg_card_accent": Color(0.122, 0.133, 0.180),   # #1F2230
		"bg_input":       Color(0.075, 0.086, 0.118),   # #131620
		"border":         Color(0.165, 0.176, 0.227),   # #2A2D3A
		"border_hover":   Color(0.298, 0.604, 1.000),   # #4C9AFF
		"border_active":  Color(0.298, 0.604, 1.000),   # #4C9AFF
		"text_primary":   Color(0.910, 0.918, 0.941),   # #E8EAF0
		"text_secondary": Color(0.545, 0.561, 0.639),   # #8B8FA3
		"text_muted":     Color(0.333, 0.345, 0.400),   # #555867
		"accent_blue":    Color(0.298, 0.604, 1.000),   # #4C9AFF
		"accent_green":   Color(0.212, 0.702, 0.494),   # #36B37E
		"accent_yellow":  Color(1.000, 0.671, 0.000),   # #FFAB00
		"accent_red":     Color(1.000, 0.337, 0.188),   # #FF5630
		"accent_purple":  Color(0.396, 0.329, 0.753),   # #6554C0
		"overlay":        Color(0.0, 0.0, 0.0, 0.75),
		"shadow":         Color(0.0, 0.0, 0.0, 0.25),
		"btn_normal":     Color(0.102, 0.114, 0.153),   # #1A1D27
		"btn_hover":      Color(0.133, 0.145, 0.227),   # #22253A
		"btn_pressed":    Color(0.298, 0.604, 1.000),   # #4C9AFF
		"btn_disabled":   Color(0.078, 0.086, 0.118),   # #14161E
		"separator":      Color(0.165, 0.176, 0.227, 0.5),
	},
	"light": {
		"bg_main":        Color(0.945, 0.949, 0.961),   # #F1F2F5
		"bg_card":        Color(1.000, 1.000, 1.000),   # #FFFFFF
		"bg_card_hover":  Color(0.957, 0.965, 0.980),   # #F4F7FA
		"bg_card_accent": Color(0.937, 0.945, 0.961),   # #EFF1F5
		"bg_input":       Color(0.965, 0.969, 0.980),   # #F6F8FA
		"border":         Color(0.847, 0.859, 0.886),   # #D8DBE2
		"border_hover":   Color(0.200, 0.467, 0.863),   # #3377DC
		"border_active":  Color(0.200, 0.467, 0.863),   # #3377DC
		"text_primary":   Color(0.129, 0.145, 0.196),   # #212532
		"text_secondary": Color(0.400, 0.420, 0.490),   # #666B7D
		"text_muted":     Color(0.600, 0.616, 0.680),   # #999DAD
		"accent_blue":    Color(0.200, 0.467, 0.863),   # #3377DC
		"accent_green":   Color(0.173, 0.612, 0.424),   # #2C9C6C
		"accent_yellow":  Color(0.878, 0.580, 0.000),   # #E09400
		"accent_red":     Color(0.878, 0.247, 0.129),   # #E03F21
		"accent_purple":  Color(0.329, 0.263, 0.659),   # #5443A8
		"overlay":        Color(0.0, 0.0, 0.0, 0.45),
		"shadow":         Color(0.0, 0.0, 0.0, 0.08),
		"btn_normal":     Color(1.000, 1.000, 1.000),   # #FFFFFF
		"btn_hover":      Color(0.957, 0.965, 0.980),   # #F4F7FA
		"btn_pressed":    Color(0.200, 0.467, 0.863),   # #3377DC
		"btn_disabled":   Color(0.925, 0.929, 0.941),   # #ECEDFO
		"separator":      Color(0.847, 0.859, 0.886, 0.5),
	},
}

## ── Font Sizes ──────────────────────────────────────────────────

const FONT_SIZES := {
	"title_large":  28,
	"title":        22,
	"subtitle":     18,
	"body":         16,
	"body_small":   14,
	"label":        13,
	"caption":      11,
	"hero_number":  36,
}

## ── Spacing Constants ───────────────────────────────────────────

const SPACING := {
	"card_padding":     16,
	"card_margin":      8,
	"section_gap":      20,
	"item_gap":         8,
	"corner_radius":    8,
	"corner_radius_sm": 6,
	"corner_radius_lg": 12,
	"border_width":     1,
	"shadow_size":      4,
	"shadow_offset":    Vector2(0, 2),
	"button_height":    44,
	"button_height_sm": 36,
	"button_height_lg": 56,
	"input_height":     40,
}


func _ready() -> void:
	_load_config()


## ── Public API ───────────────────────────────────────────────────

## Get a color from the current palette.
func c(key: String) -> Color:
	return PALETTE[current_mode].get(key, Color.MAGENTA)


## Set the theme mode and notify all listeners.
func set_mode(mode: String) -> void:
	if mode not in ["dark", "light"]:
		push_warning("ThemeMedical: Invalid mode '%s'. Use 'dark' or 'light'." % mode)
		return
	current_mode = mode
	_save_config()
	theme_changed.emit(mode)


## Toggle between dark and light.
func toggle_mode() -> void:
	set_mode("light" if current_mode == "dark" else "dark")


## ── StyleBox Builders ────────────────────────────────────────────

## Card panel — main container for content sections.
func make_card(severity: String = "normal") -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = c("bg_card")
	style.border_width_left = SPACING.border_width
	style.border_width_right = SPACING.border_width
	style.border_width_top = SPACING.border_width
	style.border_width_bottom = SPACING.border_width
	style.border_color = c("border")
	style.corner_radius_top_left = SPACING.corner_radius
	style.corner_radius_top_right = SPACING.corner_radius
	style.corner_radius_bottom_left = SPACING.corner_radius
	style.corner_radius_bottom_right = SPACING.corner_radius
	style.content_margin_left = SPACING.card_padding
	style.content_margin_right = SPACING.card_padding
	style.content_margin_top = SPACING.card_padding
	style.content_margin_bottom = SPACING.card_padding
	style.shadow_color = c("shadow")
	style.shadow_size = SPACING.shadow_size
	style.shadow_offset = SPACING.shadow_offset
	match severity:
		"warning":  style.border_color = c("accent_yellow")
		"critical": style.border_color = c("accent_red")
		"good":     style.border_color = c("accent_green")
		"active":   style.border_color = c("accent_blue")
		"info":     style.border_color = c("accent_purple")
	return style


## Card with left accent bar (colored left border, thicker).
func make_card_accent(accent_color: Color) -> StyleBoxFlat:
	var style := make_card()
	style.border_width_left = 4
	style.border_color = c("border")
	style.border_blend = false
	# Override left border with accent
	style.border_color = accent_color
	return style


## Button normal state.
func make_btn_normal() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = c("btn_normal")
	style.border_width_left = SPACING.border_width
	style.border_width_right = SPACING.border_width
	style.border_width_top = SPACING.border_width
	style.border_width_bottom = SPACING.border_width
	style.border_color = c("border")
	style.corner_radius_top_left = SPACING.corner_radius_sm
	style.corner_radius_top_right = SPACING.corner_radius_sm
	style.corner_radius_bottom_left = SPACING.corner_radius_sm
	style.corner_radius_bottom_right = SPACING.corner_radius_sm
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


## Button hover state.
func make_btn_hover() -> StyleBoxFlat:
	var style := make_btn_normal()
	style.bg_color = c("btn_hover")
	style.border_color = c("border_hover")
	return style


## Button pressed state.
func make_btn_pressed() -> StyleBoxFlat:
	var style := make_btn_normal()
	style.bg_color = c("btn_pressed")
	style.border_color = c("btn_pressed")
	return style


## Button disabled state.
func make_btn_disabled() -> StyleBoxFlat:
	var style := make_btn_normal()
	style.bg_color = c("btn_disabled")
	style.border_color = c("border")
	return style


## Input field (LineEdit, OptionButton).
func make_input() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = c("bg_input")
	style.border_width_left = SPACING.border_width
	style.border_width_right = SPACING.border_width
	style.border_width_top = SPACING.border_width
	style.border_width_bottom = SPACING.border_width
	style.border_color = c("border")
	style.corner_radius_top_left = SPACING.corner_radius_sm
	style.corner_radius_top_right = SPACING.corner_radius_sm
	style.corner_radius_bottom_left = SPACING.corner_radius_sm
	style.corner_radius_bottom_right = SPACING.corner_radius_sm
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


## Input field focused state.
func make_input_focus() -> StyleBoxFlat:
	var style := make_input()
	style.border_color = c("accent_blue")
	return style


## Full-screen overlay background.
func make_overlay() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = c("overlay")
	return style


## Separator line.
func make_separator() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = c("separator")
	style.content_margin_top = 1
	style.content_margin_bottom = 1
	return style


## Tab button — active state (accent bottom border + blue bg tint).
func make_tab_active() -> StyleBoxFlat:
	var style := make_btn_normal()
	style.bg_color = c("bg_card_accent")
	style.border_width_bottom = 3
	style.border_color = c("accent_blue")
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_width_top = 1
	return style


## Tab button — inactive state.
func make_tab_inactive() -> StyleBoxFlat:
	var style := make_btn_normal()
	style.bg_color = c("bg_card")
	style.border_color = c("border")
	return style


## ── Utility: Apply Theme to a Button ─────────────────────────────

## Apply full themed styling to a Button node.
func style_button(btn: Button, size: String = "normal") -> void:
	btn.add_theme_stylebox_override("normal", make_btn_normal())
	btn.add_theme_stylebox_override("hover", make_btn_hover())
	btn.add_theme_stylebox_override("pressed", make_btn_pressed())
	btn.add_theme_stylebox_override("disabled", make_btn_disabled())
	btn.add_theme_color_override("font_color", c("text_primary"))
	btn.add_theme_color_override("font_hover_color", c("accent_blue"))
	btn.add_theme_color_override("font_pressed_color", Color.WHITE if current_mode == "dark" else c("text_primary"))
	btn.add_theme_color_override("font_disabled_color", c("text_muted"))
	match size:
		"small":
			btn.add_theme_font_size_override("font_size", FONT_SIZES.body_small)
			btn.custom_minimum_size.y = SPACING.button_height_sm
		"large":
			btn.add_theme_font_size_override("font_size", FONT_SIZES.subtitle)
			btn.custom_minimum_size.y = SPACING.button_height_lg
		_:
			btn.add_theme_font_size_override("font_size", FONT_SIZES.body)
			btn.custom_minimum_size.y = SPACING.button_height


## Apply themed styling to a LineEdit.
func style_input(input: LineEdit) -> void:
	input.add_theme_stylebox_override("normal", make_input())
	input.add_theme_stylebox_override("focus", make_input_focus())
	input.add_theme_color_override("font_color", c("text_primary"))
	input.add_theme_color_override("font_placeholder_color", c("text_muted"))
	input.add_theme_font_size_override("font_size", FONT_SIZES.body)
	input.custom_minimum_size.y = SPACING.input_height


## Apply themed styling to an OptionButton.
func style_option_button(btn: OptionButton) -> void:
	btn.add_theme_stylebox_override("normal", make_input())
	btn.add_theme_stylebox_override("hover", make_input_focus())
	btn.add_theme_stylebox_override("pressed", make_input_focus())
	btn.add_theme_color_override("font_color", c("text_primary"))
	btn.add_theme_font_size_override("font_size", FONT_SIZES.body)


## Apply themed styling to a PanelContainer (card).
func style_panel(panel: PanelContainer, severity: String = "normal") -> void:
	panel.add_theme_stylebox_override("panel", make_card(severity))


## Apply themed styling to a Label.
func style_label(label: Label, level: String = "body", color_key: String = "text_primary") -> void:
	label.add_theme_font_size_override("font_size", FONT_SIZES.get(level, 16))
	label.add_theme_color_override("font_color", c(color_key))


## Apply themed styling to a RichTextLabel.
func style_rich_label(rtl: RichTextLabel, level: String = "body") -> void:
	rtl.add_theme_font_size_override("normal_font_size", FONT_SIZES.get(level, 16))
	rtl.add_theme_color_override("default_color", c("text_primary"))


## ── Severity Color Helpers ───────────────────────────────────────

## Get the appropriate color for a vital sign severity level.
func severity_color(level: String) -> Color:
	match level:
		"normal", "good":    return c("accent_green")
		"warning", "caution": return c("accent_yellow")
		"critical", "danger": return c("accent_red")
		"info":              return c("accent_blue")
		_:                   return c("text_secondary")


## Get triage tag color.
func triage_color(tag: String) -> Color:
	match tag.to_upper():
		"GREEN":  return c("accent_green")
		"YELLOW": return c("accent_yellow")
		"RED":    return c("accent_red")
		"BLACK":  return Color.WHITE if current_mode == "dark" else Color(0.2, 0.2, 0.2)
		_:        return c("text_secondary")


## ── Persistence ──────────────────────────────────────────────────

func _load_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var data: Dictionary = json.data
			current_mode = data.get("mode", "dark")


func _save_config() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({"mode": current_mode}, "\t"))
