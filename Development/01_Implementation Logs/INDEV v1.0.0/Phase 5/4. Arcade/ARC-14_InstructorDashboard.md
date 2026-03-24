# ARC-14 — Instructor Dashboard View

**Phase:** Phase 5 — Dashboards & Scoring
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** SYN-14, ARC-11, ARC-12
**Blocks:** None

---

## Scope
Create the instructor/aggregate dashboard view — shows class/cohort performance overview. Designed for institutional B2B use but implemented locally for competition demo.

## Acceptance Criteria
- [x] `scenes/ui/dashboard/InstructorDashboard.tscn` — aggregate view
- [x] Summary cards: total students (simulated), average scores per axis, pass rate
- [x] Class radar chart: class average scores on RadarChart component
- [x] Weakest axis identifier: "Your class struggles most with [axis]" — highlighted orange
- [x] Student list: table with names, overall scores, per-axis scores, PASS/FAIL status
- [x] Click student → emits student_selected signal for ScenarioBreakdown navigation
- [x] For competition demo: 5 mock student profiles (Somchai, Nattaya, Worawit, Pimchanok, Thanakrit) with varied scores
- [x] Clean, professional layout suitable for showing to institutional stakeholders
- [x] Test: load mock cohort data → dashboard renders all sections → click student → signal emitted

## Boundaries — Do NOT Touch
- Do NOT implement real multi-user/networking — local mock data only
- Do NOT implement user authentication — F11 scope

## Notes
- This is a DEMO feature for the competition pitch — it shows what the B2B product would look like
- Mock data should be realistic (varied scores, some failing, some improving)
