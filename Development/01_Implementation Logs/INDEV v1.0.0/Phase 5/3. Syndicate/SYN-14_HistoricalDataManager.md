# SYN-14 — Historical Data Manager

**Phase:** Phase 5 — Dashboards & Scoring
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-13
**Blocks:** ARC-12

---

## Scope
Store and retrieve historical session scores for progress tracking. Enables "compared to your last 3 attempts" analysis and skill improvement graphs.

## Acceptance Criteria
- [ ] `scripts/dashboard/history_manager.gd` — autoload singleton for score persistence
- [ ] Saves score data to `user_data/history/` as JSON files (one per session)
- [ ] Method: `save_session_scores(scenario_id, scores, timestamp)` — persists after each scenario
- [ ] Method: `get_history(scenario_id, limit) -> Array[Dictionary]` — returns past N sessions for a scenario
- [ ] Method: `get_all_history(limit) -> Array[Dictionary]` — returns past N sessions across all scenarios
- [ ] Method: `get_improvement(scenario_id, axis) -> Dictionary` — returns `{current, previous, delta, trend}`
- [ ] Calculates trends: IMPROVING, DECLINING, STABLE based on last 3-5 sessions
- [ ] Data includes: scenario_id, timestamp, all 5 axis scores, overall score, AI review summary (first sentence)
- [ ] Test: play scenario 3 times → history shows all 3 → improvement calculation is correct

## Boundaries — Do NOT Touch
- Do NOT implement graph rendering — ARC-12
- Do NOT implement cloud sync/remote storage — F11 post-competition
