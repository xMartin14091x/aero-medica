# MON-09 — Medical Bag Equipment System

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Monolith — Core Systems
**Status:** `[x] Complete`
**Verified:** 21-03-2026 — code confirmed present via codebase investigation
**Depends on:** None
**Blocks:** ARC-09

---

## Scope
Replace the ground-spawned single-item equipment pickup system with a persistent medical bag that the player carries from spawn. The bag holds all available tools (Bandage, AED, O2 Mask, Splint, Stretcher, CPR action, Recovery Position, Tourniquet) and is accessed through the PatientInteractionUI Stabilize tab.

## What Was Already Done
- PatientInteractionUI Stabilize tab created with 8 equipment buttons
- Equipment actions emit to telemetry
- Old InventoryComponent pickup system still exists (legacy, kept for backwards compat)

## Remaining Work
- [ ] Create MedicalBag resource/component that attaches to Player on spawn
- [ ] Define equipment inventory (what's available, quantities if limited)
- [ ] Wire Stabilize tab buttons to actual medical state effects on patient
- [ ] Track which equipment has been applied to which patient (for scoring)
- [ ] Remove or disable ground-spawned equipment from tutorial scenario (or keep for other scenarios)
- [ ] Add equipment cooldowns or usage limits if needed for realism

## Acceptance Criteria
- [ ] Player spawns with medical bag (no need to pick up items)
- [ ] Stabilize tab shows all available equipment
- [ ] Applying equipment changes patient medical state
- [ ] Applied equipment is logged to telemetry for scoring
- [ ] Equipment application shows visual/audio feedback

## Boundaries — Do NOT Touch
- Do not remove InventoryComponent entirely (may be used in future scenarios)
- Do not modify PatientPersona structure

## Notes
- Current Stabilize tab buttons: Bandage, AED, O2 Mask, Splint, Stretcher, CPR, Recovery Position, Tourniquet
- Future expansion: Medicine tab with drugs/fluids (deferred to v1.1.0)
