# MON-16 — Scenario Data Files (All 5 Scenarios)

**Phase:** Phase 6 — Content Expansion
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-09, MON-10, MON-14, MON-15 (Phases 1-4)
**Blocks:** ARC-15 through ARC-19

---

## Scope
Create the complete scenario data definitions for all 5 scenarios. Each file defines patients, equipment, hazards, random events, correct protocols, and time limits. This is the content that drives all scenario environments.

## Acceptance Criteria
- [ ] `data/scenarios/scenario_tutorial.json` — Tutorial: 1 patient (conscious, minor bleeding), all equipment available, no time limit, no hazards, guided hints enabled
- [ ] `data/scenarios/scenario_rta.json` — Road Traffic Accident: 3 patients (varying severity), vehicle debris, 180s time limit, no random events
- [ ] `data/scenarios/scenario_cardiac.json` — Cardiac Arrest: 1 patient (cardiac arrest), AED + CPR equipment, 120s time limit, focused BLS protocol
- [ ] `data/scenarios/scenario_mci.json` — Mass Casualty: 5+ patients, limited equipment (3 bandages, 1 AED, 1 stretcher), 300s time limit, START triage required, 1 random event
- [ ] `data/scenarios/scenario_fire.json` — Building Fire: 3 patients, fire hazards (expanding), collapse zones, 240s time limit, 2 random events
- [ ] Each scenario defines: `correct_protocol_sequence` per patient for protocol validation
- [ ] Each scenario defines: `difficulty_rating` (1-5 stars)
- [ ] All scenarios validated: load via ScenarioManager → entities spawn correctly
- [ ] Test: load each of the 5 scenarios → patients/equipment/hazards spawn → timer starts → protocol data available

## Boundaries — Do NOT Touch
- Do NOT build the environment scenes (levels) — ARC-15 through ARC-19
- Do NOT modify the scenario data format — use existing structure from MON-09

## Notes
- **This is the most medically critical ticket.** Protocol sequences must be evidence-based (Thai Red Cross / AHA standards)
- Tutorial scenario should have `guided_hints: true` flag for ARC-15 to use
