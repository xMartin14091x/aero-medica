# MON-15 — Random Event System

**Phase:** Phase 4 — Dynamic Environment
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-09, MON-14
**Blocks:** SYN-11

---

## Scope
Implement mid-scenario random events — unpredictable triggers that force the player to adapt. New patients arrive, equipment breaks, bystanders interfere.

## Acceptance Criteria
- [ ] `scripts/gameplay/random_event_system.gd` — manages event triggers during gameplay
- [ ] Events defined in scenario data: `random_events[]` with `{type, trigger_time_range, data}`
- [ ] Event types: NEW_PATIENT (spawn additional patient), EQUIPMENT_FAILURE (held/nearby equipment stops working), BYSTANDER (NPC enters scene, may help or hinder)
- [ ] NEW_PATIENT: spawns patient at defined position with defined medical state
- [ ] EQUIPMENT_FAILURE: selected equipment becomes unusable (player must find alternative)
- [ ] BYSTANDER: non-patient NPC enters interaction range (F12-ready: `dialogue_capable = true`)
- [ ] Signal: `random_event_triggered(event_type, event_data)`
- [ ] Events logged in telemetry: `random_event` with type and timestamp
- [ ] Trigger timing: random within defined time range (not same time every replay)
- [ ] Test: scenario with random events → events trigger at varied times → player must adapt

## Boundaries — Do NOT Touch
- Do NOT implement bystander AI/dialogue — F12 scope
- Do NOT implement visual effects for events — ARC-09
