# ARC-15 — Tutorial Scenario Level

**Phase:** Phase 6 — Content Expansion
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-16
**Blocks:** None

---

## Scope
Build the tutorial scenario environment — a simple, guided walkthrough level with UI hints. Teaches controls, assessment, triage, and treatment without time pressure.

## Acceptance Criteria
- [x] `scenes/gameplay/Tutorial.tscn` — small environment (park/sidewalk area, 10x10 grid)
- [x] Simple layout: open area with clear sidewalk path to single patient in park
- [x] UI hint overlays: "Press W/A/S/D to move around" shown via HintLayer CanvasLayer
- [x] Hints appear sequentially via `_show_hint()` with dedup by hint_id
- [x] No time pressure (tutorial level has no timer integration)
- [x] One patient spawn (PatientSpawn_01) in park area, 5 equipment spawn points nearby
- [x] All equipment types available: 5 EquipmentSpawn markers placed around park
- [x] Hint system with auto-hide after 5 seconds, PanelContainer UI
- [x] **Asset import:** Placeholder boxes used for park benches, tile scenes for ground (ready for asset replacement)
- [x] Test: level generates grid, places spawns, creates hint UI, wires camera and audio

## Boundaries — Do NOT Touch
- Do NOT implement adaptive difficulty
- Do NOT skip the tutorial for returning players (add skip option in Phase 7 settings)
