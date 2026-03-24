# SYN-06 — Time Pressure System

**Phase:** Phase 2 — Medical Protocol System
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** MON-11, MON-09
**Blocks:** ARC-06

---

## Scope
Implement the scenario time pressure system — countdown timer that drives urgency. Integrates with deterioration system to create escalating pressure as time runs out.

## Acceptance Criteria
- [x] `scripts/gameplay/time_pressure_system.gd` — manages scenario timer
- [x] Export: `time_limit_seconds: float` — loaded from scenario data
- [x] `start_timer(limit_seconds)` begins countdown
- [x] Signal: `time_updated(remaining_seconds)` — every second for HUD
- [x] Signal: `time_warning(remaining_seconds)` — at 75%, 50%, 25% thresholds
- [x] Signal: `time_expired()` — scenario auto-ends when timer hits zero
- [x] Timer pauses when GameManager state is PAUSED
- [x] Deterioration rate multiplier: configurable schedule (default 1.0x → 1.5x at 50% → 2.0x at 25%)
- [x] Applies multiplier to all DeteriorationSystem nodes (via group or tree search)
- [x] TelemetryEmitter event: `scenario_time_expired` on expiry

## Boundaries — Do NOT Touch
- Do NOT implement pause menu — Phase 7
- Do NOT implement scenario scoring based on time — Phase 5
