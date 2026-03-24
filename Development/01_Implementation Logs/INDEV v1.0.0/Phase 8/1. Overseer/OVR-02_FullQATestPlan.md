# OVR-02 — Full QA Pass & Test Plan

**Phase:** Phase 8 — Testing & Competition Build
**Team:** Overseer — Head Office
**Status:** `[ ] PENDING`
**Depends on:** All previous phases
**Blocks:** OVR-03

---

## Scope
Define and execute the comprehensive QA test plan — verify every feature, flow, and edge case before competition submission. Overseer coordinates all teams for testing.

## Acceptance Criteria
- [ ] **Core gameplay flow:** Player can complete each of the 5 scenarios start-to-finish without crashes
- [ ] **Interaction system:** All interactions (patient, equipment, hazards, doors) work correctly
- [ ] **Medical protocol:** All assessment, triage, and treatment actions produce correct results
- [ ] **Telemetry:** Full session data exported with correct timestamps, events, and position data
- [ ] **AI reviewer:** Claude API call succeeds → narrative review displays → graceful degradation if API unavailable
- [ ] **Scoring:** All 5 axes calculate correctly → radar chart renders → historical data saves/loads
- [ ] **UI/UX:** All menus navigate correctly, all buttons work, no overlapping elements
- [ ] **Localisation:** Thai and English both display correctly with no missing translation keys
- [ ] **Audio:** All scenarios have ambient audio, all SFX trigger correctly, volume controls work
- [ ] **Edge cases:** Zero patients scenario, all patients dead, perfect run, time expired, API timeout
- [ ] **Performance:** 60fps on mid-range hardware (GTX 1060) at 1080p — profile and verify
- [ ] QA report document: list of all bugs found and their severity (CRITICAL/MAJOR/MINOR)

## Boundaries — Do NOT Touch
- Do NOT implement new features during QA — fix bugs only
- QA report goes to KP for triage and prioritisation
