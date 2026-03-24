# SYN-07 — Protocol Adherence Tracker

**Phase:** Phase 3 — Telemetry & AI Reviewer
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-04 (Phase 2), MON-12, MON-13
**Blocks:** SYN-09

---

## Scope
Analyse the player's action sequence against gold-standard BCLS/ALS protocols. Generate a per-patient adherence report that feeds into both the AI reviewer and the scoring system.

## Acceptance Criteria
- [ ] `scripts/telemetry/protocol_adherence_tracker.gd` — processes session telemetry post-scenario
- [ ] Method: `analyse_session(session_data: Dictionary) -> Dictionary` — returns full adherence report
- [ ] Per-patient analysis: compare player's action order against correct protocol sequence
- [ ] Output fields: `correct_steps[]`, `missed_steps[]`, `wrong_order_steps[]`, `unnecessary_steps[]`, `adherence_percentage: float`
- [ ] Prioritisation analysis: did the player treat the most critical patient first? (based on triage priority)
- [ ] Timing analysis: time-to-first-assessment, time-to-triage, time-to-treatment per patient
- [ ] Output included in session data as `protocol_analysis` field for AI reviewer consumption
- [ ] Test: replay a session's telemetry → adherence report correctly identifies skipped steps and wrong order

## Boundaries — Do NOT Touch
- Do NOT implement the scoring formula — Phase 5
- Do NOT implement the AI API call — SYN-09
