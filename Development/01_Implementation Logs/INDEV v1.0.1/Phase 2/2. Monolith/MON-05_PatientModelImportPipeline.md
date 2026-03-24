# MON-05 — Patient Model Import Pipeline

**Phase:** Phase 2 — Model Importation & Visual
**Team:** Monolith — Stability/Infrastructure
**Status:** `[ ] PENDING`
**Depends on:** None (requires .glb assets from Chief Manager)
**Blocks:** ARC-05

---

## Scope

Establish the patient model import pipeline: import patient .glb files into Godot, create patient model variants, and wire them into PatientBase.tscn so ScenarioManager can assign different models per patient.

## Implementation

### 1. Model Import Process

For each patient .glb file provided by Chief Manager:
1. Place in `assets/models/characters/patients/`
2. Godot auto-imports as PackedScene resource
3. Test instance in editor — verify mesh, skeleton, materials

### 2. PatientBase.tscn Modification

Add a model slot to `scenes/entities/patients/PatientBase.tscn`:

```
PatientBase (CharacterBody3D)
├── PatientModel (Node3D — placeholder, replaced at spawn)
├── CollisionShape3D
├── InteractableComponent
├── MedicalStateComponent
├── DeteriorationSystem
├── TriageTagVisual
└── PatientStatusVisual
```

### 3. ScenarioManager Model Assignment

Update `scenario_manager.gd` to support per-patient model assignment:

```gdscript
# In _spawn_entities() patient section:
var model_path = patient_def.get("model", "res://assets/models/characters/patients/default_patient.glb")
var model_scene = load(model_path) as PackedScene
if model_scene:
    var model_instance = model_scene.instantiate()
    model_instance.name = "PatientModel"
    patient.add_child(model_instance)
```

### 4. Root Motion Stripping (Reuse Pattern)

Extract the root motion stripping logic from `player_controller.gd` into a shared utility:

```gdscript
# scripts/gameplay/model_utils.gd (new autoload or static class)
static func strip_root_motion(anim_player: AnimationPlayer) -> void:
    # Same logic as player_controller._strip_root_motion_from_all()
    # Reusable for any imported model with Mixamo animations
```

### 5. Scenario JSON Extension

Add `model` field to patient definitions:

```json
{
  "patients": [
    {
      "name": "Patient A",
      "model": "res://assets/models/characters/patients/civilian_male.glb",
      "position": [5, 0, 3]
    }
  ]
}
```

## Files to Create

- `scripts/gameplay/model_utils.gd` — Shared model utility (root motion stripping, animation detection)
- `assets/models/characters/patients/` directory

## Files to Modify

- `scenes/entities/patients/PatientBase.tscn` — Add PatientModel node slot
- `scripts/core/scenario_manager.gd` — Model assignment in `_spawn_entities()`
- Scenario JSONs — Add `model` field to patient definitions

## Acceptance Criteria

- [ ] Patient .glb models import correctly into Godot
- [ ] PatientBase.tscn supports swappable model instances
- [ ] ScenarioManager assigns models from scenario JSON
- [ ] Root motion is stripped from patient animations (if applicable)
- [ ] Default model fallback works when no model specified
- [ ] Multiple patients can have different models in the same level

## Boundaries — Do NOT Touch

- Do NOT modify the player model pipeline (player_controller.gd)
- Do NOT modify MedicalStateComponent or assessment systems
- Do NOT create UI elements

## Notes

This ticket requires Chief Manager to provide patient .glb files from Mixamo/Blender. If models are not available, create a placeholder capsule mesh with color variation as a temporary visual.
