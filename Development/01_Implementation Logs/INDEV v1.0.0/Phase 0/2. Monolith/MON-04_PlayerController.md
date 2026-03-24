# MON-04 — Player Controller

**Phase:** Phase 0 — Foundation & Architecture
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-01, MON-03
**Blocks:** None (consumed by Phase 1+)

---

## Scope
Create the EMT player character with isometric movement. The player must move in 8 directions using WASD/arrow keys, correctly oriented to the isometric camera angle.

## Acceptance Criteria
- [ ] `scenes/entities/player/Player.tscn` scene created with `CharacterBody3D` root
- [ ] `scripts/gameplay/player_controller.gd` script attached
- [ ] WASD/arrow key input mapped in `project.godot` Input Map (actions: `move_up`, `move_down`, `move_left`, `move_right`)
- [ ] Movement direction is rotated 45° to match isometric camera orientation (pressing W moves top-right on screen, not straight up)
- [ ] `move_speed` export variable for tuning
- [ ] Player has a placeholder visual (simple `MeshInstance3D` — capsule or box) with distinct facing indicator
- [ ] Collision shape (`CollisionShape3D`) attached for physics
- [ ] `NavigationAgent3D` node present (skeleton — pathfinding will be wired in Phase 1 for click-to-move)
- [ ] `InteractionArea` (`Area3D`) child node for detecting nearby interactables (radius export)
- [ ] Player moves smoothly at 60fps without jitter

## Boundaries — Do NOT Touch
- Do NOT implement click-to-move — Phase 1 scope
- Do NOT implement interaction logic — Phase 1 scope
- Do NOT implement inventory — Phase 1 scope
- Do NOT implement animations — placeholder mesh only

## Notes
- Isometric movement rotation: input vector rotated by -45° (or camera's Y rotation) so screen-relative input maps correctly to world-space movement
- `CharacterBody3D.move_and_slide()` for physics-aware movement
- The `InteractionArea` is a child `Area3D` with a `SphereShape3D` collider — it detects when interactable objects enter range but does NOT handle the interaction itself yet
