# Team Arcade — Phase 7 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 7 — UI/UX & Localisation | Tickets: ARC-21, ARC-22, ARC-23, ARC-24, ARC-25

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `4. Team_Arcade.md` | Create Team Chat log

## 1. Context
- Phase 6 complete: all 5 scenario levels built with assets, full audio system operational
- This phase is Arcade-only — you own the entire UI shell and localisation
- No cross-team dependencies. All systems are built; you wrap them in a polished user interface.

## 2. Your Mission
Build the complete UI shell: main menu, scenario selection, in-game HUD, settings, and Thai+English localisation. By phase end, a player can launch the game, navigate menus, select a scenario, play with full HUD, adjust settings, and switch language — all in Thai or English.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/3. Arcade/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### ARC-21 — Main Menu Screen
- Title screen with game logo/title, subtle 3D background or animated scene
- Buttons: Start Tutorial, Select Scenario, Dashboard, Settings, Quit
- Clean layout, consistent with game's visual identity
- **Start IMMEDIATELY**

### ARC-22 — Scenario Select Screen
- Grid or list view of all 5 scenarios with difficulty stars (1–5)
- Unlock progression: Tutorial must be completed to unlock others
- Each scenario card: thumbnail, title, description, best score, time estimate
- **Start IMMEDIATELY**

### ARC-23 — In-Game HUD
- Master HUD overlay combining all existing UI elements:
  - Scenario timer (from ARC-06)
  - Interaction prompts (from ARC-02)
  - Action menu (from ARC-01)
  - Minimap (new — top-corner overview)
  - Equipment indicator (currently held item)
  - Patient status panel (from ARC-05)
  - Pause menu overlay (resume, restart, settings, quit to menu)
- **Start IMMEDIATELY** — integrates existing UI components

### ARC-24 — Settings Menu
- Audio controls: master volume, music volume, SFX volume (sliders)
- Language toggle: Thai / English (instant switch)
- Controls display: key bindings reference (read-only for now)
- Accessibility: UI scale slider, high contrast toggle, colourblind-friendly triage patterns
- Settings persist to user:// config file
- **Start IMMEDIATELY**

### ARC-25 — Thai + English Localisation
- 200+ translation keys in CSV or Godot .translation format
- All UI strings externalised — no hardcoded text
- Thai font: Noto Sans Thai (or equivalent, Google Fonts, OFL license)
- Instant language switching without scene reload
- Thai is primary language (TMH2026 competition is Thai)
- **Start IMMEDIATELY**

## 4. Parallel Execution
- **Start IMMEDIATELY:** All 5 tickets (all independent, no cross-team dependency)
- Recommended order: ARC-25 first (localisation infrastructure affects all UI), then ARC-21 → ARC-22 → ARC-24 → ARC-23

## 5–7. Standard: Log in Team Chat, file OverseerReport. No boundaries to other teams this phase — Arcade owns everything here.

---
Footer: Issued by KP (Overseer) — 08-03-2026
