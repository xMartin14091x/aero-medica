# SYN-16 — AI Integration Testing

**Phase:** Phase 8 — Testing & Competition Build
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-09, SYN-10 (Phase 3)
**Blocks:** OVR-03

---

## Scope
Comprehensive testing of the Ollama AI review integration — verify prompts + answer sheets produce quality reviews, test edge cases, verify graceful degradation, and optimise prompt for competition demo quality. All testing is local — zero API cost.

## Acceptance Criteria
- [ ] **Prompt quality test:** Run 5+ different session data samples through Ollama → verify reviews are specific, actionable, and accurately compare against answer sheet
- [ ] **Edge cases:** Empty session (no actions) → Ollama handles gracefully → generic "no actions observed" review
- [ ] **Edge cases:** Perfect session (100% adherence) → AI recognises and praises excellent performance
- [ ] **Edge cases:** Catastrophic failure (all patients dead) → AI identifies critical errors constructively
- [ ] **Timeout handling:** Simulate Ollama unavailable → graceful degradation → quantitative-only display
- [ ] **Model comparison:** Test with at least 2 different Ollama models (e.g., llama3.1:8b, mistral:7b) → document quality differences
- [ ] **Prompt optimisation:** Refine system prompt + answer sheet format for consistently structured responses (parseable sections)
- [ ] **Response time:** Review must generate within 30 seconds on target hardware → measure and report
- [ ] **Answer sheet validation:** Verify all 5 scenario answer sheets produce accurate reviews when tested against known-good and known-bad sessions
- [ ] **Cache sample reviews:** Pre-generate 3–5 sample reviews and cache them for offline demo fallback (no Ollama needed for judges to see the feature)
- [ ] Final system prompt and answer sheet templates saved in `data/prompts/`

## Boundaries — Do NOT Touch
- Do NOT test NPC dialogue — F12 scope
- Do NOT modify the telemetry pipeline — test with existing data

## Notes
- Zero API cost — all testing is local via Ollama
- Consider caching sample reviews for demo mode (offline fallback with pre-generated reviews)
- Document which Ollama model produces best results for competition recommendation
- Test on both RTX 3090 (dev machine) and modest GPU (competition hardware simulation)
