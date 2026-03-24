# Team Syndicate — Phase 8 Briefing
Issued by: KP | Date: 08-03-2026 | Project: AeroMedica | Phase: 8 — Testing & Competition Build | Tickets: SYN-16

## 0. Pre-Work: Load Your Roster
- Read CLAUDE.md + Team Roster `3. Team_Syndicate.md` | Create Team Chat log

## 1. Context
- Phases 0–7 complete: full game built, all systems operational
- Competition deadline: April 2, 2026 (TMH2026)
- Ollama AI review integration needs thorough testing with real scenario data before competition demo

## 2. Your Mission
Validate the AI integration end-to-end. Test Ollama with 5+ real scenario sessions covering edge cases (empty session, perfect run, catastrophic failure). Verify timeout handling, optimise prompts and answer sheets for quality, validate response times, compare models, and cache sample reviews for offline demo fallback. All testing is local — zero cost.

**Output:** `Projects/aero-medica/` | **Team Chat:** `.claude/Team Chat/2. Syndicate/` | **OverseerReport:** `.claude/Team Chat/4. OverseerReport/`

## 3. Tickets

### SYN-16 — AI Integration Testing
- Test with 5+ complete scenario sessions (varied performance levels)
- Edge cases: empty telemetry, perfect protocol adherence, catastrophic errors (all patients dead), Ollama unavailable
- Prompt + answer sheet optimisation: ensure Ollama produces useful, educational, non-punitive reviews based on rubric comparison
- Model comparison: test at least 2 models (e.g., llama3.1:8b, mistral:7b) — document quality differences
- Response time validation: review must generate within 30 seconds on target hardware
- Cache 3–5 sample reviews for offline demo fallback (no Ollama needed for judges to see the feature)
- **Start IMMEDIATELY** — full system available for testing

## 4. Parallel Execution
- **Start IMMEDIATELY:** SYN-16 (single ticket)

## 5–7. Standard: Log in Team Chat, file OverseerReport, do NOT modify game logic or UI — testing and prompt tuning only

---
Footer: Issued by KP (Overseer) — 08-03-2026
