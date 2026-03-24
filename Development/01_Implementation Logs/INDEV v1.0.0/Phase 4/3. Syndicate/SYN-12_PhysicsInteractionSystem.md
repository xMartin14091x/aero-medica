# SYN-12 — Physics Interaction System

**Phase:** Phase 4 — Dynamic Environment
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-01 (Phase 1)
**Blocks:** None

---

## Scope
Implement lightweight physics interactions — movable debris, openable doors, draggable stretchers. Extends the interaction system to handle physics-based objects.

## Acceptance Criteria
- [ ] `scripts/gameplay/physics_interactable.gd` — extends InteractableComponent for physics objects
- [ ] Movable debris: RigidBody3D objects player can push/pull to clear paths
- [ ] Openable doors: AnimatableBody3D with open/close states, interaction toggles
- [ ] Draggable stretcher: player can drag stretcher to patient → load patient → drag to safety
- [ ] Patient loading: interact with stretcher near patient → patient attaches to stretcher
- [ ] Physics interactions logged in telemetry: `physics_interact` with object_type and action
- [ ] Clear paths affect navigation: NavMesh updates when debris is moved (runtime rebake)
- [ ] Test: push debris → path clears → NavMesh updates → drag stretcher to patient → load → move

## Boundaries — Do NOT Touch
- Do NOT implement complex ragdoll physics
- Do NOT implement vehicle physics (vehicles are static props)
