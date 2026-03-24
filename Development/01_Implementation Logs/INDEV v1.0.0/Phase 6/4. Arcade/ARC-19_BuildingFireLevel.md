# ARC-19 — Building Fire Evacuation Level

**Phase:** Phase 6 — Content Expansion
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-16, MON-14 (hazard system)
**Blocks:** None

---

## Scope
Build the Building Fire scenario — hazard navigation + patient extraction + treatment prioritisation. Combines medical gameplay with environmental danger.

## Acceptance Criteria
- [x] `scenes/gameplay/BuildingFire.tscn` — building interior (14x18 grid) with exterior staging area
- [x] 3 fire hazard zones with OmniLight3D effects (orange/red glow at fire origin + spread positions)
- [x] Collapse zone in Room 3 blocking corridor (debris props + negative OmniLight3D darkening)
- [x] 3 patients: Room 2 office (conscious), corridor (trapped under beam), Room 3 collapse zone (critical)
- [x] Smoke effect via darkened OmniLight3D with warm/smoky tint in collapse areas
- [x] Safe zone: exterior staging area (z=12..17) with ambulance placeholder, blue triage tarp, floodlight
- [x] Interior rooms with walls: storage (Room 1), office (Room 2), collapse (Room 3), fire origin (Room 4)
- [x] Door gaps in wall segments for corridor access and building entrance
- [x] Test: level generates building shell, interior walls, fire lights, 3 patient spawns, 4 equipment spawns in staging area, FIRE_ALARM audio

## Boundaries — Do NOT Touch
- Do NOT implement structural collapse simulation (physics) — use static blocked zones
