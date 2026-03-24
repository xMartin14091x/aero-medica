# ARC-12 — Progress Over Time Graphs

**Phase:** Phase 5 — Dashboards & Scoring
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** SYN-14
**Blocks:** None

---

## Scope
Create line graph components showing skill improvement across multiple attempts. Visualises historical performance data.

## Acceptance Criteria
- [x] `scenes/ui/dashboard/LineChart.tscn` — custom Control node for line graphs
- [x] `scripts/ui/line_chart.gd` — custom drawing with `_draw()`
- [x] Method: `add_series(name, data_points, colour)` + `set_history_data(history, axes)` — renders line chart
- [x] X-axis: attempt number, Y-axis: score (0-100)
- [x] Can overlay multiple axes on one chart (colour-coded lines with legend)
- [x] Data point markers (small circles) at each attempt
- [x] Trend line: dashed line via linear regression showing overall direction
- [x] Labels: axis names in legend, grid labels at 0/25/50/75/100
- [x] Responsive sizing
- [x] Test: provide 5 data points → line chart renders → trend visible

## Boundaries — Do NOT Touch
- Do NOT implement data fetching — receives data from HistoryManager via parent UI
