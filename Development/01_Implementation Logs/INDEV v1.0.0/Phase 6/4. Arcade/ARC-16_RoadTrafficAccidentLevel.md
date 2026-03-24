# ARC-16 — Road Traffic Accident Level

**Phase:** Phase 6 — Content Expansion
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-16, ARC-03 (Phase 1 layout upgrade)
**Blocks:** None

---

## Scope
Upgrade the RTA environment from Phase 1 placeholder to full scenario level with imported 3D assets, proper lighting, and visual polish.

## Acceptance Criteria
- [x] `scenes/environments/RoadTrafficAccident.tscn` upgraded with debris, emergency vehicles, hazard zone
- [x] Placeholder vehicles enhanced: 3 crash vehicles + ambulance (white) + fire truck (red)
- [x] 3 patient spawn markers around crash site (PatientSpawn_01/02/03)
- [x] Equipment spawn markers: AED, Bandages, Stretcher positions
- [x] Street props: 6 traffic cones (orange cylinders), emergency vehicles with flashing lights
- [x] Proper lighting: DirectionalLight3D (daytime) + animated emergency OmniLight3D (red/blue alternating)
- [x] NavigationMesh baked at runtime with vehicle collision blocking paths
- [x] 7 debris pieces scattered around crash site with varied sizes/colors/rotations
- [x] Test: level generates with enhanced visuals, emergency lights animate in _process(), audio system wired

## Boundaries — Do NOT Touch
- Do NOT modify gameplay logic — visual upgrade only
- Do NOT add hazards not defined in scenario data
