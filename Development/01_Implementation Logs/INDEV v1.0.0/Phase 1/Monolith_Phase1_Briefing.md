# Team Monolith — Phase 1 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 1 — Core Gameplay Loop | Tickets: MON-07, MON-08, MON-09

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md at `D:\Claude Code\.claude\CLAUDE.md`
- Read Team Roster file at `D:\Claude Code\.claude\Team Roster\2. Team_Monolith.md`
- Adopt voice, code names, coding style
- Create today's Team Chat log

## 1. Context
- Phase 0 is COMPLETE — project skeleton, camera, player movement, tiles, base components all built
- All autoloads registered: GameManager, TelemetryCollector
- InteractableComponent, TelemetryEmitter, PatientPersona are skeletons — you flesh them out here
- Godot project at `Projects/aero-medica/`

## 2. Your Mission
Build the three core gameplay entities: Patient NPC, Equipment items, and the Scenario loading system. By phase end, a scenario data file should load and spawn patients + equipment into the test level, detectable by the player's interaction area.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/1. Monolith/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### MON-07 — Patient Entity Base
- **File:** `Phase 1/2. Monolith/MON-07_PatientEntityBase.md`
- Create PatientBase.tscn (CharacterBody3D + MedicalStateComponent skeleton + InteractableComponent + PatientPersona + TriageTagVisual placeholder)
- Placeholder mesh lying on ground, distinct from player

### MON-08 — Equipment Entity Base
- **File:** `Phase 1/2. Monolith/MON-08_EquipmentEntityBase.md`
- Create EquipmentBase.tscn + EquipmentData resource class + 5 variant scenes (AED, Bandage, Splint, OxygenMask, Stretcher)
- All with InteractableComponent and placeholder meshes

### MON-09 — Scenario Data Format & Loader
- **File:** `Phase 1/2. Monolith/MON-09_ScenarioDataAndLoader.md`
- Implement ScenarioManager: load scenario JSON → spawn patients/equipment → manage lifecycle
- Create first test scenario definition (`scenario_tutorial.json`)

## 4. Parallel Execution — Start Now vs. Wait
- **Start IMMEDIATELY:** MON-07 and MON-08 (independent of each other)
- **After MON-07 + MON-08:** MON-09 (needs both entity types to spawn)

## 5. Logging & Handoff Requirements
- Log in Team Chat daily file | File OverseerReport when all tickets complete
- Update ticket status fields as you work

## 6. Boundaries — Do NOT Touch
- Do NOT implement interaction logic (SYN-01) | Do NOT implement medical state transitions (Phase 2)
- Do NOT import final 3D models — placeholder meshes only

## 7. If You Hit a Blocker
- File in OverseerReport immediately — do not workaround without KP sign-off

---
Footer: Issued by KP (Overseer) — 08-03-2026
