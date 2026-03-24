# ARC-01 — Contextual Action Menu UI

**Phase:** Phase 1 — Core Gameplay Loop
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** SYN-03
**Blocks:** None

---

## Scope
Create the in-game contextual action menu that appears when the player interacts with a patient. Displays available assessment/treatment actions as a list or radial menu near the patient.

## Acceptance Criteria
- [ ] `scenes/ui/hud/ActionMenu.tscn` — Control node anchored to screen, positioned near patient
- [ ] `scripts/ui/action_menu.gd` — listens for assessment mode activation
- [ ] Shows available actions as clickable buttons (or keyboard-navigable list: 1-5 keys)
- [ ] Actions displayed: "Check Airway", "Check Breathing", "Check Pulse", "Check Consciousness", "Check Bleeding"
- [ ] Selecting an action → calls AssessmentManager to execute → menu closes
- [ ] Menu auto-closes if player walks away from patient (distance check)
- [ ] Clean, readable design — dark semi-transparent background, white text, clear highlight on hover/select
- [ ] Works with both mouse click and keyboard number keys
- [ ] Test: interact with patient → menu appears → select action → result shown → menu closes

## Boundaries — Do NOT Touch
- Do NOT implement treatment actions in the menu — Phase 2 will add those
- Do NOT implement the AI review UI — Phase 3
- Do NOT style with final art — functional prototype only

## Notes
- Menu should use Godot's Control/VBoxContainer for layout
- Position near patient using Camera3D.unproject_position() to convert 3D world position to 2D screen position
- Consider F12 future: menu will eventually include "Talk to Patient" option for dialogue
