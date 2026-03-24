# MON-08 — Equipment Entity Base

**Phase:** Phase 1 — Core Gameplay Loop
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-01, MON-06 (Phase 0)
**Blocks:** SYN-02

---

## Scope
Create base equipment entities — interactable objects the player can pick up and use. Initial set: AED, Bandage, Splint, Oxygen Mask, Stretcher. All use placeholder meshes.

## Acceptance Criteria
- [ ] `scenes/entities/equipment/EquipmentBase.tscn` base scene (StaticBody3D + InteractableComponent + EquipmentData)
- [ ] `scripts/gameplay/equipment_data.gd` Resource class with exports: `equipment_name: String`, `equipment_type: String` (enum: AED, BANDAGE, SPLINT, OXYGEN_MASK, STRETCHER), `use_label: String`
- [ ] 5 equipment variant scenes inheriting from EquipmentBase: `AED.tscn`, `Bandage.tscn`, `Splint.tscn`, `OxygenMask.tscn`, `Stretcher.tscn`
- [ ] Each has a distinct placeholder mesh (coloured box, different sizes) and CollisionShape3D
- [ ] InteractableComponent configured with appropriate `interaction_label` per equipment type
- [ ] Equipment can be placed in TestLevel and detected by player's InteractionArea

## Boundaries — Do NOT Touch
- Do NOT implement pickup/inventory logic — SYN-02
- Do NOT implement equipment usage effects — Phase 2
- Do NOT import final 3D models yet — placeholder meshes only
