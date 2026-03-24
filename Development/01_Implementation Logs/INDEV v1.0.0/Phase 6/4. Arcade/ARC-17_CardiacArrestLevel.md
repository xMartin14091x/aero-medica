# ARC-17 — Cardiac Arrest Level

**Phase:** Phase 6 — Content Expansion
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-16
**Blocks:** None

---

## Scope
Build the Cardiac Arrest scenario environment — focused single-patient BLS scenario in an indoor/office setting.

## Acceptance Criteria
- [x] `scenes/gameplay/CardiacArrest.tscn` — indoor office environment (8x10 grid with walls)
- [x] Single patient spawn (PatientSpawn_01) on floor next to desk
- [x] AED spawn (EquipmentSpawn_01) and first aid kit (EquipmentSpawn_02) nearby, oxygen (EquipmentSpawn_03) in hallway
- [x] Indoor props: office desk, chair, filing cabinet, bookshelf, water cooler — enclosed office feel
- [x] Walls with doorway gap (east wall), internal partition separating office from entry hall
- [x] Indoor lighting: overhead OmniLight3D (cool white fluorescent), hallway light, dim DirectionalLight3D window ambient
- [x] Tight 8x10 space forces focused gameplay — patient immediately visible upon entry
- [x] Test: level generates walls/furniture/lighting, places spawn markers, bakes NavigationMesh, wires CARDIAC_INDOOR audio

## Boundaries — Do NOT Touch
- Do NOT implement bystander interaction — F12 scope
