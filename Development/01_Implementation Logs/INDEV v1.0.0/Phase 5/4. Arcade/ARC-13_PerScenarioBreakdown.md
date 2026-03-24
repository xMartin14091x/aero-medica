# ARC-13 — Per-Scenario Breakdown View

**Phase:** Phase 5 — Dashboards & Scoring
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** SYN-13, ARC-11
**Blocks:** None

---

## Scope
Create the detailed per-scenario score breakdown screen — shows all 5 skill axes, pass/fail per axis, patient-by-patient results, and the radar chart for a specific scenario attempt.

## Acceptance Criteria
- [x] `scenes/ui/dashboard/ScenarioBreakdown.tscn` — detailed result view
- [x] Header: scenario name, date, overall score, PASS/FAIL badge
- [x] RadarChart (ARC-11) showing the 5 axis scores
- [x] Per-axis detail: score value, pass/fail threshold, bar chart representation
- [x] Per-patient cards: patient name, condition, triage tag (correct/incorrect), treatment applied, outcome
- [x] Timeline view: key actions in chronological order (simplified action log)
- [x] "View AI Review" button → opens ARC-07 review panel for this session
- [x] "Export" button → triggers SYN-15 data export
- [x] Scrollable layout for scenarios with many patients
- [x] Test: load a completed scenario's data → all sections populated → scores match calculated values

## Boundaries — Do NOT Touch
- Do NOT implement the instructor/cohort view — ARC-14
