# Team Arcade — Phase 3 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 3 — Telemetry & AI Reviewer | Tickets: ARC-07, ARC-08

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `4. Team_Arcade.md` | Create Team Chat log

## 1. Context
- Phase 2 complete: triage tag visuals, patient status indicators, scenario timer HUD all working
- Syndicate is building the AI review pipeline (SYN-09, SYN-10) this phase
- You display the results — the debrief screen shown immediately when a scenario ends, and the AI review panel that loads once Claude's analysis arrives

## 2. Your Mission
Build the end-of-scenario experience — an immediate debrief screen with quick stats, plus the AI review display panel that presents Claude's narrative assessment. Players finish a scenario and see their results in a clear, readable format.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/3. Arcade/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### ARC-07 — AI Review Display Panel
- In-game panel showing AI narrative review: narrative text on left, quick metrics sidebar on right
- Sections: overall assessment, strengths (green), improvements (yellow), critical errors (red), recommendations
- Loading state with spinner while waiting for Claude API response
- **Depends on SYN-10** — scaffold with mock parsed review data

### ARC-08 — Scenario Debrief Screen
- End-of-scenario screen shown immediately when timer expires or player completes
- Quick stats: time taken, patients treated, triage accuracy %, protocol steps completed
- "Generating AI Review..." loading indicator that transitions to ARC-07 panel when ready
- Replay scenario / Return to menu buttons
- **Start IMMEDIATELY** — uses Phase 2 timer and triage data, no cross-team dependency for immediate stats

## 4. Parallel Execution
- **Start IMMEDIATELY:** ARC-08 (immediate stats from local data)
- **Start with mocks:** ARC-07 (scaffold display with mock AI review data, wire live after SYN-10 signals complete)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch telemetry analysis or AI API calls (Syndicate scope) or telemetry pipeline (Monolith scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
