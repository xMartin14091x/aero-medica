# OVR-01 — SyncThing .stignore Configuration

**Phase:** Phase 0 — Bug Fixes & Tech Debt
**Team:** Overseer — HQ/Management
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** None
**Priority:** Low

---

## Scope

Configure SyncThing `.stignore` at the project root to prevent binary asset deletion, editor cache conflicts, and dependency bloat during sync between machines.

## Implementation

Created `.stignore` at `D:\Claude Code\.stignore` with rules for:
- Godot `.godot/` editor cache and `.import` metadata files
- Python `__pycache__/` and `.venv/` directories
- Node.js `node_modules/`
- Build artifacts (`dist/`, `build/`)
- IDE state files (`.vscode/`)
- OS files (`Thumbs.db`, `.DS_Store`)
- SyncThing's own `.stversions/` folder

## Acceptance Criteria

- [x] `.stignore` file exists at `D:\Claude Code\.stignore`
- [x] Rules cover all known conflict-causing file types
- [x] Binary assets (.glb, .png) are NOT ignored (they should sync)

## Notes

Completed during Session 9 (SyncThing Recovery). The `.stignore` was created as part of the merge operation.
