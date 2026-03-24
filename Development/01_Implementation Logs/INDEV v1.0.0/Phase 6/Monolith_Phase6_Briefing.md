# Team Monolith — Phase 6 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 6 — Content Expansion | Tickets: MON-16

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `2. Team_Monolith.md` | Create Team Chat log

## 1. Context
- Phases 0–5 complete: all core systems, telemetry, AI review, scoring, dashboards operational
- This phase is content — defining all 5 scenario data files that drive the game
- Arcade depends on your scenario data (MON-16) for building the 5 scenario levels and audio system

## 2. Your Mission
Author the complete scenario data files for all 5 scenarios. Each file defines patients (positions, conditions, deterioration rates), equipment (types, locations), hazards (types, positions, spread), protocol expectations, time limits, and random events. These JSON files are the content backbone — Arcade builds levels from them.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/1. Monolith/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### MON-16 — Scenario Data Files
- 5 complete scenario definitions (JSON):
  1. **Tutorial** — 1 patient (conscious, minor bleeding), no hazards, no time pressure, guided
  2. **Road Traffic Accident** — 3 patients (varying severity), traffic hazard, 15-min timer
  3. **Cardiac Arrest** — 1 patient (cardiac arrest), indoor, AED + first aid kit, 8-min timer
  4. **Mass Casualty Event** — 5+ patients, limited resources (3 bandages, 1 AED, 1 stretcher), 20-min timer
  5. **Building Fire** — 3 patients, fire/collapse hazards, extraction decisions, 12-min timer
- Each file uses the scenario data schema from MON-09 (Phase 1)
- Include random event definitions per scenario
- **Start IMMEDIATELY** — data authoring, no code dependency

## 4. Parallel Execution
- **Start IMMEDIATELY:** MON-16 (single ticket, data authoring)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch level building or audio (Arcade scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
