# MON-06 — Equipment Held-State Visual Configuration

**Phase:** Phase 2 — Model Importation & Visual
**Team:** Monolith — Stability/Infrastructure
**Status:** `[ ] PENDING`
**Depends on:** MON-01 (physics fix must be done first)
**Blocks:** None

---

## Scope

Configure how equipment looks when held by the player. Currently equipment is reparented to HeldItemMount with `position = Vector3.ZERO` and `rotation = Vector3.ZERO`, but the visual result may be incorrect (wrong scale, wrong orientation, clipping through player model). Add per-equipment-type held-state transforms.

## Implementation

### 1. Held Transform Data

Add held-state transform configuration to EquipmentData resource or directly in equipment entity:

```gdscript
# In equipment_entity.gd or EquipmentData resource:
@export var held_position_offset: Vector3 = Vector3.ZERO
@export var held_rotation_offset: Vector3 = Vector3.ZERO
@export var held_scale: Vector3 = Vector3.ONE
```

### 2. InventoryComponent Update

Modify `inventory_component.gd` `try_pickup()` to apply held transforms:

```gdscript
equipment_node.position = Vector3.ZERO
equipment_node.rotation = Vector3.ZERO
# Apply held-state offsets
if "held_position_offset" in equipment_node:
    equipment_node.position = equipment_node.held_position_offset
if "held_rotation_offset" in equipment_node:
    equipment_node.rotation = equipment_node.held_rotation_offset
if "held_scale" in equipment_node:
    equipment_node.scale = equipment_node.held_scale
```

### 3. Per-Equipment Configuration

Set held transforms for each equipment type in their .tscn files:

| Equipment | Position Offset | Rotation | Scale | Notes |
|-----------|----------------|----------|-------|-------|
| AED | (0, -0.1, 0.2) | (0, 0, 0) | (0.7, 0.7, 0.7) | Held in front of body |
| Bandage | (0.1, 0, 0.1) | (0, 0, 0) | (1, 1, 1) | Held in hand |
| OxygenMask | (0, 0, 0.15) | (0, 0, 0) | (0.8, 0.8, 0.8) | Held forward |
| Splint | (0.1, 0, 0) | (0, 0, PI/2) | (1, 1, 1) | Rotated horizontal |
| Stretcher | (0, -0.2, 0.5) | (0, 0, 0) | (0.5, 0.5, 0.5) | Scaled down when held |

*Values are estimates — adjust in editor until visually correct.*

### 4. Drop Restoration

On `drop_item()`, reset scale and apply drop-state transforms:

```gdscript
_held_node.scale = Vector3.ONE  # Restore original scale
```

## Files to Modify

- `scripts/gameplay/equipment_entity.gd` — Add held-state transform exports
- `scripts/gameplay/inventory_component.gd` — Apply held transforms on pickup, restore on drop
- All 5 equipment .tscn files — Set held transform values

## Acceptance Criteria

- [ ] Each equipment type has configurable held position, rotation, and scale
- [ ] Equipment visually appears correctly in player's hand when held
- [ ] Equipment does not clip through player model
- [ ] Dropping equipment restores original scale and orientation
- [ ] Equipment looks correct on the ground after dropping

## Boundaries — Do NOT Touch

- Do NOT modify HeldItemMount position in Player.tscn (adjust per-equipment instead)
- Do NOT modify the player model or animations
- Do NOT add new equipment types
