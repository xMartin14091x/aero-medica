# SYN-03 — Patient Assessment Actions

**Phase:** Phase 1 — Core Gameplay Loop
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-01, MON-07
**Blocks:** ARC-01

---

## Scope
Implement the patient assessment action flow — when the player interacts with a patient (without equipment), present assessment options and execute them. This is the foundation for the BCLS/ALS protocol system in Phase 2.

## Acceptance Criteria
- [x] `scripts/gameplay/assessment_manager.gd` — handles patient assessment flow
- [x] When player interacts with a patient (no equipment held) → triggers assessment mode
- [x] Assessment actions available: "Check Airway", "Check Breathing", "Check Pulse", "Check Consciousness" (AVPU), "Check Bleeding"
- [x] Each assessment action reveals the corresponding patient state data (from MedicalStateComponent)
- [x] Signal: `assessment_performed(patient, action_type, result)` — consumed by UI and telemetry
- [x] TelemetryEmitter events: `assess_airway`, `assess_breathing`, `assess_pulse`, `assess_consciousness`, `assess_bleeding` with patient ID and result
- [x] Assessment results stored on patient entity as `assessed_conditions: Dictionary` via node meta (tracks what the player has checked)
- [x] Test: assessment flow verified — begin_assessment → perform_assessment → telemetry emit + meta storage
- [x] Bonus: `perform_assessment_by_name()` convenience method for Arcade ActionMenu wiring

## Boundaries — Do NOT Touch
- Do NOT implement treatment actions — Phase 2
- Do NOT implement BCLS/ALS protocol validation — Phase 2 (SYN-04)
- Do NOT implement the action menu UI — ARC-01 handles the visual menu
