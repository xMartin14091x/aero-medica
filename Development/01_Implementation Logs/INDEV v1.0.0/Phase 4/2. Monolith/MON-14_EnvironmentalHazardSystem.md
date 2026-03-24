# MON-14 — Environmental Hazard System

**Phase:** Phase 4 — Dynamic Environment
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-09 (Phase 1)
**Blocks:** ARC-09, SYN-11

---

## Scope
Create the hazard system — fire spread zones, structural collapse zones, and traffic areas that the player must navigate around or secure. Hazards are defined per-scenario in scenario data.

## Acceptance Criteria
- [ ] `scripts/gameplay/hazard_system.gd` — manages all active hazards in a scenario
- [ ] `scripts/gameplay/hazard_zone.gd` — base class for individual hazard zones (Area3D)
- [ ] Hazard types: FIRE (damages player/patients over time), COLLAPSE (impassable, may expand), TRAFFIC (periodic danger)
- [ ] Hazard zones defined in scenario data: `hazards[]` with `{type, position, radius, spread_rate, initial_active}`
- [ ] Fire hazards: expand radius over time (`spread_rate`), damage any patient inside zone
- [ ] Collapse zones: block navigation (update NavMesh), may trigger at random intervals
- [ ] Traffic zones: periodic vehicle pass-through (danger window every N seconds)
- [ ] Signal: `hazard_activated(hazard)`, `hazard_expanded(hazard)`, `entity_in_hazard(entity, hazard_type)`
- [ ] Player receives warning when entering a hazard zone
- [ ] Test: scenario with fire hazard → fire spreads → patient inside takes damage → player warned

## Boundaries — Do NOT Touch
- Do NOT implement hazard visual effects — ARC-09
- Do NOT implement environmental audio — Phase 6
