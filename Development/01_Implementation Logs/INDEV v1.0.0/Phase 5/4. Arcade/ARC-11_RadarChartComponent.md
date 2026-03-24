# ARC-11 — Radar Chart Component

**Phase:** Phase 5 — Dashboards & Scoring
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** SYN-13
**Blocks:** ARC-13

---

## Scope
Create a reusable radar chart (spider chart) Control node for displaying the 5 clinical skill axes. Core visual component of the dashboard.

## Acceptance Criteria
- [x] `scenes/ui/dashboard/RadarChart.tscn` — custom Control node
- [x] `scripts/ui/radar_chart.gd` — custom drawing with `_draw()`
- [x] 5-axis radar: Triage Speed, Protocol Accuracy, Decision Quality, Equipment Handling, Patient Outcome
- [x] Method: `set_scores(scores: Dictionary)` — updates chart with animation
- [x] Animated fill: scores animate from 0 to value on display (smooth tween)
- [x] Colour-coded: fill colour changes based on overall score (red < 40, yellow 40-70, green > 70)
- [x] Axis labels displayed at each point
- [x] Grid lines at 25%, 50%, 75%, 100% for reference
- [x] Responsive sizing (works at different UI panel sizes)
- [x] Test: set_scores with known values → chart renders correctly → animation plays

## Boundaries — Do NOT Touch
- Do NOT implement line charts — ARC-12
- Do NOT implement data loading — chart receives data via set_scores()
