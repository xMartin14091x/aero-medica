# ARC-10 — Environmental Audio Cues

**Phase:** Phase 4 — Dynamic Environment
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-14, MON-15
**Blocks:** None

---

## Scope
Add audio feedback for environmental hazards and random events — warning sounds, fire crackling, collapse rumbles, event notification chimes.

## Acceptance Criteria
- [x] Fire: crackling/roaring AudioStreamPlayer3D positioned at fire zones (positional audio)
- [x] Collapse: rumble/crashing sound when collapse zone activates or expands
- [x] Traffic: vehicle engine/horn sounds during traffic zone danger windows
- [x] Random event notification: distinct chime/alert when random event triggers
- [x] Hazard warning: alarm sound when player enters a hazard zone
- [x] Audio fades with distance (3D positional audio falloff)
- [x] All sounds use placeholder free audio (source from freesound.org CC0 or generate with SFXR)
- [x] Volume balanced — hazard sounds should not overpower gameplay
- [x] Test: fire hazard → crackling sound from fire position → louder as player approaches

## Boundaries — Do NOT Touch
- Do NOT implement full audio system (ambient, music) — Phase 6
- Do NOT implement patient audio cues — Phase 6

## Notes
- Placeholder audio sources: [Freesound.org](https://freesound.org/) (CC0 filter), [SFXR](https://sfxr.me/) for generated effects
