## ThemeManager — Centralised visual theme for consistent art direction.
## Applies unified colour palette, typography, and panel styling across all UI.
extends Node

## Colour palette — medical blue theme.
const COL_BG_PRIMARY := Color(0.08, 0.1, 0.15)
const COL_BG_SECONDARY := Color(0.12, 0.14, 0.2)
const COL_BG_PANEL := Color(0.15, 0.17, 0.24)
const COL_ACCENT_BLUE := Color(0.3, 0.55, 0.9)
const COL_ACCENT_LIGHT := Color(0.4, 0.7, 1.0)
const COL_TEXT_PRIMARY := Color(0.92, 0.94, 0.98)
const COL_TEXT_SECONDARY := Color(0.65, 0.68, 0.78)
const COL_TEXT_DIM := Color(0.45, 0.48, 0.55)
const COL_SUCCESS := Color(0.2, 0.8, 0.3)
const COL_WARNING := Color(0.95, 0.75, 0.15)
const COL_ERROR := Color(0.9, 0.2, 0.15)
const COL_TRIAGE_GREEN := Color(0.1, 0.85, 0.1)
const COL_TRIAGE_YELLOW := Color(0.95, 0.9, 0.1)
const COL_TRIAGE_RED := Color(0.95, 0.15, 0.1)
const COL_TRIAGE_BLACK := Color(0.2, 0.2, 0.2)

## Typography sizes.
const FONT_TITLE := 48
const FONT_HEADER := 32
const FONT_SUBHEADER := 24
const FONT_BODY := 18
const FONT_CAPTION := 14
const FONT_SMALL := 12

## UI constants.
const BUTTON_MIN_HEIGHT := 48
const BUTTON_MIN_WIDTH := 200
const MARGIN_LARGE := 24
const MARGIN_MEDIUM := 16
const MARGIN_SMALL := 8

## Material palette for 3D environments.
## Ensures consistent colours across all levels.
const MAT_ROAD := Color(0.35, 0.35, 0.38)
const MAT_SIDEWALK := Color(0.72, 0.72, 0.72)
const MAT_GRASS := Color(0.25, 0.6, 0.18)
const MAT_WALL_EXTERIOR := Color(0.7, 0.68, 0.64)
const MAT_WALL_INTERIOR := Color(0.82, 0.8, 0.76)
const MAT_WOOD_DARK := Color(0.42, 0.28, 0.12)
const MAT_WOOD_LIGHT := Color(0.55, 0.38, 0.2)
const MAT_METAL := Color(0.6, 0.6, 0.62)
const MAT_VEHICLE_GREY := Color(0.5, 0.5, 0.55)
const MAT_VEHICLE_RED := Color(0.75, 0.12, 0.08)
const MAT_VEHICLE_WHITE := Color(0.92, 0.92, 0.92)
const MAT_DEBRIS := Color(0.45, 0.42, 0.4)
const MAT_CHAR := Color(0.18, 0.14, 0.1)


## Apply theme to a button.
static func style_button(btn: Button, size: int = FONT_BODY) -> void:
	btn.add_theme_font_size_override("font_size", size)
	btn.custom_minimum_size = Vector2(BUTTON_MIN_WIDTH, BUTTON_MIN_HEIGHT)


## Apply theme to a label.
static func style_label(label: Label, size: int = FONT_BODY, color: Color = COL_TEXT_PRIMARY) -> void:
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)


## Create a styled panel container.
static func create_panel(bg_color: Color = COL_BG_PANEL) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	style.content_margin_left = float(MARGIN_MEDIUM)
	style.content_margin_right = float(MARGIN_MEDIUM)
	style.content_margin_top = float(MARGIN_SMALL)
	style.content_margin_bottom = float(MARGIN_SMALL)
	panel.add_theme_stylebox_override("panel", style)
	return panel
