# MON-03 — Isometric Camera Rig

**Phase:** Phase 0 — Foundation & Architecture
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-01
**Blocks:** None (consumed by MON-04, Phase 1+)

---

## Scope
Create the isometric camera system — an orthographic Camera3D at the standard isometric angle that smoothly follows a target node.

## Acceptance Criteria
- [ ] `scenes/gameplay/IsometricCamera.tscn` scene created
- [ ] `scripts/core/isometric_camera.gd` script attached
- [ ] Camera uses orthographic projection
- [ ] Camera angle: ~35.264° pitch (true isometric = arctan(1/√2)), 45° yaw rotation
- [ ] Smooth follow: camera lerps to `target` node position each frame (`follow_speed` export variable)
- [ ] Optional zoom: mouse scroll adjusts `size` property within min/max bounds (`zoom_min`, `zoom_max` exports)
- [ ] `target` is an exported `NodePath` — can be assigned to any node (player, etc.)
- [ ] Works correctly in a test scene with a simple MeshInstance3D as target

## Boundaries — Do NOT Touch
- Do NOT implement camera rotation (locked isometric angle for now)
- Do NOT implement screen shake or effects — Phase 4 scope

## Notes
- True isometric angle: pitch ≈ 35.264° (not 30°). This gives equal foreshortening on all 3 axes.
- Godot orthographic: set `Camera3D.projection = PROJECTION_ORTHOGRAPHIC`, adjust `size` for zoom level
