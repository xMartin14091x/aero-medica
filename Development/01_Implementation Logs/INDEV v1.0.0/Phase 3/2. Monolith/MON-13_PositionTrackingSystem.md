# MON-13 — Position Tracking System

**Phase:** Phase 3 — Telemetry & AI Reviewer
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-12
**Blocks:** SYN-07

---

## Scope
Record player position at regular intervals for movement pattern analysis — generates heatmap data showing where the player spent time and how they navigated the scene.

## Acceptance Criteria
- [ ] `scripts/telemetry/position_tracker.gd` — attached to Player
- [ ] Records player world position every 1 second (configurable `tracking_interval` export)
- [ ] Stores as array of `{position: Vector3, timestamp: float}`
- [ ] Also tracks: `time_in_zone` — accumulates time spent near each patient (within interaction radius)
- [ ] Data included in TelemetryCollector session export as `movement_data` field
- [ ] Method: `get_heatmap_data() -> Array` — returns position samples for visualisation
- [ ] Method: `get_patient_proximity_times() -> Dictionary` — returns time spent near each patient
- [ ] Tracking starts/stops with TelemetryCollector session
- [ ] Test: walk around test level → export session → movement_data contains position samples at 1s intervals

## Boundaries — Do NOT Touch
- Do NOT implement heatmap visualisation — Phase 5 dashboard
- Do NOT implement movement scoring — Phase 5
