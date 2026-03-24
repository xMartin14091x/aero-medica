# MON-17 — Performance Optimisation

**Phase:** Phase 8 — Testing & Competition Build
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** OVR-02 (QA identifies bottlenecks)
**Blocks:** OVR-03

---

## Scope
Profile and optimise the game to meet the 60fps target on mid-range hardware. Fix any performance issues identified during QA.

## Acceptance Criteria
- [ ] Godot profiler run on each scenario — identify frame time spikes
- [ ] Particle system optimisation: reduce particle counts if needed (especially fire/smoke in Phase 4 levels)
- [ ] Navigation mesh: verify baking is done once at load, not per-frame
- [ ] Telemetry position tracking: verify 1s interval is not causing frame drops
- [ ] Scene tree cleanup: no orphaned nodes, no unnecessary processing on hidden nodes
- [ ] Texture/model LOD: ensure imported assets are not unnecessarily high-poly for isometric distance
- [ ] Memory profiling: no memory leaks across multiple scenario loads/unloads
- [ ] Target: consistent 60fps at 1080p on GTX 1060 / Intel i5 equivalent
- [ ] Test: run each scenario for full duration → no frame drops below 55fps → no memory growth

## Boundaries — Do NOT Touch
- Do NOT change gameplay behaviour for performance — only optimise existing implementations
- Do NOT remove features to meet performance targets — optimise first, then consult KP
