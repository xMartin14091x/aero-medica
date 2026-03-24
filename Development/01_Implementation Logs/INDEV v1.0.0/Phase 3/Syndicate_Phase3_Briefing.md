# Team Syndicate — Phase 3 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 3 — Telemetry & AI Reviewer | Tickets: SYN-07, SYN-08, SYN-09, SYN-10

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `3. Team_Syndicate.md` | Create Team Chat log

## 1. Context
- Phase 2 complete: BCLS/ALS protocols defined (SYN-04), triage system built (SYN-05), time pressure working (SYN-06)
- Monolith is wiring telemetry pipeline (MON-12) this phase — you analyse the telemetry output
- You own the entire stealth assessment brain: protocol adherence, error detection, Ollama review integration (answer sheet approach), response parsing

## 2. Your Mission
Build the stealth assessment engine — analyse player performance against gold-standard protocols, detect errors, send telemetry + answer sheet to local Ollama for narrative review, and parse the AI response into structured data. By phase end, a complete scenario session can be analysed and a personalised AI review generated — fully offline, zero cost.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/2. Syndicate/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### SYN-07 — Protocol Adherence Tracker
- Analyse player action sequences against BCLS/ALS gold-standard protocols from SYN-04
- Generate adherence report: correct steps, missed steps, wrong-order steps, unnecessary steps
- Calculate per-protocol adherence percentage
- **Depends on MON-12** for telemetry data — scaffold with mock telemetry session data

### SYN-08 — Error Detection System
- Detect and categorise player errors: wrong triage tag, skipped assessment, wrong treatment priority, wrong equipment usage
- Severity levels: CRITICAL (life-threatening mistake), MAJOR (protocol violation), MINOR (suboptimal sequence)
- Error log feeds into AI review prompt
- **Depends on SYN-07** — needs adherence data to cross-reference

### SYN-09 — Ollama Review Integration
- Implement Ollama API client (HTTP request to localhost:11434)
- Compose prompt from: telemetry session data, protocol adherence report, error log, scenario context, **protocol answer sheet** (correct actions per scenario)
- Answer sheet approach: model compares player actions against correct protocol — doesn't need medical knowledge
- Send request, receive narrative performance review. Fully offline, zero cost
- Handle timeouts, Ollama-not-running gracefully (fall back to quantitative scores only)
- **Depends on SYN-07, SYN-08** — needs analysis data to compose prompt

### SYN-10 — AI Review Response Parser
- Parse Ollama's narrative response into structured sections: overall assessment, strengths, areas for improvement, critical errors, recommendations
- Validate response structure, handle malformed responses with fallback
- Output structured data ready for Arcade's display panel (ARC-07)
- **Depends on SYN-09**

## 4. Parallel Execution
- **Start IMMEDIATELY with mocks:** SYN-07 (scaffold with mock telemetry data)
- **After SYN-07:** SYN-08
- **After SYN-08:** SYN-09 → SYN-10 (sequential chain)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT touch telemetry pipeline wiring (Monolith scope) or review display UI (Arcade scope)

---
Footer: Issued by KP (Overseer) — 08-03-2026
