# MON-02 — GameManager Singleton

**Phase:** Phase 0 — Foundation & Architecture
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-01
**Blocks:** None (consumed by Phase 1+)

---

## Scope
Create the `GameManager` autoload singleton — the central coordinator for game state, scene transitions, and session lifecycle.

## Acceptance Criteria
- [ ] `scripts/core/game_manager.gd` exists and extends `Node`
- [ ] Registered as autoload `GameManager` in `project.godot`
- [ ] Implements `change_scene(scene_path: String)` for scene transitions
- [ ] Holds `current_state` enum: `MENU`, `PLAYING`, `PAUSED`, `DEBRIEF`
- [ ] Emits signal `state_changed(old_state, new_state)`
- [ ] Loads and runs without errors when project is opened

## Boundaries — Do NOT Touch
- Do NOT implement scenario logic — that's `ScenarioManager` (later)
- Do NOT implement telemetry — that's `TelemetryCollector` (MON-06)
- Keep it minimal — only what's listed above
