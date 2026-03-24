# OVR-04 — Phase 3 Integration Testing & Scoring Validation

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Overseer — Integration
**Status:** `[ ] PENDING`
**Depends on:** All other Phase 3 tickets
**Blocks:** None

---

## Scope
End-to-end integration test of the complete gameplay loop: walk to patient → interact → talk (AI/static) → examine (DRSABCDE) → stabilize (medical bag) → diagnose → debrief scoring. Validate that all systems work together and scoring is accurate.

## Test Plan
- [ ] Tutorial scenario: full walkthrough with static responses (no Ollama)
- [ ] Tutorial scenario: full walkthrough with Ollama running
- [ ] Verify SAMPLE history responses match scenario JSON data
- [ ] Verify exam results are logged correctly
- [ ] Verify equipment application changes patient state
- [ ] Verify diagnosis selection feeds into debrief
- [ ] Verify telemetry captures all player actions
- [ ] Verify Ollama graceful degradation (start game → stop Ollama mid-session → responses fall back)
- [ ] Performance: UI opens/closes without frame drops
- [ ] Edge cases: open UI → walk away → UI auto-closes, rapid tab switching, spam clicking

## Acceptance Criteria
- [ ] Complete gameplay loop works end-to-end
- [ ] Scoring reflects player performance accurately
- [ ] No crashes or null reference errors during normal play
- [ ] Telemetry log is complete and parseable

## Boundaries — Do NOT Touch
- Testing only — no code modifications in this ticket
