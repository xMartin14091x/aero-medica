# ARC-08 — Scenario Debrief Screen

**Phase:** Phase 3 — Telemetry & AI Reviewer
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** ARC-07, SYN-06 (Phase 2)
**Blocks:** None

---

## Scope
Create the end-of-scenario debrief screen — the transition between gameplay ending and AI review display. Shows immediate results before the AI review loads.

## Acceptance Criteria
- [ ] `scenes/ui/review/DebriefScreen.tscn` — displayed when scenario ends
- [ ] Immediate display (no API wait): scenario time, patients found/total, patients treated, patients survived
- [ ] Per-patient summary cards: patient name, final state, triage tag assigned (colour-coded), correct/incorrect indicator
- [ ] "Requesting AI Review..." indicator → transitions to ReviewPanel when ready
- [ ] If AI unavailable → shows "View Detailed Results" button → simplified quantitative view
- [ ] Smooth transition animation from gameplay to debrief
- [ ] Test: complete scenario → debrief shows immediately → AI review loads → panel transitions

## Boundaries — Do NOT Touch
- Do NOT implement the AI review panel itself — ARC-07
- Do NOT implement replay functionality
