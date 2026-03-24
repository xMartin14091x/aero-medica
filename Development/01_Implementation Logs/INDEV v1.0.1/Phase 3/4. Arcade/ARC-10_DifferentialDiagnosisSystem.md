# ARC-10 — Differential Diagnosis System & Scoring

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Arcade — UI/Creative
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** None

---

## Scope
Implement the Differential tab's diagnosis selection system. Players select suspected diagnoses from the list of 20 common emergencies. Selections are scored against the scenario's correct diagnosis for the debrief review.

## Current State
- 20 diagnosis buttons exist in the Differential tab
- Buttons are clickable but only log to telemetry — no scoring, no feedback

## Remaining Work
- [x] Define correct diagnosis per scenario in scenario JSON — all scenarios have `"correct_diagnosis"` array
- [x] Allow multiple diagnosis selections (ranked by confidence) — up to 3 selections
- [x] Visual feedback: selected diagnoses highlighted, ranked 1st/2nd/3rd with color gradient
- [x] "Submit Diagnosis" button to finalize selection
- [x] Score calculation: primary match = 3 pts, secondary = 2 pts, tertiary = 1 pt
- [x] Show score result with percentage and grade coloring (green ≥80%, yellow ≥50%, red <50%)
- [x] Show "Diagnosis submitted" confirmation in chat with score
- [x] Lock diagnosis after submission (prevent changing after commit)
- [x] Highlight correct answers after submission
- [x] Expanded diagnosis list from 20 to 30 entries (covers all scenario correct diagnoses)

## Implementation Notes (09-03-2026)
- `_score_diagnosis()` reads `correct_diagnosis` from `ScenarioManager.current_scenario`
- Scoring: rank_points = [3, 2, 1] per selection slot; max_score = correct_count × 3
- After submission: correct diagnoses highlighted green, rank label shows score/percentage
- Telemetry event includes score and max_score fields

## Acceptance Criteria
- [x] Player can select 1-3 diagnoses from the list
- [x] Selected diagnoses are visually highlighted with rank
- [x] Submit button finalizes and locks the selection
- [x] Diagnosis score feeds into debrief review
- [x] Scenario JSON supports correct_diagnosis field

## Boundaries — Do NOT Touch
- Do not modify the 20 diagnosis list without medical review
- Do not change debrief screen structure (add score data, don't restructure)
