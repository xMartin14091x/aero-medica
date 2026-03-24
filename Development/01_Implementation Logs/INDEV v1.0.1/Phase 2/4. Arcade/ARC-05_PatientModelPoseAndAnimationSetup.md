# ARC-05 — Patient Model Pose & Animation Setup

**Phase:** Phase 2 — Model Importation & Visual
**Team:** Arcade — Frontend/Creative
**Status:** `[ ] PENDING`
**Depends on:** MON-05 (patient model pipeline must exist)
**Blocks:** None

---

## Scope

Configure patient model poses and animations to reflect their medical state. Conscious patients should have an idle/sitting animation, unconscious patients should be lying down, cardiac arrest patients should be still on the ground, and dead patients should have no animation.

## Implementation

### 1. Update PatientStatusVisual

Extend `scripts/ui/patient_status_visual.gd` to work with imported 3D models instead of just mesh primitives:

```gdscript
# Find AnimationPlayer in patient model
var _patient_anim_player: AnimationPlayer = null

func _ready() -> void:
    _find_patient_anim_player()
    _update_all_visuals()

func _find_patient_anim_player() -> void:
    var model := get_parent().get_node_or_null("PatientModel")
    if model:
        _patient_anim_player = _find_child_of_type(model, "AnimationPlayer")
```

### 2. State-Based Animation/Pose

| Medical State | Animation/Pose | Visual |
|---------------|---------------|--------|
| CONSCIOUS | idle_sitting or idle_standing | Upright, subtle breathing |
| UNCONSCIOUS | lying_down (static pose) | Flat on ground, slow breathing |
| CARDIAC_ARREST | lying_down (static, no breathing) | Flat, no movement, desaturated |
| DEAD | lying_down (static, no breathing) | Flat, no movement, dark grey tint |

### 3. Animation Detection

Reuse the animation name detection pattern from player_controller.gd:
- Search for animations containing "idle", "sit", "stand", "lie", "down"
- Apply root motion stripping via `model_utils.gd` (from MON-05)

### 4. Consciousness Transition Animation

When patient state changes (e.g., CONSCIOUS → UNCONSCIOUS from deterioration):
- Smooth transition: patient model rotates to lying position over 0.5 seconds
- Breathing animation slows and stops

## Files to Modify

- `scripts/ui/patient_status_visual.gd` — Extend for 3D model animation support
- May create animation state logic helpers

## Acceptance Criteria

- [ ] Conscious patients display idle animation (sitting/standing)
- [ ] Unconscious patients are visually lying down
- [ ] Cardiac arrest patients are lying down with no breathing animation
- [ ] Dead patients are lying down with dark grey tint
- [ ] State transitions animate smoothly (not instant snap)
- [ ] System falls back to primitive mesh if no model is attached
- [ ] Breathing visual scales with breathing_rate from MedicalStateComponent

## Boundaries — Do NOT Touch

- Do NOT modify MedicalStateComponent or DeteriorationSystem
- Do NOT modify the player model or player_controller.gd
- Do NOT change triage tag visuals

## Notes

Requires patient .glb models with at least one animation. If models have no animation, use static poses via bone manipulation or node rotation (existing fallback in PatientStatusVisual).
