# ARC-02 — Interaction Prompt UI

**Phase:** Phase 1 — Core Gameplay Loop
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** SYN-01
**Blocks:** None

---

## Scope
Create floating interaction prompts that appear when the player is near an interactable object. Shows the interaction label and key hint (e.g., "[E] Check Pulse", "[E] Pick Up AED").

## Acceptance Criteria
- [ ] `scenes/ui/hud/InteractionPrompt.tscn` — Label3D or Control overlay
- [ ] `scripts/ui/interaction_prompt.gd` — listens to InteractionManager.interaction_target_changed
- [ ] Shows prompt when player is near an interactable: "[E] {interaction_label}"
- [ ] Hides prompt when no interactable in range
- [ ] Prompt floats above the target entity (world-space billboard or screen-space overlay)
- [ ] Smooth fade in/out transitions
- [ ] Clear, readable text with contrasting background
- [ ] Test: walk near AED → "[E] Pick Up AED" appears → walk away → disappears

## Boundaries — Do NOT Touch
- Do NOT implement the action menu — ARC-01
- Do NOT implement HUD elements — Phase 7
