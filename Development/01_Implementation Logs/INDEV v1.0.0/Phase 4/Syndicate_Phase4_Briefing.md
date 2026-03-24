# Team Syndicate — Phase 4 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 4 — Dynamic Environment | Tickets: SYN-11, SYN-12

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `3. Team_Syndicate.md` | Create Team Chat log

## 1. Context
- Phase 3 complete: stealth assessment engine fully operational (protocol tracker, error detection, Claude API, response parser)
- This phase adds replayability and physical interaction depth
- You own scene variation (randomisation) and physics-based object interaction

## 2. Your Mission
Make every playthrough different and add physical interaction depth. The scene variation engine randomises patient positions, conditions, hazard placements, and equipment locations each run. Physics interactions let the player move debris, open doors, and drag stretchers.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/2. Syndicate/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### SYN-11 — Scene Variation Engine
- Randomise scenario elements on each play: patient spawn positions/conditions, hazard placements, equipment locations
- Variation parameters defined per scenario in data files
- Seed-based randomisation for reproducible test runs
- **Start IMMEDIATELY** — uses scenario data structure from Phase 1

### SYN-12 — Physics Interaction System
- Extend interaction system for physics objects: movable debris (RigidBody3D), openable doors (AnimatableBody3D), draggable stretchers
- Physics objects use InteractableComponent with interaction_type = "physics"
- Player push/pull mechanics with weight limits
- **Start IMMEDIATELY** — extends Phase 1 interaction system, independent of SYN-11

## 4. Parallel Execution
- **Start IMMEDIATELY:** Both SYN-11 and SYN-12 (independent of each other)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch hazard core logic (Monolith scope) or VFX/audio (Arcade scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
