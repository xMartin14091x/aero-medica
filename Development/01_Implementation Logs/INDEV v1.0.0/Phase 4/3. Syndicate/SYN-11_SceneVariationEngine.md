# SYN-11 — Scene Variation Engine

**Phase:** Phase 4 — Dynamic Environment
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** MON-09, MON-14, MON-15
**Blocks:** None

---

## Scope
Implement scenario randomisation — same scenario template generates different experiences each playthrough. Vary patient positions, conditions, hazard placements, and equipment locations within defined bounds.

## Acceptance Criteria
- [ ] `scripts/gameplay/scene_variation.gd` — pre-processes scenario data before spawning
- [ ] Method: `randomise_scenario(scenario_data: Dictionary, seed: int) -> Dictionary` — returns modified scenario data
- [ ] Patient positions: randomised within defined zones (not exact positions)
- [ ] Patient conditions: vary severity within range (e.g., bleeding_severity 1-3, randomised per play)
- [ ] Equipment positions: scattered within defined areas (not always same spot)
- [ ] Hazard placements: vary initial position/radius within bounds
- [ ] Seed-based: same seed = same layout (for reproducible testing/competition demos)
- [ ] Optional: difficulty scaling — higher difficulty = more patients, faster deterioration, fewer equipment
- [ ] Test: load same scenario 3 times → different patient positions/conditions each time

## Boundaries — Do NOT Touch
- Do NOT modify the scenario data format — work with existing structure from MON-09
- Do NOT implement difficulty selection UI — Phase 7
