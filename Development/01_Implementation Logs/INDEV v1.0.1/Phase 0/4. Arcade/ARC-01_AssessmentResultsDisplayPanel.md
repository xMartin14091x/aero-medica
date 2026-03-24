# ARC-01 — Assessment Results Display Panel

**Phase:** Phase 0 — Bug Fixes & Tech Debt
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** None
**Priority:** Medium

---

## Scope

Create a visual feedback panel that displays assessment results to the player after performing a patient assessment. Currently, the assessment backend works correctly (data is computed, stored, logged to telemetry) but the player sees nothing — the ActionMenu closes and no result is shown.

## Current Signal Flow (Broken UX)

```
Player selects "Check Airway" in ActionMenu
  → AssessmentManager.perform_assessment_by_name("Check Airway")
  → Returns { "airway_status": "CLEAR" }     ← NEVER SHOWN
  → assessment_performed signal emitted       ← NOTHING LISTENS
  → ActionMenu.close_menu()                   ← Menu closes, no result
```

## Implementation

1. **Create AssessmentResultPanel scene** (`scenes/ui/hud/AssessmentResultPanel.tscn`):
   - PanelContainer with Label for assessment name and RichTextLabel for result
   - Semi-transparent background, positioned center-bottom of screen
   - Auto-hide after 3 seconds with fade animation

2. **Add to GameHUD** — instance AssessmentResultPanel as child of the HUD CanvasLayer

3. **Wire signal in HUDController** (`scripts/ui/hud_controller.gd`):
   - Connect `AssessmentManager.assessment_performed` signal
   - On signal: format result dict into readable text, show panel for 3 seconds
   - Format examples:
     - "Airway: CLEAR" / "Airway: OBSTRUCTED"
     - "Pulse: Present" / "Pulse: Absent"
     - "Breathing: 16 bpm (Normal)" / "Breathing: 6 bpm (Abnormal)"
     - "Consciousness: Alert (A)" / "Consciousness: Unresponsive (U)"
     - "Bleeding: None" / "Bleeding: Severe (3)"

4. **Keep ActionMenu open** after assessment — don't auto-close so player can check multiple things

## Files to Create

- `scenes/ui/hud/AssessmentResultPanel.tscn`
- `scripts/ui/assessment_result_panel.gd`

## Files to Modify

- `scripts/ui/hud_controller.gd` — Wire `assessment_performed` signal to result panel
- `scenes/ui/hud/GameHUD.tscn` — Add AssessmentResultPanel instance

## Acceptance Criteria

- [ ] After selecting any assessment action, result text appears on screen
- [ ] Result panel shows for 3 seconds then fades out
- [ ] All 5 assessment types display correctly formatted results
- [ ] ActionMenu stays open after assessment (player can check multiple things)
- [ ] Panel does not overlap with ActionMenu
- [ ] Panel works for both conscious and unconscious patients

## Boundaries — Do NOT Touch

- Do NOT modify AssessmentManager logic — it already works correctly
- Do NOT modify ActionMenu behavior beyond keeping it open after assessment
- Do NOT add new assessment types
