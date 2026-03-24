# SYN-10 — AI Review Response Parser

**Phase:** Phase 3 — Telemetry & AI Reviewer
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-09
**Blocks:** ARC-07

---

## Scope
Parse the Claude API response into a structured data object that the Review UI can consume. Handles section extraction, formatting, and fallback for malformed responses.

## Acceptance Criteria
- [ ] `scripts/ai/claude/review_parser.gd` — parses Claude response text
- [ ] Method: `parse_review(response_text: String) -> Dictionary`
- [ ] Output format: `{overall_assessment: String, strengths: Array[String], improvements: Array[String], critical_errors: Array[String], recommendations: Array[String], raw_text: String}`
- [ ] Section detection: parses by header markers (## or **Section Name**)
- [ ] Fallback: if sections cannot be parsed → return `{raw_text: response_text}` and display as plain text
- [ ] Strips markdown formatting for clean display text
- [ ] Signal: `review_parsed(review_data: Dictionary)`
- [ ] Test: given a sample Claude response with sections → correctly extracts each section into arrays

## Boundaries — Do NOT Touch
- Do NOT implement the display UI — ARC-07
- Do NOT implement historical comparison — Phase 5 (F6.6)
