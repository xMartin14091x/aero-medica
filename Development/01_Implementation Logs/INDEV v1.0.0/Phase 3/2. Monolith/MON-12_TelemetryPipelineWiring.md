# MON-12 — Telemetry Pipeline Wiring

**Phase:** Phase 3 — Telemetry & AI Reviewer
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-06, SYN-01, SYN-02, SYN-03 (Phase 0/1)
**Blocks:** SYN-07, SYN-08

---

## Scope
Wire all gameplay actions into the telemetry pipeline — connect every TelemetryEmitter to the TelemetryCollector singleton. Every player action must be logged with full context.

## Acceptance Criteria
- [ ] TelemetryEmitter on Player auto-connects to TelemetryCollector on _ready()
- [ ] All interaction events logged: `interact`, `equipment_pickup`, `equipment_use`, `equipment_drop`
- [ ] All assessment events logged: `assess_airway`, `assess_breathing`, `assess_pulse`, `assess_consciousness`, `assess_bleeding`
- [ ] All triage events logged: `triage_assign` with patient_id, assigned_tag, correct_tag
- [ ] All treatment events logged: `treatment_applied` with equipment_type, patient_id, was_correct
- [ ] Scenario lifecycle events: `scenario_started`, `scenario_ended`, `scenario_time_expired`
- [ ] Every event includes timestamp (ms since scenario start) and player position at time of action
- [ ] Test: play through a full scenario → export JSON → verify all events are captured with correct timestamps

## Boundaries — Do NOT Touch
- Do NOT implement scoring/analysis — Phase 5
- Do NOT implement position tracking (separate system) — MON-13
