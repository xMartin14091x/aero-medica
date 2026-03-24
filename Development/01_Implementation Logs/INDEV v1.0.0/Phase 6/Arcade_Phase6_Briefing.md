# Team Arcade — Phase 6 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 6 — Content Expansion | Tickets: ARC-15, ARC-16, ARC-17, ARC-18, ARC-19, ARC-20

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `4. Team_Arcade.md` | Create Team Chat log

## 1. Context
- Phases 0–5 complete: all systems operational, dashboards and scoring ready
- Monolith is authoring scenario data files (MON-16) this phase
- You build the actual playable levels for all 5 scenarios and the full audio system
- **Asset import phase:** This is when 3D assets from CC0/CC-BY sources (Mixamo, Poly Haven, Sketchfab, Quaternius) are imported to replace placeholder boxes. Refer to Current TechStack.md Asset Strategy for source links and per-entity mapping.

## 2. Your Mission
Build all 5 scenario levels as playable 3D environments with imported assets, proper lighting, and navigation. Add the complete audio system — ambient soundscapes, UI sounds, patient audio, and dynamic music. By phase end, all 5 scenarios are fully playable with real visuals and sound.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/3. Arcade/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### ARC-15 — Tutorial Scenario Level
- Simple guided environment: small room or outdoor area, clear waypoints
- 1 conscious patient with minor bleeding, UI hint overlays for first-time players
- No time pressure, no hazards — pure learning
- **Depends on MON-16** — scaffold with placeholder layout, wire patient/equipment positions from scenario data

### ARC-16 — Road Traffic Accident Level
- Upgrade Phase 1's RTA level with 3D assets: vehicles (Quaternius), road/sidewalk (Poly Haven textures), debris
- 3 patient NPCs (Mixamo rigged), scattered equipment, traffic hazard zone
- Proper lighting (directional sun + emergency vehicle lights)
- **Depends on MON-16** — scaffold layout, wire from scenario data

### ARC-17 — Cardiac Arrest Level
- Indoor environment: room or office with single patient in cardiac arrest
- AED and first aid kit nearby, minimal distractions
- Intimate lighting, focused scenario
- **Depends on MON-16**

### ARC-18 — Mass Casualty Event Level
- Large outdoor area: park, plaza, or intersection
- 5+ patient spawn points, limited equipment spawn points
- Open layout requiring triage prioritisation and movement strategy
- **Depends on MON-16**

### ARC-19 — Building Fire Level
- Interior rooms + exterior staging area
- Fire particle effects (from ARC-09), collapse zones, smoke obscuring visibility
- 3 patients requiring extraction decisions (rescue order matters)
- **Depends on MON-16**

### ARC-20 — Full Audio System
- Ambient soundscapes per environment type (outdoor traffic, indoor quiet, fire roar)
- UI feedback sounds: menu clicks, triage tag assignment, assessment complete
- Patient audio cues: groaning, coughing, calling for help
- Dynamic music: calm base layer → urgency layers as timer progresses
- **Start IMMEDIATELY** — audio system is independent, wire to levels as they're built

## 4. Parallel Execution
- **Start IMMEDIATELY:** ARC-20 (audio system, independent)
- **Start with mocks:** ARC-15 through ARC-19 (scaffold layouts with placeholder positions, wire MON-16 scenario data when complete)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch scenario data authoring (Monolith scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
