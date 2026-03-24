# SYN-04 — BCLS/ALS Protocol Definitions

**Phase:** Phase 2 — Medical Protocol System
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** MON-10
**Blocks:** SYN-05

---

## Scope
Define the gold-standard BCLS/ALS protocol sequences as data — the correct action order for each patient condition. These serve as the reference against which player performance is measured.

## Acceptance Criteria
- [x] `data/protocols/bcls_protocol.json` — 9-step BLS sequence (AHA/Thai Red Cross)
- [x] `data/protocols/als_protocol.json` — 10-step ALS sequence with advanced airway
- [x] `data/protocols/start_triage.json` — START triage decision tree + tag definitions
- [x] `scripts/medical/protocol_validator.gd` — validates player action sequences against gold standard
- [x] Protocol format: ordered list of `{action, condition, required_equipment, time_window_seconds}`
- [x] Method: `validate_sequence(patient_state, player_actions[]) -> Dictionary` — returns correct_steps, missed_steps, wrong_order_steps, adherence_percentage, missed_critical
- [x] BLS: Scene safety → Response → Call help → Breathing → Pulse → Airway → CPR → AED → Reassess
- [x] START: decision tree with 6 nodes → GREEN/YELLOW/RED/BLACK tag assignment
- [x] Test: validator scores order-sensitive adherence with half-credit for wrong-order steps

## Boundaries — Do NOT Touch
- Do NOT implement the telemetry scoring — Phase 3/5
- Do NOT implement treatment effects — MON-10 handles that

## Notes
- Protocol data should be evidence-based and follow Thai Red Cross / AHA standards
- The validator compares ORDER of actions, not just presence — doing CPR before checking airway is an error
