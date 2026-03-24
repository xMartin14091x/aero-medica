# MON-01 — Equipment Pickup Physics Fix

**Phase:** Phase 0 — Bug Fixes & Tech Debt
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** None
**Priority:** Critical

---

## Scope

Fix the physics conflict caused by reparenting `StaticBody3D` equipment entities under the player's `CharacterBody3D` during pickup. Currently, AED and Oxygen Mask cause indefinite leftward sliding, and Bandage causes the player to freeze in place.

## Root Cause

`InventoryComponent.try_pickup()` (line 46–49) reparents the entire `StaticBody3D` equipment node to `HeldItemMount` (a child of the player `CharacterBody3D`). The equipment's `CollisionShape3D` remains active, creating physics conflicts:
- Large collision boxes (AED 0.5×0.35×0.4, OxygenMask 0.3×0.25×0.3) push the player sideways
- Small collision boxes (Bandage 0.2×0.15×0.2) block movement from within

## Implementation

Modify `inventory_component.gd`:

**On pickup** (`try_pickup()`):
```gdscript
# After reparenting to mount
equipment_node.collision_layer = 0
equipment_node.collision_mask = 0
# Also disable all CollisionShape3D children
for child in equipment_node.get_children():
    if child is CollisionShape3D:
        child.disabled = true
```

**On drop** (`drop_item()`):
```gdscript
# Before reparenting back to level
_held_node.collision_layer = 1  # Restore default layer
_held_node.collision_mask = 1   # Restore default mask
for child in _held_node.get_children():
    if child is CollisionShape3D:
        child.disabled = false
```

**On use** (`_clear_held_item()`):
- Equipment is consumed, so no collision restore needed. The node is freed.

## Files to Modify

- `scripts/gameplay/inventory_component.gd` — Add collision disable/enable around reparenting

## Acceptance Criteria

- [ ] Picking up AED does not cause player to slide
- [ ] Picking up Oxygen Mask does not cause player to slide
- [ ] Picking up Bandage does not cause player to freeze
- [ ] Picking up Splint does not cause movement issues
- [ ] Picking up Stretcher does not cause movement issues
- [ ] Dropping equipment restores collision — equipment is solid on the ground again
- [ ] Equipment can be re-picked up after dropping

## Boundaries — Do NOT Touch

- Do NOT change the equipment scene files (.tscn) — fix is in the inventory script only
- Do NOT change the equipment entity script (equipment_entity.gd)
- Do NOT change physics layers globally in project.godot

## Notes

This is a critical gameplay-blocking bug. All equipment types are affected.
