# ARC-09 — Hazard Visual Effects

**Phase:** Phase 4 — Dynamic Environment
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-14
**Blocks:** None

---

## Scope
Create visual effects for environmental hazards — fire, smoke, structural damage indicators, traffic warning signals.

## Acceptance Criteria
- [x] Fire VFX: GPUParticles3D with orange/red flame particles + warm light source (OmniLight3D)
- [x] Smoke VFX: GPUParticles3D with grey/black smoke rising from fire zones
- [x] Fire spread: particle system radius grows to match hazard zone expansion
- [x] Collapse zone: cracked ground texture + dust particles + "DANGER" visual barrier
- [x] Traffic zone: flashing warning indicators at zone boundaries
- [x] Hazard zone border: semi-transparent coloured boundary visible from isometric distance (red = fire, yellow = collapse, orange = traffic)
- [x] Warning overlay: screen edge flash when player enters hazard zone
- [x] All effects perform well at 60fps (particle count limits)
- [x] Test: fire hazard active → flames visible → spreads → smoke rises → player enters → warning flash

## Boundaries — Do NOT Touch
- Do NOT implement hazard audio — ARC-10
- Do NOT import final fire/smoke assets — use Godot's built-in particle system with placeholder shapes

## Notes
- **Asset note:** Phase 6 will replace placeholder particles with polished effects if time permits
