# MON-07 — Patient Entity Base

**Phase:** Phase 1 — Core Gameplay Loop
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-01, MON-06 (Phase 0)
**Blocks:** SYN-03, ARC-01

---

## Scope
Create the base Patient NPC entity — a CharacterBody3D with MedicalStateComponent, InteractableComponent, PatientPersona, and TriageTagVisual placeholder. This is the core entity all medical gameplay revolves around.

## Acceptance Criteria
- [ ] `scenes/entities/patients/PatientBase.tscn` scene created with CharacterBody3D root
- [ ] MedicalStateComponent (`scripts/medical/medical_state_component.gd`) attached — skeleton with state enum (CONSCIOUS, UNCONSCIOUS, CARDIAC_ARREST, DEAD) and modifier exports (bleeding_severity, airway_status, breathing_rate, pulse_present)
- [ ] InteractableComponent attached with `dialogue_capable = true` (F12-ready)
- [ ] PatientPersona resource slot exposed as export
- [ ] TriageTagVisual child node (MeshInstance3D — small coloured plane above patient, initially hidden)
- [ ] CollisionShape3D for physics
- [ ] Placeholder mesh (capsule/box lying on ground) with distinct colour from player
- [ ] Patient can be placed in TestLevel and detected by player's InteractionArea

## Boundaries — Do NOT Touch
- Do NOT implement medical state transitions — Phase 2
- Do NOT implement actual triage tag logic — Phase 2
- Do NOT implement patient animations — placeholder mesh only
- Do NOT implement dialogue — F12 post-core scope
