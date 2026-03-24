# MON-01 — Godot Project Bootstrap

**Phase:** Phase 0 — Foundation & Architecture
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** OVR-01
**Blocks:** MON-02, MON-03, MON-04, MON-05, MON-06

---

## Scope
Create the Godot 4.x project at `Projects/game/` with the full folder structure defined in OVR-01 and Main TechStack Logic. This is the skeleton that all subsequent work builds on.

## Acceptance Criteria
- [ ] `project.godot` exists at `Projects/game/` with correct project name and settings
- [ ] All folders from the Architecture Overview exist (assets/, scenes/, scripts/, data/, user_data/)
- [ ] All sub-folders created (models, textures, audio/music, audio/sfx, ui, entities/player, entities/patients, entities/equipment, etc.)
- [ ] `.gitignore` configured for Godot (`.godot/`, `*.import`, `export_presets.cfg`)
- [ ] Project opens cleanly in Godot 4.x editor without errors

## Boundaries — Do NOT Touch
- Do NOT write game logic — this ticket is folder structure and project config only
- Do NOT modify anything in `Development/`

## Notes
- The `project.godot` file can be created manually (it's a text config file) — Godot will regenerate `.godot/` cache on first open
- Window size: 1920x1080, stretch mode: `canvas_items`, aspect: `keep`
- Renderer: Forward+ (default)
