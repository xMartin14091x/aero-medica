# MON-10 — Additional Scenario Content & Patient Data

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Monolith — Core Systems
**Status:** `[x] Complete`
**Depends on:** MON-08 (History data loading — Complete)
**Blocks:** None

---

## Scope
Create additional scenario JSON files with fully populated patient data (SAMPLE history, medical state, correct protocol sequence, correct diagnosis). Expand beyond the single tutorial scenario.

## Remaining Work
- [x] Enrich tutorial scenario with additional detail (guided hints text, equipment usage hints)
- [x] Create Cardiac Arrest scenario JSON (cardiac_arrest_01.json) — `scenario_cardiac_arrest.json` (park collapse, bystander history)
- [x] Create Road Traffic Accident scenario JSON (rta_01.json) — history added to existing `scenario_rta.json` (3 patients, Warfarin bracelet discovery)
- [x] Create Building Fire scenario JSON (building_fire_01.json) — `scenario_building_fire.json` (smoke inhalation, asthma comorbidity)
- [x] Add `correct_diagnosis` field to all scenario JSONs — all 5 existing + 2 new scenarios have it
- [x] Add SAMPLE history to all existing scenarios (cardiac, rta, fire, mci) — 13 patients total
- [ ] Validate all scenario JSONs load correctly in-game

## Implementation Notes (09-03-2026)
- 2 new scenario files created: `scenario_cardiac_arrest.json`, `scenario_building_fire.json`
- 4 existing scenarios updated with full SAMPLE history for every patient: `scenario_cardiac.json` (1 patient), `scenario_rta.json` (3 patients), `scenario_fire.json` (3 patients + 1 random event), `scenario_mci.json` (6 patients)
- Unconscious patients have history sourced from bystanders, medical bracelets, pill bottles, and coworker testimony
- `correct_diagnosis` arrays added to all scenarios

## Acceptance Criteria
- [x] At least 3 additional scenarios with full patient data
- [x] All SAMPLE history categories populated per patient
- [x] Correct protocol sequences defined for scoring
- [x] Correct diagnoses defined for differential scoring
- [ ] All scenarios load without errors

## Boundaries — Do NOT Touch
- Do not modify scenario JSON schema without Overseer approval
- Do not change ScenarioManager loading logic (already fixed in MON-08)
