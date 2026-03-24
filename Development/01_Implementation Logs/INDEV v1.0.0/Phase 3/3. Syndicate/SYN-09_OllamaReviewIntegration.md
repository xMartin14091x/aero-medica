# SYN-09 — Ollama Review Integration

**Phase:** Phase 3 — Telemetry & AI Reviewer
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-07, SYN-08
**Blocks:** SYN-10, ARC-07

---

## Scope
Implement the Ollama API client for AI performance review — sends structured telemetry + protocol analysis + error data + answer sheet to local Ollama instance and receives natural language performance review. Fully offline, zero cost. The centrepiece AI feature.

## Acceptance Criteria
- [ ] `scripts/ai/reviewer/ollama_review_client.gd` — HTTPRequest-based Ollama API client (localhost:11434)
- [ ] Method: `request_review(session_data: Dictionary, answer_sheet: Dictionary) -> void` — async HTTP call
- [ ] Signal: `review_received(review_text: String)`, `review_failed(error: String)`
- [ ] System prompt: senior EMT clinical instructor persona with grading rubric + answer sheet injection (stored in `data/prompts/triage_reviewer_system.txt`)
- [ ] Answer sheet: per-scenario JSON files in `data/protocols/` containing correct action sequences, correct triage tags, timing benchmarks, correct equipment selection
- [ ] User prompt: structured JSON payload containing: scenario_id, answer_sheet, patient_outcomes, action_log, timing_metrics, protocol_adherence, errors
- [ ] Expected response sections: Overall Assessment, Strengths, Areas for Improvement, Critical Errors, Recommendations
- [ ] Request timeout: 60 seconds (local model may be slower than cloud) with retry once on failure
- [ ] Graceful degradation: if Ollama unavailable → emit `review_failed` → game continues with quantitative scores only
- [ ] Ollama model configurable in `user_data/ai_config.json` (default: llama3.1:8b)
- [ ] Test: send sample session data + answer sheet → receive structured narrative review → verify sections present

## Boundaries — Do NOT Touch
- Do NOT implement NPC dialogue — F12 post-core scope (shares Ollama backend but different client)
- Do NOT implement response parsing — SYN-10
- Do NOT implement review display UI — ARC-07

## Notes
- Ollama endpoint: `http://localhost:11434/api/generate`
- No API key needed — Ollama is local
- Answer sheet approach: model compares player actions against correct protocol, doesn't need medical knowledge
- Max tokens: ~1500 for review response
- Include instruction in system prompt to structure response with clear section headers for parsing
- Ollama must be installed and running with a model pulled (e.g., `ollama pull llama3.1:8b`)
