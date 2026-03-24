# ARC-11 — Environment Texture Variation System

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Arcade — UI/Creative
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** None

---

## Scope
Create grass tile variants using existing PBR texture assets (Grass1-4) so each level can have distinct ground appearance. Currently all levels share one Grass.tscn.

## Current State
- 4 grass texture folders exist: Grass1 (forest leaves), Grass2 (Rock063 — current), Grass3 (Ground037), Grass4 (Ground068)
- Grass3 and Grass4 have ready `.tres` material files
- Grass1 has textures but no `.tres` file
- Only 1 Grass.tscn exists, shared by all levels
- User has already changed Grass.tscn to use Grass3/Ground037 material

## Remaining Work
- [x] Create GrassV2.tscn using Grass2/Rock063 material (the original) — already existed
- [x] Create GrassV3.tscn using Grass4/Ground068 material — created 09-03-2026
- [x] Create Grass1 `.tres` material file from forest_leaves textures — `forest_leaves_02_4k.tres`
- [x] Create GrassV4.tscn using Grass1 material — created 09-03-2026
- [ ] Update level scenes to use appropriate grass variants per scenario theme (manual in editor)
- [x] Create SidewalkV2.tscn using Sidewalk3/PavingStones131 material — created 09-03-2026
- [ ] Document texture variation system for future asset additions

## Implementation Notes (09-03-2026)
- 4 grass variants now available: Grass.tscn (Ground037), GrassV2.tscn (Rock063), GrassV3.tscn (Ground068), GrassV4.tscn (forest_leaves)
- 2 sidewalk variants available: Sidewalk.tscn (PavingStones105), SidewalkV2.tscn (PavingStones131)
- All use identical StaticBody3D + BoxMesh + BoxShape3D structure with different material references
- Level scene assignment must be done manually in the Godot editor (drag variant .tscn into level)

## Acceptance Criteria
- [x] At least 3 grass variant .tscn files available
- [x] Each level can independently choose its ground texture
- [x] Changing one variant doesn't affect other levels
- [x] Materials render correctly with PBR (normal, roughness, AO)

## Boundaries — Do NOT Touch
- Do not modify existing Grass.tscn structure (only create new variants)
- Do not delete any texture assets
