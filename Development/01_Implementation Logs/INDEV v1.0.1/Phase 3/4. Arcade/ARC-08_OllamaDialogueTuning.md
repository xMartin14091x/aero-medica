# ARC-08 — Ollama Dialogue UX & Response Display

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Arcade — UI/Creative
**Status:** `[x] Complete`
**Verified:** 21-03-2026 — code confirmed present via codebase investigation
**Depends on:** MON-07 (Ollama connectivity)
**Blocks:** None

---

## Scope
Polish the AI dialogue experience in the Patient tab — loading indicators, response formatting, conversation flow, and visual feedback for when Ollama is processing vs when static fallback is used.

## Remaining Work
- [ ] Add "Patient is thinking..." animated indicator while waiting for Ollama response
- [ ] Format AI responses with proper text wrapping and paragraph breaks
- [ ] Distinguish AI responses from static SAMPLE responses visually (e.g., icon or color hint)
- [ ] Add system message when Ollama connects/disconnects mid-session
- [ ] Rate-limit player questions (prevent spam-clicking while Ollama processes)
- [ ] Show "AI Dialogue" or "Scripted Responses" indicator in Patient tab header
- [ ] Conversation history scrollback without losing context

## Acceptance Criteria
- [ ] Player sees clear feedback while AI processes response
- [ ] AI responses display correctly with proper formatting
- [ ] No duplicate messages when clicking rapidly
- [ ] Visual indicator shows whether AI or scripted mode is active

## Boundaries — Do NOT Touch
- Do not modify ollama_dialogue_client.gd backend logic
- Do not change the Ollama API protocol
