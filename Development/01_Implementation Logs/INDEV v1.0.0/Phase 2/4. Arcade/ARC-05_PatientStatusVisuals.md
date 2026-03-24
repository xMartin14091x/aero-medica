# ARC-05 — Patient Status Visual Indicators

**Phase:** Phase 2 — Medical Protocol System
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-10, MON-11
**Blocks:** None

---

## Scope
Add visual indicators to patients that communicate their medical state — breathing animation, bleeding effects, consciousness posture. These are visual cues the player reads to assess patients WITHOUT opening the action menu.

## Acceptance Criteria
- [ ] Breathing indicator: subtle mesh scale oscillation on conscious/breathing patients (chest rising/falling)
- [ ] Bleeding visual: red-tinted particles or expanding red plane beneath bleeding patients (intensity scales with severity 1-3)
- [ ] Consciousness posture: ALERT=sitting/standing, VERBAL=sitting slumped, PAIN=lying curled, UNRESPONSIVE=lying flat
- [ ] Cardiac arrest: no breathing animation, no movement, desaturated colour tint
- [ ] Dead: black/grey colour tint, all animations stopped
- [ ] Visuals update in real-time as MedicalStateComponent changes (listen to `state_changed` and `modifier_changed` signals)
- [ ] All indicators visible and readable from isometric camera distance
- [ ] Test: patient deteriorates from CONSCIOUS → UNCONSCIOUS → posture changes, breathing slows

## Boundaries — Do NOT Touch
- Do NOT implement patient dialogue or speech bubbles — F12 scope
- Do NOT implement patient audio cues — Phase 6

## Notes
- These visuals are critical for the stealth assessment — they're how the player gathers information before formal assessment. The AI reviewer will evaluate whether the player read these cues correctly
