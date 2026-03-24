# SYN-08 — Error Detection System

**Phase:** Phase 3 — Telemetry & AI Reviewer
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** MON-12, SYN-04 (Phase 2)
**Blocks:** SYN-09

---

## Scope
Detect and categorise player errors during gameplay — wrong triage tags, skipped assessment steps, treating lower-priority patients first, using wrong equipment. Feeds error data into AI reviewer.

## Acceptance Criteria
- [ ] `scripts/telemetry/error_detector.gd` — processes session telemetry post-scenario
- [ ] Error categories: `WRONG_TRIAGE`, `SKIPPED_ASSESSMENT`, `WRONG_PRIORITY`, `WRONG_EQUIPMENT`, `PROTOCOL_VIOLATION`, `DELAYED_ACTION`
- [ ] Method: `detect_errors(session_data: Dictionary, protocol_analysis: Dictionary) -> Array[Dictionary]`
- [ ] Each error: `{type: String, severity: String (CRITICAL/MAJOR/MINOR), patient_id: String, description: String, timestamp: float}`
- [ ] CRITICAL errors: wrong triage on RED/BLACK patient, no CPR on cardiac arrest, treating GREEN before RED
- [ ] MAJOR errors: skipped assessment step, used wrong equipment
- [ ] MINOR errors: slow response time, unnecessary actions
- [ ] Output included in session data as `errors[]` field for AI reviewer
- [ ] Test: intentionally play poorly → error detector catches all mistakes with correct severity

## Boundaries — Do NOT Touch
- Do NOT display errors to player during gameplay — stealth assessment principle
- Do NOT implement scoring penalties — Phase 5
