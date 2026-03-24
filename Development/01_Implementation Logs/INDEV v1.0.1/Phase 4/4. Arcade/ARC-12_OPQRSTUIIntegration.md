# ARC-12 — OPQRST UI Integration in PatientInteractionUI

**Phase:** Phase 4 — OPQRST & Vital Signs
**Team:** Arcade — Frontend/Creative
**Status:** `[x] Complete`
**Depends on:** MON-12
**Blocks:** None

---

## Scope
Add OPQRST as a 7th category in the Patient tab of `PatientInteractionUI`. OPQRST questions should be visually grouped with SAMPLE but distinct, appearing as a separate section or tab within the Patient history panel.

## Implementation Detail

### PatientInteractionUI — Patient Tab Modification
The Patient tab currently shows 6 SAMPLE category buttons. Add OPQRST as:
- A 7th button labeled "OPQRST (Pain)" in a visually distinct color (e.g., amber/orange vs. the existing SAMPLE button colors)
- When clicked, shows the 6 OPQRST questions in the same question-list format as SAMPLE categories
- Responses display in the same chat-style response log

### Auto-Suggest Behavior
When a patient reports pain (pain_level > 0 in persona, or SAMPLE `where_hurts` / `pain_scale` responses contain pain keywords), display a subtle UI hint: "This patient is in pain — consider OPQRST assessment" near the OPQRST button. This is a teaching prompt, not a blocker.

### Unconscious Patient Gating
OPQRST button should be greyed out / disabled for unresponsive patients, with tooltip: "Patient is unresponsive — OPQRST requires verbal communication." Same gating logic as existing SAMPLE buttons.

### Visual Design
- OPQRST button uses a distinct icon or color to differentiate from SAMPLE (e.g., pain-related icon like a wave/pulse symbol)
- Section header in question list: "Pain Assessment (OPQRST)"
- Question format identical to SAMPLE: clickable buttons, greyed after asked, response in chat log

## Acceptance Criteria
- [x]OPQRST appears as 7th category button in Patient tab
- [x]OPQRST questions display and function identically to SAMPLE questions
- [x]Responses appear in the shared chat-style response log
- [x]OPQRST button disabled for unresponsive patients with tooltip explanation
- [x]Pain auto-suggest hint appears when patient has pain_level > 0
- [x]Visual distinction between SAMPLE and OPQRST buttons (color or icon)
- [x]Asked OPQRST questions greyed with checkmark (same as SAMPLE)

## Boundaries — Do NOT Touch
- Do not modify SAMPLE button layout or behavior
- Do not modify Exam/Stabilize/Differential tabs
- Do not modify `HistoryTakingManager` backend logic (MON-12 handles data)

## Notes
- Clinical reference: Medica Consultation Log #01, Part 2A
- OPQRST is the standard pain-focused companion to SAMPLE in EMT/paramedic training
