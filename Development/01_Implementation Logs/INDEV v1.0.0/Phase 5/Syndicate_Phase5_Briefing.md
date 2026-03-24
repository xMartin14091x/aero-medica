# Team Syndicate — Phase 5 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 5 — Dashboards & Scoring | Tickets: SYN-13, SYN-14, SYN-15

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `3. Team_Syndicate.md` | Create Team Chat log

## 1. Context
- Phase 4 complete: dynamic environment, scene variation, physics interactions all working
- The full gameplay loop is done — now you quantify performance
- Arcade depends on your scoring data (SYN-13) and historical data (SYN-14) for dashboard visualisations

## 2. Your Mission
Build the scoring and data persistence layer. Calculate 5-axis clinical skill scores from telemetry, store session history for progress tracking, and provide data export for instructors. By phase end, every completed scenario produces a structured score and all scores are persisted across sessions.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/2. Syndicate/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### SYN-13 — Scoring Algorithm
- Calculate 5-axis scores: Triage Speed, Protocol Accuracy, Decision Quality, Equipment Handling, Patient Outcome
- Each axis 0–100 scale, weighted composite for overall score
- Uses telemetry session data, protocol adherence report, error log
- **Start IMMEDIATELY** — uses Phase 3 telemetry/analysis output

### SYN-14 — Historical Data Manager
- Persist session scores to local storage (JSON file or Godot's user:// filesystem)
- Track per-scenario history: date, score axes, overall score, scenario ID
- Query methods: get_best_score(), get_history(), get_improvement_trend()
- **Depends on SYN-13** — needs scoring output to store

### SYN-15 — Data Export System
- Export performance data as CSV and JSON
- Includes: all session scores, per-patient breakdown, protocol adherence, AI review summaries
- File save dialog for export location
- **Depends on SYN-14** — needs historical data to export

## 4. Parallel Execution
- SYN-13 first → SYN-14 → SYN-15 (sequential chain)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch dashboard UI or chart rendering (Arcade scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
