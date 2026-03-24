# Team Monolith — Phase 8 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 8 — Testing & Competition Build | Tickets: MON-17

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `2. Team_Monolith.md` | Create Team Chat log

## 1. Context
- Phases 0–7 complete: full game built, all UI polished, localisation done
- Competition deadline: April 2, 2026 (TMH2026)
- This phase is optimisation and stability — make it run smoothly for the judges

## 2. Your Mission
Profile and optimise performance. The game must run at 60fps at 1080p on a GTX 1060 (mid-range competition hardware). Profile with Godot's built-in profiler, identify bottlenecks, optimise particles, navigation, telemetry writes, and memory usage. No feature removal — only performance improvement.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/1. Monolith/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### MON-17 — Performance Optimisation
- Profile with Godot profiler: identify frame time spikes, memory leaks, GC pressure
- Optimise GPUParticles3D (LOD, emission rates, culling)
- Optimise NavigationServer3D (bake quality, agent count)
- Optimise TelemetryCollector (batch writes, reduce per-frame allocations)
- Memory profiling: ensure no leaks across scenario transitions
- Target: 60fps sustained at 1080p on GTX 1060 equivalent
- **Start IMMEDIATELY** — no dependency, profile the full game as-built

## 4. Parallel Execution
- **Start IMMEDIATELY:** MON-17 (single ticket)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT remove features or change game logic — optimise only

---
Footer: Issued by KP (Overseer) — 08-03-2026
