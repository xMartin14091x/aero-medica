# Team Monolith — Phase 3 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 3 — Telemetry & AI Reviewer | Tickets: MON-12, MON-13

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `2. Team_Monolith.md` | Create Team Chat log

## 1. Context
- Phase 2 complete: patient medical state machine, deterioration, protocols, triage, time pressure all built
- TelemetryEmitter and TelemetryCollector exist from Phase 0 — you wire the actual gameplay events into them
- Syndicate depends on your telemetry data pipeline (MON-12) for protocol adherence tracking (SYN-07) and error detection (SYN-08)

## 2. Your Mission
Connect every gameplay action to the telemetry pipeline and add spatial tracking. By phase end, every player action (assessments, treatments, triage assignments, equipment use, movement) is captured in structured session data ready for AI analysis.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/1. Monolith/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### MON-12 — Telemetry Pipeline Wiring
- Wire all gameplay actions into telemetry: assessment actions, treatment applications, triage assignments, equipment pickups/uses, interaction events
- Connect TelemetryEmitter signals from Patient, Equipment, and Player entities to TelemetryCollector
- Ensure every event includes timestamp, action type, target entity, result, and player position
- **Start IMMEDIATELY** — uses Phase 0 telemetry foundation + Phase 1/2 gameplay systems

### MON-13 — Position Tracking System
- Record player position at 1-second intervals throughout scenario
- Generate heatmap-ready data (position + timestamp array)
- Data feeds into telemetry session export for movement pattern analysis
- **Depends on MON-12** — needs pipeline wiring first

## 4. Parallel Execution
- MON-12 first → MON-13 after

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch protocol analysis or AI integration (Syndicate scope) or UI display (Arcade scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
