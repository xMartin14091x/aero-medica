# MON-09 — Scenario Data Format & Loader

**Phase:** Phase 1 — Core Gameplay Loop
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-01, MON-07, MON-08
**Blocks:** ARC-03

---

## Scope
Implement the ScenarioManager singleton — load scenario definitions from data files, spawn patients and equipment at defined positions, manage the scenario lifecycle (start → running → complete).

## Acceptance Criteria
- [ ] `scripts/core/scenario_manager.gd` fully implemented (was skeleton autoload from Phase 0)
- [ ] Scenario data format defined as Godot Resource (`.tres`) or JSON with fields: `scenario_id`, `scenario_name`, `environment_scene_path`, `time_limit_seconds`, `patients[]` (position, persona, initial_state), `equipment[]` (type, position), `correct_protocol_sequence[]`
- [ ] `data/scenarios/scenario_tutorial.json` — first test scenario definition (simple: 1 patient, 2 equipment items)
- [ ] `load_scenario(path)` → parses data → changes scene to environment → spawns patients + equipment at positions
- [ ] `start_scenario()` → begins timer, sets GameManager state to PLAYING, calls TelemetryCollector.start_session()
- [ ] `end_scenario()` → stops timer, sets GameManager state to DEBRIEF, calls TelemetryCollector.end_session()
- [ ] Signal: `scenario_loaded(scenario_data)`, `scenario_started()`, `scenario_ended(results: Dictionary)`
- [ ] Test: load tutorial scenario, verify patients and equipment spawn at correct positions

## Boundaries — Do NOT Touch
- Do NOT implement time pressure / deterioration — Phase 2
- Do NOT implement scoring — Phase 5
- Do NOT implement AI review trigger — Phase 3
