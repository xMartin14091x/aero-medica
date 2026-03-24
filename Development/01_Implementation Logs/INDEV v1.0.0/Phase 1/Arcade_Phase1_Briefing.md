# Team Arcade — Phase 1 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 1 — Core Gameplay Loop | Tickets: ARC-01, ARC-02, ARC-03

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md at `D:\Claude Code\.claude\CLAUDE.md`
- Read Team Roster file at `D:\Claude Code\.claude\Team Roster\4. Team_Arcade.md`
- Adopt voice, code names, coding style
- Create today's Team Chat log

## 1. Context
- Phase 0 foundation is built: isometric camera, player movement, tile system, test level
- Syndicate is building the interaction/assessment systems (SYN-01, SYN-03) — you depend on SYN-03 for ARC-01
- Scaffold with mocks until Syndicate signals are ready — Arcade Mock-First Exception applies

## 2. Your Mission
Build the three visual/UI gameplay elements: contextual action menu (patient interaction), floating interaction prompts, and the first real scenario environment (Road Traffic Accident). By phase end, the player sees interaction prompts, can select assessment actions from a menu, and plays in a proper scenario level.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/3. Arcade/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### ARC-01 — Contextual Action Menu UI
- **File:** `Phase 1/4. Arcade/ARC-01_ContextualActionMenuUI.md`
- Action menu near patient with assessment options (Check Airway, Breathing, Pulse, Consciousness, Bleeding)
- Keyboard (1-5) and mouse selectable
- **Depends on SYN-03** — scaffold with mock signals first, wire live after SYN-03 signals complete

### ARC-02 — Interaction Prompt UI
- **File:** `Phase 1/4. Arcade/ARC-02_InteractionPromptUI.md`
- Floating "[E] Pick Up AED" prompts above interactable objects
- **Depends on SYN-01** — scaffold with mock; wire live after SYN-01 complete

### ARC-03 — First Scenario Environment (Road Traffic Accident)
- **File:** `Phase 1/4. Arcade/ARC-03_FirstScenarioEnvironment.md`
- Build RTA level: road intersection, placeholder vehicles, patient/equipment spawn points, NavMesh
- Create corresponding scenario data file
- **Start IMMEDIATELY** — no dependency, uses tile system from Phase 0

## 4. Parallel Execution — Start Now vs. Wait
- **Start IMMEDIATELY:** ARC-03 (no dependencies — build the level)
- **Start with mocks:** ARC-02 (mock interaction signal, wire SYN-01 later)
- **Start with mocks:** ARC-01 (mock assessment actions, wire SYN-03 later)

## 5. Logging & Handoff Requirements
- Log in Team Chat daily file | File OverseerReport when all tickets complete
- Update ticket status fields as you work

## 6. Boundaries — Do NOT Touch
- Do NOT implement interaction logic (Syndicate) | Do NOT implement medical states (Phase 2)
- Do NOT import final 3D assets — placeholder coloured boxes for vehicles

## 7. If You Hit a Blocker
- File in OverseerReport immediately — do not workaround without KP sign-off

---
Footer: Issued by KP (Overseer) — 08-03-2026
