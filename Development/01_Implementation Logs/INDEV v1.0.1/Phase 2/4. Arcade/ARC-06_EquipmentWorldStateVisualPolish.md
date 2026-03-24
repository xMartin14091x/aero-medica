# ARC-06 — Equipment World-State Visual Polish

**Phase:** Phase 2 — Model Importation & Visual
**Team:** Arcade — Frontend/Creative
**Status:** `[ ] PENDING`
**Depends on:** None
**Blocks:** None

---

## Scope

Polish the visual appearance of equipment entities on the ground. Currently they are colored box meshes. Add visual distinction, glow/highlight when interactable, and ground placement refinement.

## Implementation

### 1. Interaction Highlight

Add a visual highlight when equipment is within interaction range:

```gdscript
# In equipment_entity.gd or a new visual component:
func _on_interaction_focus() -> void:
    # Subtle pulse/glow effect when player is near
    var mesh := $MeshInstance3D
    mesh.material_override = highlighted_material  # Brighter variant

func _on_interaction_unfocus() -> void:
    mesh.material_override = null  # Restore default
```

Wire to InteractionManager's `interaction_target_changed` signal.

### 2. Equipment Color Coding

Update equipment mesh materials for visual distinction:

| Equipment | Color | Rationale |
|-----------|-------|-----------|
| AED | Red/White | Standard emergency AED color |
| Bandage | White/Cream | Medical bandage |
| OxygenMask | Blue/Clear | Oxygen equipment association |
| Splint | Beige/Brown | Wooden splint |
| Stretcher | Orange/Yellow | Emergency stretcher |

### 3. Ground Shadow

Add a subtle circular shadow/contact blob beneath each equipment item for grounding:
- Simple dark circle (Decal or MeshInstance3D with circle texture)
- Helps equipment feel placed on the ground rather than floating

### 4. Floating Label (Optional)

Add a small floating label above equipment showing its name (e.g., "AED", "Bandage") visible when within interaction range. Uses the existing interaction prompt system.

## Files to Modify

- All 5 equipment .tscn files — Update mesh materials and colors
- `scripts/gameplay/equipment_entity.gd` — Add highlight response methods
- `scripts/ui/hud_controller.gd` — Wire highlight signals (if not already)

## Acceptance Criteria

- [ ] Each equipment type has a distinct color
- [ ] Equipment highlights when player is within interaction range
- [ ] Highlight removes when player walks away
- [ ] Equipment appears grounded (not floating)
- [ ] Visual style matches the "clean low-poly realistic" art direction

## Boundaries — Do NOT Touch

- Do NOT modify inventory/pickup logic (MON-01 handles physics)
- Do NOT modify interaction detection radius
- Do NOT add new equipment types
- Do NOT modify patient visuals
