# Team Arcade — Phase 2 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 2 — Medical Protocol System | Tickets: ARC-04, ARC-05, ARC-06

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `4. Team_Arcade.md` | Create Team Chat log

## 1. Context
- Phase 1 complete: action menu UI, interaction prompts, RTA level all built
- Monolith is building medical state machine (MON-10) and Syndicate is building triage system (SYN-05)
- You visualise the medical state — triage tags, patient status indicators, timer display

## 2. Your Mission
Make the medical system visible — colour-coded triage tags on patients, visual indicators of patient condition (breathing, bleeding, consciousness), and the scenario countdown timer. Players read these visual cues to make triage decisions.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/3. Arcade/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### ARC-04 — Triage Tag Visuals
- Colour-coded 3D labels (Green/Yellow/Red/Black) above patients after triage assignment
- Incorrect tags pulse subtly (stealth assessment — don't say "WRONG")
- **Depends on SYN-05** — scaffold with mock tag data

### ARC-05 — Patient Status Visual Indicators
- Breathing animation, bleeding particles, consciousness posture changes, cardiac arrest/dead desaturation
- Updates in real-time via MedicalStateComponent signals
- **Depends on MON-10** — scaffold with mock state changes

### ARC-06 — Scenario Timer HUD
- MM:SS countdown, white → yellow (50%) → red (25%) → pulsing red (10%)
- **Depends on SYN-06** — scaffold with mock timer signal

## 4. Parallel Execution
- **Start IMMEDIATELY with mocks:** All 3 tickets (ARC-04, ARC-05, ARC-06) — scaffold visuals with mock data, wire live signals when dependencies complete

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch medical logic or triage validation (Monolith/Syndicate scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
