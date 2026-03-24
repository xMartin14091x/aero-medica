# ARC-07 — AI Review Display Panel

**Phase:** Phase 3 — Telemetry & AI Reviewer
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** SYN-10
**Blocks:** None

---

## Scope
Create the in-game panel that displays the AI Triage Reviewer's narrative performance review alongside quantitative metrics. This is the primary educational feedback interface.

## Acceptance Criteria
- [ ] `scenes/ui/review/ReviewPanel.tscn` — full-screen or large overlay panel
- [ ] Layout: left side = narrative review (scrollable text), right side = quick metrics summary
- [ ] Sections displayed: Overall Assessment (header), Strengths (green bullets), Areas for Improvement (yellow bullets), Critical Errors (red bullets), Recommendations (blue bullets)
- [ ] Quick metrics sidebar: scenario time, patients treated, triage accuracy %, protocol adherence %
- [ ] Loading state: "AI Reviewer is analysing your performance..." with spinner while waiting for API response
- [ ] Error state: if API fails → "AI Review unavailable — showing quantitative results only"
- [ ] "Continue" button → returns to scenario select or main menu
- [ ] Clean, professional design — dark background, clear typography, colour-coded sections
- [ ] Scrollable if review text is long
- [ ] Test: receive parsed review data → all sections display correctly → scroll works → continue button works

## Boundaries — Do NOT Touch
- Do NOT implement historical comparison view — Phase 5
- Do NOT implement dashboard charts — Phase 5
