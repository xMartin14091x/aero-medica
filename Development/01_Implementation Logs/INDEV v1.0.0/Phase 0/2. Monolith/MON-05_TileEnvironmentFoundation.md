# MON-05 — Tile Environment Foundation

**Phase:** Phase 0 — Foundation & Architecture
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-01, MON-03
**Blocks:** None (consumed by Phase 1+)

---

## Scope
Create the modular tile/environment system for building isometric levels. Includes base tile scenes, a simple GridMap or manual tile placement approach, and a test level that proves the camera + player + environment work together.

## Acceptance Criteria
- [ ] At least 3 base tile types created as reusable scenes: `Road.tscn`, `Sidewalk.tscn`, `Grass.tscn`
- [ ] Each tile is a `StaticBody3D` with a `MeshInstance3D` (placeholder box/plane with distinct colour per type) and `CollisionShape3D`
- [ ] Tiles snap to a 2m x 2m grid (configurable)
- [ ] `NavigationRegion3D` with baked `NavigationMesh` covering walkable tiles (for future pathfinding)
- [ ] Test scene `scenes/gameplay/TestLevel.tscn` created: 10x10 tile grid mixing road/sidewalk/grass, with Player and IsometricCamera
- [ ] Player can walk around the test level and the camera follows correctly
- [ ] No z-fighting, clipping, or visual artifacts at tile boundaries

## Boundaries — Do NOT Touch
- Do NOT create final art assets — placeholder colours only (grey=road, light grey=sidewalk, green=grass)
- Do NOT implement GridMap unless it clearly simplifies things — manual scene placement is acceptable for Phase 0
- Do NOT add environmental hazards — Phase 4 scope

## Notes
- Tile size 2m x 2m is a starting point — may be adjusted in Phase 1 based on feel
- Consider using `MeshLibrary` + `GridMap` if manual placement proves tedious, but keep it simple
- The NavigationMesh bake should exclude non-walkable tiles (future: walls, hazard zones)
