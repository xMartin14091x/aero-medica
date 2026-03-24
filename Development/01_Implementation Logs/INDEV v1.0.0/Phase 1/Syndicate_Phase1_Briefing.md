# Team Syndicate — Phase 1 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 1 — Core Gameplay Loop | Tickets: SYN-01, SYN-02, SYN-03

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md at `D:\Claude Code\.claude\CLAUDE.md`
- Read Team Roster file at `D:\Claude Code\.claude\Team Roster\3. Team_Syndicate.md`
- Adopt voice, code names, coding style
- Create today's Team Chat log

## 1. Context
- Phase 0 foundation is built: player moves in isometric space, InteractableComponent/TelemetryEmitter signals defined
- Monolith is building Patient and Equipment entities in parallel (MON-07, MON-08)
- Your interaction system wires into the InteractableComponent signal contract (`interacted` signal, `can_interact()` method)

## 2. Your Mission
Build the three core interaction systems: detect-and-interact (E key), equipment pickup/carry/use, and patient assessment actions. By phase end, the player can walk to a patient, press E, assess them, pick up equipment, and use it — all logged in telemetry.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/2. Syndicate/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### SYN-01 — Interaction System
- **File:** `Phase 1/3. Syndicate/SYN-01_InteractionSystem.md`
- InteractionManager on Player: detect nearest interactable, E key triggers interaction, telemetry logging
- This is the foundation — SYN-02 and SYN-03 depend on it

### SYN-02 — Equipment Inventory System
- **File:** `Phase 1/3. Syndicate/SYN-02_EquipmentInventorySystem.md`
- InventoryComponent: pick up equipment, carry one item, use on patient, drop (Q key)
- Visual: held item follows player as child node

### SYN-03 — Patient Assessment Actions
- **File:** `Phase 1/3. Syndicate/SYN-03_PatientAssessmentActions.md`
- AssessmentManager: interact with patient → assessment mode → check airway/breathing/pulse/consciousness/bleeding
- Assessment reveals patient state data, logged in telemetry

## 4. Parallel Execution — Start Now vs. Wait
- **Start IMMEDIATELY:** SYN-01 — scaffold with mock InteractableComponent if MON-07/08 not yet ready
- **After SYN-01:** SYN-02 and SYN-03 (both depend on interaction system, independent of each other)

## 5. Logging & Handoff Requirements
- Log in Team Chat daily file | File OverseerReport when all tickets complete
- Update ticket status fields as you work

## 6. Boundaries — Do NOT Touch
- Do NOT implement medical state transitions (Phase 2) | Do NOT implement the action menu UI (ARC-01)
- Do NOT implement triage or treatment (Phase 2)

## 7. If You Hit a Blocker
- File in OverseerReport immediately — do not workaround without KP sign-off

---
Footer: Issued by KP (Overseer) — 08-03-2026
