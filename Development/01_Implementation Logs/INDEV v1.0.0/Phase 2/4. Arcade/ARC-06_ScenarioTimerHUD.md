# ARC-06 — Scenario Timer HUD

**Phase:** Phase 2 — Medical Protocol System
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** SYN-06
**Blocks:** None

---

## Scope
Create the scenario timer display in the HUD — countdown clock that communicates time pressure to the player.

## Acceptance Criteria
- [ ] `scenes/ui/hud/ScenarioTimer.tscn` — HUD element anchored to top-right of screen
- [ ] Displays remaining time in MM:SS format
- [ ] Normal state: white text on dark background
- [ ] Warning states: turns YELLOW at 50% time remaining, RED at 25%, PULSING RED at 10%
- [ ] Listens to TimePressureSystem.time_updated and time_warning signals
- [ ] Smooth number transition (no flickering)
- [ ] Font size readable at 1080p
- [ ] Test: scenario starts → timer counts down → colour changes at thresholds → timer hits 0

## Boundaries — Do NOT Touch
- Do NOT implement full HUD layout — Phase 7
- Do NOT implement pause functionality — Phase 7
- Keep this as a standalone HUD component that can be integrated into the full HUD later
