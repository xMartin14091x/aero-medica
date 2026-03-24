# ARC-07 — Patient Interaction UI Polish & UX

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Arcade — UI/Creative
**Status:** `[x] Complete`
**Verified:** 21-03-2026 — code confirmed present via codebase investigation
**Depends on:** None
**Blocks:** None

---

## Scope
Polish the PatientInteractionUI tabbed panel (Patient/Exam/Stabilize/Differential) for usability, visual clarity, and responsive layout. The UI is functional but needs UX refinement.

## What Was Already Done
- Full tabbed UI created with 4 tabs (patient_interaction_ui.gd + .tscn)
- Patient tab: AI chat + SAMPLE quick-ask buttons
- Exam tab: DRSABCDE step buttons with result labels
- Stabilize tab: 8 equipment buttons
- Differential tab: 20 diagnosis buttons
- Escape to close, auto-close on distance > 4 units

## Remaining Work
- [ ] Visual styling — tab buttons need distinct colors/icons per tab
- [ ] Patient info header — show patient name, age, consciousness level at top of all tabs
- [ ] Chat scroll — ensure chat auto-scrolls to bottom on new messages
- [ ] Input focus — LineEdit should auto-focus when Patient tab is active
- [ ] Exam tab — show completion status (e.g., "3/8 steps complete")
- [ ] Stabilize tab — show applied vs available equipment (grey out used items)
- [ ] Differential tab — highlight selected diagnosis, show confidence feedback
- [ ] Responsive layout — handle different screen resolutions
- [ ] Add keyboard shortcuts for tab switching (1-4 keys)
- [ ] Mouse cursor visible when UI is open (currently hidden by FPS controller)

## Acceptance Criteria
- [ ] All 4 tabs visually distinct and easy to navigate
- [ ] Patient information visible at all times
- [ ] Chat scrolls correctly and input is focused
- [ ] Applied equipment visually marked
- [ ] UI works at 1080p and 1440p resolutions

## Boundaries — Do NOT Touch
- Do not change the tab structure (4 tabs as designed)
- Do not modify interaction routing in interaction_manager.gd
