# MON-10 — Patient Medical State Machine

**Phase:** Phase 2 — Medical Protocol System
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-07 (Phase 1)
**Blocks:** MON-11, SYN-04

---

## Scope
Implement the full patient medical state machine — state transitions, modifier tracking, and treatment response. Each patient is a dynamic medical entity whose condition changes based on player actions and time.

## Acceptance Criteria
- [ ] `scripts/medical/medical_state_component.gd` fully implemented (was skeleton from Phase 1)
- [ ] State enum: CONSCIOUS, UNCONSCIOUS, CARDIAC_ARREST, DEAD
- [ ] Modifiers as exports: `bleeding_severity: int` (0-3), `airway_status: String` (clear/obstructed), `breathing_rate: float`, `pulse_present: bool`
- [ ] Signal: `state_changed(old_state, new_state)`, `modifier_changed(modifier_name, old_value, new_value)`
- [ ] Method: `apply_treatment(treatment_type: String) -> bool` — returns true if treatment was correct for current state
- [ ] Method: `get_triage_priority() -> String` — returns correct START triage colour based on current state
- [ ] State transitions are rule-based: e.g., pulse_present=false + no CPR within time → DEAD
- [ ] Treatment mapping: correct treatment stabilises/improves, incorrect treatment has no effect (logged as error)

## Boundaries — Do NOT Touch
- Do NOT implement time-based deterioration — MON-11
- Do NOT implement triage tag UI — ARC-04
