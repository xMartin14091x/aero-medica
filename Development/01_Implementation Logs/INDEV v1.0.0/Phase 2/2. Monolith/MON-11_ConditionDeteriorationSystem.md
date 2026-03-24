# MON-11 — Condition Deterioration System

**Phase:** Phase 2 — Medical Protocol System
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-10
**Blocks:** SYN-06

---

## Scope
Implement time-based patient deterioration — untreated conditions worsen over time. Bleeding increases, consciousness drops, cardiac arrest becomes death. Configurable per-scenario rates.

## Acceptance Criteria
- [ ] `scripts/medical/deterioration_system.gd` — attached to each Patient entity
- [ ] Exports: `deterioration_rate: float` (speed multiplier), `deterioration_enabled: bool`
- [ ] Bleeding: severity increases by 1 level every N seconds if untreated
- [ ] Airway obstruction: if untreated → breathing_rate drops → UNCONSCIOUS → CARDIAC_ARREST
- [ ] CARDIAC_ARREST: if no CPR/AED within time window → DEAD
- [ ] UNCONSCIOUS: if airway not cleared within time → CARDIAC_ARREST
- [ ] Deterioration pauses while player is actively treating the patient
- [ ] Signal: `condition_worsened(patient, modifier, old_value, new_value)`
- [ ] Configurable via scenario data: per-patient deterioration rates
- [ ] Test: leave bleeding patient untreated → bleeding severity rises → eventually UNCONSCIOUS

## Boundaries — Do NOT Touch
- Do NOT implement recovery/healing over time — treatment is instant stabilisation
- Do NOT implement environmental damage to patients — Phase 4
