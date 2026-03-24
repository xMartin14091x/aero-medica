# Team Syndicate — Phase 2 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 2 — Medical Protocol System | Tickets: SYN-04, SYN-05, SYN-06

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `3. Team_Syndicate.md` | Create Team Chat log

## 1. Context
- Phase 1 complete: interaction system, inventory, assessment all working
- Monolith is building the medical state machine (MON-10) and deterioration (MON-11) in parallel
- You own the protocol definitions, triage logic, and time pressure system

## 2. Your Mission
Define the medical rules of the game — BCLS/ALS gold-standard protocols, START triage algorithm, and time pressure mechanics. By phase end, the game knows what the "correct" actions are and can validate player behaviour against them.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/2. Syndicate/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### SYN-04 — BCLS/ALS Protocol Definitions
- Protocol data files (JSON): BLS sequence, ALS sequence, START triage decision tree
- ProtocolValidator: validate player action sequences against gold standard
- **Depends on MON-10** for patient state data — scaffold with mock states if needed

### SYN-05 — Triage Tag System (START Protocol)
- Player assigns Green/Yellow/Red/Black tags to patients
- System validates correctness against actual medical state
- Incorrect tags logged but NOT prevented (stealth assessment)
- **Depends on SYN-04 and MON-10**

### SYN-06 — Time Pressure System
- Countdown timer with warning signals at 75/50/25%
- Deterioration rate multiplier increases as time progresses
- Timer pauses when game is paused
- **Depends on MON-11** for deterioration integration

## 4. Parallel Execution
- **Start IMMEDIATELY:** SYN-04 (protocol data files can be written now, validator scaffolded with mock states)
- **After MON-10 ready:** Wire SYN-04 validator + start SYN-05
- **After MON-11 ready:** SYN-06

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch triage visuals (ARC-04) or timer HUD (ARC-06)

---
Footer: Issued by KP (Overseer) — 08-03-2026
