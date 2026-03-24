# Team Arcade — Phase 5 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 5 — Dashboards & Scoring | Tickets: ARC-11, ARC-12, ARC-13, ARC-14

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `4. Team_Arcade.md` | Create Team Chat log

## 1. Context
- Phase 4 complete: hazard VFX, environmental audio, dynamic environment all working
- Syndicate is building the scoring algorithm (SYN-13) and historical data manager (SYN-14) this phase
- You build the visual dashboard — radar charts, progress graphs, scenario breakdowns, and the instructor view

## 2. Your Mission
Create the performance visualisation layer. Players see their 5-axis skill scores on a radar chart, track improvement over time with line graphs, drill into per-scenario detail, and instructors get a cohort overview dashboard. All charts are reusable Control nodes.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/3. Arcade/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### ARC-11 — Radar Chart Component
- Custom Control node: 5-axis radar chart with animated fill
- Colour-coded axes: green (>80), yellow (50–80), red (<50)
- Reusable — accepts any 5-value array, used in debrief and dashboard
- **Start IMMEDIATELY** — pure UI component, no backend dependency

### ARC-12 — Progress Over Time Graphs
- Line chart Control node showing skill improvement across multiple attempts
- X-axis: attempt number or date, Y-axis: score (0–100)
- One line per axis, toggleable, with trend indicator (improving/declining/stable)
- **Depends on SYN-14** — scaffold with mock historical data array

### ARC-13 — Per-Scenario Breakdown View
- Detailed result screen: all 5 axis scores, patient status cards, action timeline, AI review access button, export button
- Accessed from dashboard or post-scenario debrief
- **Depends on SYN-13** — scaffold with mock scoring data

### ARC-14 — Instructor Dashboard View
- Aggregate cohort dashboard: class-wide radar chart (average), student list with individual scores, weakest-axis identification
- B2B demo feature — scaffold with mock multi-student data
- **Start IMMEDIATELY with mocks** — no live multi-student system yet

## 4. Parallel Execution
- **Start IMMEDIATELY:** ARC-11 (pure UI), ARC-14 (mock data)
- **Start with mocks:** ARC-12 (mock historical data), ARC-13 (mock scoring data)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch scoring algorithm or data persistence logic (Syndicate scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
