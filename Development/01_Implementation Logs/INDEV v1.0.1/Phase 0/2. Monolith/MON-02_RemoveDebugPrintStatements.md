# MON-02 — Remove Debug Print Statements

**Phase:** Phase 0 — Bug Fixes & Tech Debt
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** None
**Priority:** Low

---

## Scope

Remove four `print()` debug calls from `player_controller.gd` that were added during animation debugging. They pollute the Godot console output but cause no functional issues.

## Implementation

Remove these four lines:

1. **Line 46:** `print("Player animations found: ", anims)`
2. **Line 66:** `print("Using idle='%s', walk='%s'" % [_anim_idle, _anim_walk])`
3. **Line 73:** `print("Root bone: '%s'" % root_bone_name)`
4. **Line 134:** `print("Stripped root motion track: %s in '%s'" % [path_str, anim_name])`

## Files to Modify

- `scripts/gameplay/player_controller.gd` — Remove 4 print() lines

## Acceptance Criteria

- [ ] All four `print()` calls removed
- [ ] No `print()` calls remain in `player_controller.gd`
- [ ] Player animation system still functions correctly (idle/walk switching, root motion stripping)
- [ ] Godot console is clean of animation debug output on game start

## Boundaries — Do NOT Touch

- Do NOT modify any logic — only remove the print() lines
- Do NOT add logging replacements (no push_warning, no Logger calls)
