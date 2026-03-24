# MON-07 — Ollama Dialogue Integration & Connectivity

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Monolith — Core Systems
**Status:** `[x] Complete`
**Verified:** 21-03-2026 — code confirmed present via codebase investigation
**Depends on:** MON-03 (PatientPersona expansion — Complete), MON-04 (HistoryTakingManager — Complete)
**Blocks:** ARC-08

---

## Scope
Ensure Ollama local LLM integration is fully operational for patient AI conversation. The OllamaDialogueClient autoload exists and is registered, but needs connectivity verification, error handling improvements, and graceful degradation when Ollama is unavailable.

## What Was Already Done
- `ollama_dialogue_client.gd` — Created and registered as autoload
- `user_data/ai_config.json` — Config file exists (localhost:11434, llama3.1:8b)
- `patient_interaction_ui.gd` — Patient tab wired to call Ollama with persona context
- Fallback to static SAMPLE responses when Ollama unavailable

## Remaining Work
- [ ] Verify Ollama connectivity on game startup with user-visible status indicator
- [ ] Add startup log message: "Ollama: Connected (model: llama3.1:8b)" or "Ollama: Unavailable — using static responses"
- [ ] Tune system prompt for medical patient roleplay (persona + medical state + SAMPLE history context)
- [ ] Add response streaming or "Patient is thinking..." indicator during Ollama response wait
- [ ] Handle timeout gracefully (60s timeout in config, show fallback after timeout)
- [ ] Test with Ollama running on non-localhost (configurable via ai_config.json)

## Acceptance Criteria
- [ ] Game launches without error when Ollama is not running
- [ ] Game connects to Ollama when available and patient responds with AI-generated dialogue
- [ ] Static SAMPLE fallback works when Ollama unavailable
- [ ] System prompt includes full patient context (persona + medical state + history)
- [ ] Console log shows Ollama connection status on startup

## Boundaries — Do NOT Touch
- Do not modify PatientPersona resource structure
- Do not change scenario JSON format

## Notes
- Ollama must be started separately by the user (`ollama serve`)
- Model `llama3.1:8b` must be pulled first (`ollama pull llama3.1:8b`)
- User may run Ollama on a different IP — ai_config.json supports this
