# Team Arcade — Phase 4 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 4 — Dynamic Environment | Tickets: ARC-09, ARC-10

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `4. Team_Arcade.md` | Create Team Chat log

## 1. Context
- Phase 3 complete: debrief screen, AI review display panel built
- Monolith is building hazard system (MON-14) and random events (MON-15) this phase
- You make hazards visible and audible — fire particles, smoke, collapse indicators, environmental audio

## 2. Your Mission
Bring the dynamic environment to life visually and aurally. Fire crackles and glows, structures show damage, traffic zones have warning signs, and every hazard has matching audio. Players read environmental danger through your visual and audio cues.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/3. Arcade/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### ARC-09 — Hazard Visual Effects
- GPUParticles3D: fire (orange particles + OmniLight3D glow), smoke (grey rising particles), structural collapse (dust + cracks)
- Traffic danger zones: warning decals or barrier meshes
- Hazard intensity scales visually (small fire → large fire)
- **Depends on MON-14** — scaffold with mock hazard data (position, type, intensity)

### ARC-10 — Environmental Audio Cues
- AudioStreamPlayer3D for spatial hazard sounds: fire crackling, collapse rumbling, traffic noise
- UI audio: event notification chimes, hazard proximity warnings
- Volume scales with distance (3D spatial audio)
- **Depends on MON-14** — scaffold with mock hazard signals

## 4. Parallel Execution
- **Start IMMEDIATELY with mocks:** Both ARC-09 and ARC-10 (scaffold with mock hazard positions/types, wire live after MON-14 signals complete)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch hazard logic or random event triggers (Monolith scope) or scene variation (Syndicate scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
