# SYN-02 — Equipment Inventory System

**Phase:** Phase 1 — Core Gameplay Loop
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-01, MON-08
**Blocks:** None (consumed by Phase 2+)

---

## Scope
Implement the equipment pickup, carry, and use system. Player can pick up equipment from the ground, carry one item at a time, and use it on a patient.

## Acceptance Criteria
- [x] `scripts/gameplay/inventory_component.gd` — attached to Player
- [x] `held_item: EquipmentData` — currently held equipment (null if empty)
- [x] Signal: `item_picked_up(equipment_data)`, `item_used(equipment_data, target)`, `item_dropped(equipment_data)`
- [x] Interacting with equipment on ground → picks it up (removes from scene, stores in inventory)
- [x] Interacting with patient while holding equipment → uses equipment on patient (emits `item_used`)
- [x] Drop action (Q key) → drops held item back into scene at player position
- [x] TelemetryEmitter events: `equipment_pickup`, `equipment_use`, `equipment_drop` with equipment type and target
- [x] Visual indicator: held equipment reparented to HeldItemMount (Node3D child of Player, offset 0.4, 0.8, 0)
- [x] Test: pickup → carry → use → drop flow verified via routing in InteractionManager

## Boundaries — Do NOT Touch
- Do NOT implement equipment effects on patient state — Phase 2
- Do NOT implement multiple-item inventory — carry one item only for now
