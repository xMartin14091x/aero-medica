# ARC-09 — Stabilize Tab Equipment Effects & Feedback

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Arcade — UI/Creative
**Status:** `[x] Complete`
**Verified:** 21-03-2026 — code confirmed present via codebase investigation
**Depends on:** MON-09 (Medical bag system)
**Blocks:** None

---

## Scope
Wire the Stabilize tab equipment buttons to produce visual and audio feedback when applied. Show the effect on patient state and track usage for scoring.

## Remaining Work
- [ ] Equipment application animation/effect (brief flash or icon animation on button press)
- [ ] Sound effect per equipment type (bandage wrap, AED charge/shock, O2 hiss, etc.)
- [ ] Patient state change feedback in chat (e.g., "System: Bandage applied — bleeding controlled")
- [ ] Grey out equipment after use (single-use items like AED pads)
- [ ] Show equipment effect on patient vital indicators (if visible)
- [ ] CPR mini-sequence (timed button presses or hold)
- [ ] Recovery Position visual change on patient model (future — tied to Phase 2 model work)

## Acceptance Criteria
- [ ] Each equipment button produces audio/visual feedback on use
- [ ] Applied equipment logged to chat and telemetry
- [ ] Single-use items cannot be re-applied
- [ ] Patient medical state updated after equipment application

## Boundaries — Do NOT Touch
- Do not modify MedicalStateComponent core logic without Monolith approval
- Do not change telemetry event format
