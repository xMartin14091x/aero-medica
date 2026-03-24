# ARC-03 — First Scenario Environment (Road Traffic Accident)

**Phase:** Phase 1 — Core Gameplay Loop
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-09, MON-05 (tile system)
**Blocks:** None

---

## Scope
Build the first playable scenario environment — a Road Traffic Accident scene. Uses the tile system from Phase 0 with additional props. This is the primary test environment for the entire gameplay loop.

## Acceptance Criteria
- [ ] `scenes/environments/RoadTrafficAccident.tscn` — full scenario level scene
- [ ] Environment layout: road intersection with sidewalks and grass, using Road/Sidewalk/Grass tiles
- [ ] Placeholder vehicle props: 2-3 box meshes representing crashed cars at intersection
- [ ] Spawn points marked for 3 patients (varying positions around crash site)
- [ ] Spawn points marked for equipment (AED near ambulance area, bandages scattered, stretcher)
- [ ] NavigationRegion3D with baked NavMesh covering walkable areas
- [ ] Ambient lighting appropriate for daytime outdoor scene
- [ ] Corresponding scenario data file: `data/scenarios/scenario_rta.json` with patient/equipment spawn definitions
- [ ] Test: ScenarioManager loads scenario_rta.json → patients and equipment spawn at marked positions → player can walk around and interact

## Boundaries — Do NOT Touch
- Do NOT import final 3D assets yet — use placeholder coloured boxes for vehicles and props
- Do NOT implement hazards (fire, traffic) — Phase 4
- Do NOT implement audio — Phase 6

## Notes
- **Asset import note for Martin:** This is where you'll replace placeholder boxes with real assets in Phase 6. For now, focus on layout and gameplay flow
- Vehicle placeholders: large grey boxes (car-sized), rotated to suggest collision angle
- Consider sightlines — patient visibility from different approach angles matters for triage gameplay
