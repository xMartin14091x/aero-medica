# Team Monolith — Phase 2 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 2 — Medical Protocol System | Tickets: MON-10, MON-11

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `2. Team_Monolith.md` | Create Team Chat log

## 1. Context
- Phase 1 complete: Patient entity, Equipment entity, ScenarioManager all built
- MedicalStateComponent exists as skeleton — you implement the full state machine
- Syndicate depends on MON-10 for protocol validation (SYN-04) and MON-11 for time pressure (SYN-06)

## 2. Your Mission
Make patients medically dynamic — state transitions, condition deterioration over time. Patients who aren't treated get worse and die. This is the core medical simulation logic.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/1. Monolith/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### MON-10 — Patient Medical State Machine
- Full state machine: CONSCIOUS → UNCONSCIOUS → CARDIAC_ARREST → DEAD
- Modifiers: bleeding_severity, airway_status, breathing_rate, pulse_present
- apply_treatment() and get_triage_priority() methods
- **Start IMMEDIATELY**

### MON-11 — Condition Deterioration System
- Time-based worsening: untreated bleeding increases, obstructed airway → unconscious → cardiac arrest → dead
- Configurable deterioration rates per scenario
- Pauses during active treatment
- **Depends on MON-10**

## 4. Parallel Execution
- MON-10 first → MON-11 after

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch UI/triage logic (Syndicate/Arcade scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
