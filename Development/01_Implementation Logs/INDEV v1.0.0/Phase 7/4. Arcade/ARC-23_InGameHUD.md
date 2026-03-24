# ARC-23 — In-Game HUD (Full)

**Phase:** Phase 7 — UI/UX & Localisation
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** ARC-02, ARC-06 (Phase 1/2 HUD components)
**Blocks:** None

---

## Scope
Assemble the complete in-game HUD — integrate all existing HUD components (timer, interaction prompts) and add minimap, equipment indicator, and patient status overview.

## Acceptance Criteria
- [x] `scenes/ui/hud/GameHUD.tscn` — CanvasLayer master HUD overlay
- [x] Existing timer/prompts/action menu integrated via parent HUD.tscn
- [x] **Top-left:** Minimap (150x150 ColorRect) — player dot (blue), patient dots (yellow), updates in _process()
- [x] **Bottom-left:** Equipment indicator — PanelContainer with header label + item name, wired to inventory_changed signal
- [x] **Right side:** Patient overview panel — scrollable VBoxContainer listing all patients with triage status
- [x] Pause overlay (Esc key): dark background + Resume/Restart/Quit to Menu buttons, get_tree().paused toggle
- [x] All elements offset from edges (16px margins), patient panel 80px from top/bottom
- [x] set_hud_visible(bool) method to hide during debrief/review
- [x] All text uses tr() translation keys
- [x] Test: minimap tracks player position relative to world bounds, pause toggles correctly, equipment updates on signal

## Boundaries — Do NOT Touch
- Do NOT implement the action menu here — ARC-01 is separate
- Do NOT implement dashboard UI in HUD — dashboard is post-scenario
