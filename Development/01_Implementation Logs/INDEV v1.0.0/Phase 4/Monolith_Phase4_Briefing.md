# Team Monolith — Phase 4 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 4 — Dynamic Environment | Tickets: MON-14, MON-15

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `2. Team_Monolith.md` | Create Team Chat log

## 1. Context
- Phase 3 complete: telemetry pipeline wired, position tracking active
- You now add environmental dynamism — hazards that threaten the player and random events that change mid-scenario
- Arcade depends on your hazard system (MON-14) for visual effects (ARC-09) and audio cues (ARC-10)

## 2. Your Mission
Make the scenario environment dynamic and dangerous. Hazards (fire, structural collapse, traffic) create zones that damage or block the player. Random events (new patients, equipment failure, bystander arrival) force adaptation mid-scenario.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/1. Monolith/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### MON-14 — Environmental Hazard System
- HazardComponent: fire spread, structural collapse warnings, traffic danger zones
- Hazards deal damage or block player movement via Area3D detection
- Configurable per-scenario: hazard type, position, spread rate, damage amount
- **Start IMMEDIATELY**

### MON-15 — Random Event System
- Mid-scenario events triggered by time or condition: new patient spawns, equipment failure, bystander arrival
- Event definitions in scenario data files (JSON array of events with triggers)
- Events queue and fire via signal — other systems react
- **Depends on MON-14** — some events interact with hazard state

## 4. Parallel Execution
- MON-14 first → MON-15 after

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch scene variation logic (Syndicate scope) or visual effects/audio (Arcade scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
