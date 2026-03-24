# SYN-13 — Scoring Algorithm

**Phase:** Phase 5 — Dashboards & Scoring
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-07, SYN-08, MON-13 (Phase 3)
**Blocks:** ARC-11, ARC-13

---

## Scope
Implement the 5-axis clinical skill scoring algorithm. Converts raw telemetry + protocol analysis + error data into quantitative scores (0–100 per axis).

## Acceptance Criteria
- [ ] `scripts/dashboard/scoring_engine.gd` — calculates all 5 skill axes
- [ ] **Triage Speed** (0-100): based on time-to-first-assessment and time-to-triage-tag vs. benchmark times
- [ ] **Protocol Accuracy** (0-100): protocol_adherence_percentage from SYN-07, penalised by wrong-order steps
- [ ] **Decision Quality** (0-100): patient prioritisation correctness — did player treat most critical first?
- [ ] **Equipment Handling** (0-100): correct equipment selected for condition, proper usage sequence
- [ ] **Patient Outcome** (0-100): final patient states vs. best achievable outcome (survived/stabilised)
- [ ] Method: `calculate_scores(session_data: Dictionary) -> Dictionary` — returns `{triage_speed, protocol_accuracy, decision_quality, equipment_handling, patient_outcome, overall}`
- [ ] Overall score: weighted average (configurable weights per axis)
- [ ] Pass/fail threshold per axis: configurable (default 60%)
- [ ] Test: given known session data → scores calculate correctly → edge cases handled (no patients, perfect run, zero actions)

## Boundaries — Do NOT Touch
- Do NOT implement score display UI — ARC-11 through ARC-13
- Do NOT implement historical comparison — SYN-14
