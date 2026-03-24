# Team Monolith — Phase 0 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 0 — Foundation & Architecture | Tickets: MON-01 through MON-06

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md at `D:\Claude Code\.claude\CLAUDE.md`
- Read Team Roster file at `D:\Claude Code\.claude\Team Roster\2. Team_Monolith.md`
- Adopt voice, code names, coding style
- Create today's Team Chat log at `D:\Claude Code\.claude\Team Chat\1. Monolith\08-03-2026_Monolith.md`

## 1. Context
- **New project.** AeroMedica is a Godot 4.x isometric 3D medical emergency simulation game
- **Engine decision is final:** Godot 4.x with GDScript — approved by Chief Manager 08-03-2026
- **Architecture is defined:** See `Main TechStack Logic.md` for folder structure, entity composition, system architecture, and signal contracts
- **OVR-01 is pre-complete:** Overseer has already defined project standards (naming, autoloads, F12 hooks). Reference `Phase 0/1. Overseer/OVR-01_ProjectArchitectureStandards.md`
- **No prior code exists.** This is a greenfield bootstrap

## 2. Your Mission
Build the complete Godot project skeleton: folder structure, core singletons, isometric camera, player movement, tile system, and base component interfaces. By the end of Phase 0, a player character should walk around an isometric test level with the camera following — and all signal contracts for telemetry and interaction should be defined.

**Output locations:**
- Godot project: `D:\Claude Code\Claude Projects\AeroMedica\Projects\game\`
- Team Chat log: `D:\Claude Code\.claude\Team Chat\1. Monolith\08-03-2026_Monolith.md`
- OverseerReport: `D:\Claude Code\.claude\Team Chat\4. OverseerReport\08-03-2026_OverseerReport.md`

## 3. Tickets

### MON-01 — Godot Project Bootstrap
- **File:** `Phase 0/2. Monolith/MON-01_GodotProjectBootstrap.md`
- **What to do:**
  1. Create `Projects/game/` directory
  2. Create `project.godot` with project name "AeroMedica", window 1920x1080, stretch mode canvas_items
  3. Create ALL subdirectories per Architecture Overview in Main TechStack Logic
  4. Verify project opens in Godot without errors
- **Acceptance:** project.godot exists, all folders exist, opens cleanly

### MON-02 — GameManager Singleton
- **File:** `Phase 0/2. Monolith/MON-02_GameManagerSingleton.md`
- **What to do:**
  1. Create `scripts/core/game_manager.gd` extending Node
  2. Implement state enum (MENU, PLAYING, PAUSED, DEBRIEF), state_changed signal, change_scene method
  3. Register as autoload in project.godot
- **Acceptance:** Autoload works, state transitions emit signal

### MON-03 — Isometric Camera Rig
- **File:** `Phase 0/2. Monolith/MON-03_IsometricCameraRig.md`
- **What to do:**
  1. Create camera scene + script
  2. Orthographic projection, true isometric angle (~35.264° pitch, 45° yaw)
  3. Smooth follow with lerp, optional zoom via mouse scroll
  4. Test with simple mesh target
- **Acceptance:** Camera follows target smoothly at correct isometric angle with zoom

### MON-04 — Player Controller
- **File:** `Phase 0/2. Monolith/MON-04_PlayerController.md`
- **What to do:**
  1. Create Player scene (CharacterBody3D) with placeholder mesh, collision, NavigationAgent3D, InteractionArea (Area3D)
  2. WASD input mapping in project.godot
  3. Isometric movement (rotate input 45° to match camera)
  4. move_and_slide physics movement
- **Important:** Movement direction must be rotated to match isometric camera — pressing W should move the player toward the top-right of the screen
- **Acceptance:** Player moves in 8 directions correctly oriented to isometric view

### MON-05 — Tile Environment Foundation
- **File:** `Phase 0/2. Monolith/MON-05_TileEnvironmentFoundation.md`
- **What to do:**
  1. Create 3 tile scenes (Road, Sidewalk, Grass) — placeholder coloured boxes with collision
  2. Build 10x10 test level combining all tile types
  3. Add NavigationRegion3D with baked NavMesh
  4. Place Player + Camera in test level
- **Acceptance:** Player walks around a tiled level, camera follows, no visual artifacts

### MON-06 — Base Component Library
- **File:** `Phase 0/2. Monolith/MON-06_BaseComponentLibrary.md`
- **What to do:**
  1. Create `InteractableComponent` — signals + exports + dialogue_capable flag
  2. Create `TelemetryEmitter` — action signals + dialogue_event signal
  3. Create `TelemetryCollector` — autoload singleton, session storage, JSON export
  4. Create `PatientPersona` — Resource class with AVPU scale, persona exports, get_persona_prompt() skeleton
  5. Register TelemetryCollector as autoload
- **Important:** These are INTERFACE SKELETONS. Define signals, exports, and method signatures. Do NOT implement gameplay logic — Phase 1 will do that.
- **Acceptance:** All scripts exist, load without errors, signals defined, TelemetryCollector autoload registered

## 4. Parallel Execution — Start Now vs. Wait
**Start IMMEDIATELY (no dependencies):**
- MON-01 (bootstrap) — start first, everything depends on it
- After MON-01: MON-02, MON-03, MON-05, MON-06 can all proceed in parallel
- MON-04 depends on MON-03 (needs camera angle to calculate movement rotation) but can start scaffolding immediately

**Blocked tickets:** None — all 6 tickets are Monolith-internal, zero cross-team dependencies.

**ZCB Status:** Clean — Monolith owns all Phase 0 implementation tickets.

## 5. Logging & Handoff Requirements
- Log all work in Team Chat: `D:\Claude Code\.claude\Team Chat\1. Monolith\08-03-2026_Monolith.md`
- When ALL tickets are complete, file OverseerReport: `D:\Claude Code\.claude\Team Chat\4. OverseerReport\08-03-2026_OverseerReport.md`
- Update each ticket's status field as you work (`PENDING` → `IN PROGRESS` → `Complete`)
- No Dependency Signal needed — no other teams are active in Phase 0

## 6. Boundaries — Do NOT Touch
- Do NOT modify any file in `Development/` except ticket status updates
- Do NOT implement game logic beyond what tickets specify (no interaction handling, no patient AI, no scoring)
- Do NOT create final art assets — placeholders only
- Do NOT connect to any external API (Claude, Ollama)
- Do NOT write UI screens (menus, HUD, dashboards) — Phase 7 scope

## 7. If You Hit a Blocker
- Stop and file a blocker in OverseerReport — do not workaround without KP sign-off
- Common Godot 4.x issues: check [Godot docs](https://docs.godotengine.org/en/stable/) and [GDScript reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/)

---
Footer: Issued by KP (Overseer) — 08-03-2026
