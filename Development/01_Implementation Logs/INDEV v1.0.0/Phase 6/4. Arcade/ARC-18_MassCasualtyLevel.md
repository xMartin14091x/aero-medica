# ARC-18 — Mass Casualty Event Level

**Phase:** Phase 6 — Content Expansion
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-16
**Blocks:** None

---

## Scope
Build the Mass Casualty Event scenario — large outdoor area with 5+ patients, limited resources, START triage under extreme pressure. The most challenging scenario.

## Acceptance Criteria
- [x] `scenes/gameplay/MassCasualty.tscn` — large outdoor park/plaza (20x20 grid with road perimeter)
- [x] 6 patient positions spread across the park (near fountain, debris, paths, benches, south/east areas)
- [x] Limited equipment: 3 EquipmentSpawn markers at park edges (west/east/north — forces movement decisions)
- [x] Open layout with central fountain, cross-paths, diagonal paths — patients visible from distance
- [x] Triage staging area: blue tarp prop near park entrance (south side)
- [x] Props: 4 park benches, central fountain (CylinderMesh), 6 trees (trunk+canopy), overturned vendor cart, debris
- [x] 20x20 grid large enough for movement tracking; emergency vehicle lights (red/blue OmniLight3D) at west entrance
- [x] Test: level generates large open park, 6 patient spawns, 3 equipment spawns, trees/fountain/debris, MCI_CROWD audio

## Boundaries — Do NOT Touch
- Do NOT implement patient transport mechanics beyond stretcher drag (SYN-12)
