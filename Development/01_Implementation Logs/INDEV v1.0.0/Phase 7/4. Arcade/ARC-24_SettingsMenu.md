# ARC-24 — Settings Menu

**Phase:** Phase 7 — UI/UX & Localisation
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** None (standalone UI)
**Blocks:** None

---

## Scope
Create the settings menu — audio controls, language selection, control remapping, and accessibility options.

## Acceptance Criteria
- [x] `scenes/main/Settings.tscn` — TabContainer with 4 tabs
- [x] **Audio tab:** Master/Music/SFX volume sliders (0-100, step 5) with percentage labels
- [x] **Language tab:** Thai/English toggle button, triggers LocalisationManager.toggle_locale()
- [x] **Controls tab:** Read-only display of WASD, E, Q, Esc, 1-5 bindings via translation keys
- [x] **Accessibility tab:** UI scale slider (0.8x-1.5x), high contrast toggle, colourblind patterns toggle
- [x] Settings persist to user://settings.json via JSON.stringify() / FileAccess
- [x] Apply button saves and applies all settings (audio via AudioSystem, scale via content_scale_factor)
- [x] Back button returns to MainMenu.tscn via GameManager.change_scene()
- [x] Test: volume sliders adjust AudioSystem, locale toggle switches language, settings persist across sessions

## Boundaries — Do NOT Touch
- Do NOT implement key remapping (stretch goal — only display current bindings)
- Do NOT implement graphics quality settings (not needed for isometric low-poly)
