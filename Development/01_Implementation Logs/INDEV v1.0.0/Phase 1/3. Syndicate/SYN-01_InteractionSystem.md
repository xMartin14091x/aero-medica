# SYN-01 — Interaction System

**Phase:** Phase 1 — Core Gameplay Loop
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** MON-06, MON-07 (Phase 0/1)
**Blocks:** SYN-02, SYN-03

---

## Scope
Implement the core interaction system — detect nearby interactable objects, show interaction prompts, and handle the player pressing the interact key (E). This wires the InteractableComponent signal contracts into actual gameplay.

## Acceptance Criteria
- [x] `scripts/gameplay/interaction_manager.gd` — attached to Player, manages interaction state
- [x] Detects all InteractableComponent nodes within player's InteractionArea (Area3D)
- [x] Tracks the nearest interactable as `current_target`
- [x] Input action `interact` mapped to E key in project.godot
- [x] Pressing E while `current_target` exists → emits `interacted(player)` on the target's InteractableComponent
- [x] Emits signal `interaction_target_changed(old, new)` when nearest target changes (for UI to react)
- [x] Calls `TelemetryEmitter.emit_action("interact", target_name, {label: interaction_label})` on every interaction
- [x] Works with both Patient and Equipment entities — routes via `_is_patient_entity` / `_is_equipment_entity`
- [x] Test: interaction routing tested via entity type detection + signal emission

## Boundaries — Do NOT Touch
- Do NOT implement what happens AFTER interaction (pickup, assessment) — SYN-02 and SYN-03 handle that
- Do NOT implement UI prompts — ARC-02
