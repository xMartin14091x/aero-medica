# ARC-21 — Main Menu Screen

**Phase:** Phase 7 — UI/UX & Localisation
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** All gameplay systems (Phases 0-6)
**Blocks:** None

---

## Scope
Create the main menu — the first screen players see. Professional, clean design that sets the medical simulation tone.

## Acceptance Criteria
- [x] `scenes/main/MainMenu.tscn` — full-screen menu scene with dark blue medical theme
- [x] AeroMedica title (font_size 48, blue accent) + subtitle from translation keys
- [x] Menu buttons: Start Tutorial, Select Scenario, Dashboard, Settings, Quit (300x48 each)
- [x] Background: dark gradient overlay (medical blue theme, Color(0.08, 0.1, 0.15))
- [x] Button hover triggers AudioSystem.play_ui_click() via scene tree discovery
- [x] Start Tutorial loads Tutorial.tscn via GameManager.change_scene()
- [x] Select Scenario navigates to ScenarioSelect.tscn
- [x] Dashboard emits dashboard_requested signal
- [x] Settings navigates to Settings.tscn
- [x] Quit shows AcceptDialog confirmation, then get_tree().quit()
- [x] GameManager.set_state(0) called on ready (MENU state)
- [x] All text uses tr() translation keys, updates on locale_changed signal
- [x] Test: all buttons navigate correctly, version label shows INDEV v1.0.0, locale switching works

## Boundaries — Do NOT Touch
- Do NOT implement user profiles/login — F11 scope
