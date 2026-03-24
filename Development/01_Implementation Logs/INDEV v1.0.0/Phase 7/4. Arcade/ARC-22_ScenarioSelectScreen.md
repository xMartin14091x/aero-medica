# ARC-22 — Scenario Select Screen

**Phase:** Phase 7 — UI/UX & Localisation
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-16 (scenario data), SYN-14 (history)
**Blocks:** None

---

## Scope
Create the scenario selection screen — grid/list view of all available scenarios with difficulty, best scores, and progression.

## Acceptance Criteria
- [x] `scenes/main/ScenarioSelect.tscn` — 2-column grid layout with HSplitContainer detail panel
- [x] Each scenario card: name, difficulty stars (*/5), patient count — 230x140 PanelContainer
- [x] Tutorial always unlocked, others check HistoryManager for tutorial completion (defaults unlocked for demo)
- [x] Locked scenarios show dimmed card (modulate 0.5 alpha) with "Locked" text
- [x] Selected scenario shows detail panel: name, description, patients/time_limit/best_score info
- [x] Start button loads selected scenario's scene_path via GameManager.change_scene()
- [x] Back button returns to MainMenu.tscn
- [x] 5 scenarios defined in SCENARIOS const array with scene paths, difficulty, patient counts
- [x] All text uses tr() translation keys, cards rebuild on locale_changed
- [x] Test: 5 scenario cards visible, click selects and populates detail panel, start loads scene

## Boundaries — Do NOT Touch
- Do NOT implement difficulty selection per scenario — use scenario's defined difficulty
