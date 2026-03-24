# Team Arcade — Phase 4 Briefing
**Issued by:** KP | **Date:** 10-03-2026 | **Project:** AeroMedica | **Phase:** 4 | **Tickets:** ARC-12, ARC-13

---

## 0. Pre-Work: Load Your Roster

Before anything else:
1. Read `D:\Claude Code\.claude\CLAUDE.md`
2. Read `D:\Claude Code\.claude\Team Roster\4. Team_Arcade.md`
3. Adopt your team voice, code names, and coding style
4. Create today's Team Chat log at `D:\Claude Code\.claude\Team Chat\3. Arcade\10-03-2026_Arcade.md`

---

## 1. Context

- **Phases 0, 1, 3** are complete. `PatientInteractionUI` (tabbed panel with Patient/Exam/Stabilize/Differential tabs) is fully working. The Patient tab has 6 SAMPLE category buttons. The Exam tab has 5 DRSABCDE assessment buttons.
- **Phase 4** opens now. You are expanding two tabs in `PatientInteractionUI`:
  - Patient tab → add OPQRST as a 7th category (ARC-12)
  - Exam tab → add vital sign assessment buttons with color-coding and equipment-gating feedback (ARC-13)
- **ARC-12 depends on MON-12.** ARC-13 depends on MON-11. Monolith starts both their tickets at the same time as you. You must scaffold with mocks first and wire live data when Monolith signals complete.
- Medica's clinical specs: `D:\Claude Code\.claude\Medical Reference\Consultation Log\01. AeroMedica_FeatureReview_09_03_2026.md` — Parts 2A and 2B

---

## 2. Your Mission

Expand `PatientInteractionUI` with two additions:

1. **ARC-12** — Add OPQRST as a 7th history category in the Patient tab, with pain-based auto-suggest and consciousness gating.
2. **ARC-13** — Add 8 vital sign assessment buttons in the Exam tab with color-coded result display, equipment-gating feedback, and section headers.

**Output location:** `scripts/ui/patient_interaction_ui.gd` and `scenes/ui/hud/PatientInteractionUI.tscn` (both modified, not replaced).

---

## 3. Ticket ARC-12 — OPQRST UI Integration

**Ticket file:** `Phase 4/4. Arcade/ARC-12_OPQRSTUIIntegration.md`
**Depends on:** MON-12 (scaffold with mocks first)

**What to do:**

1. **Add a 7th OPQRST button** to the Patient tab category button row. Label: `"OPQRST (Pain)"`. Use a visually distinct color (amber/orange tone) and/or pain-related icon to differentiate from the 6 SAMPLE buttons.

2. **Wire question display** — when clicked, show the 6 OPQRST questions in the same question-list format as SAMPLE categories. On question click, call the existing history-taking flow. Responses display in the same chat-style response log.

3. **Consciousness gating** — OPQRST button must be disabled/greyed for unresponsive patients. Tooltip: `"Patient is unresponsive — OPQRST requires verbal communication."` Use the same gating pattern already applied to SAMPLE buttons.

4. **Pain auto-suggest hint** — if the current patient has `pain_level > 0` (or if SAMPLE symptoms/pain responses contain pain keywords), display a subtle hint near the OPQRST button: `"This patient is in pain — consider OPQRST assessment"`. This is a teaching prompt, not a gate.

5. **Asked questions greyed** — mark OPQRST questions as asked with a checkmark, same as SAMPLE.

**Mock scaffold:** While waiting for MON-12, wire ARC-12 against a hard-coded mock `opqrst` dictionary with test responses. When Monolith files the Dependency Signal for MON-12 in OverseerReport, swap the mock for the live `HistoryTakingManager.ask_question("opqrst", key)` call.

**Acceptance criteria:** See ticket file.

---

## 4. Ticket ARC-13 — Vital Signs Assessment UI

**Ticket file:** `Phase 4/4. Arcade/ARC-13_VitalSignsAssessmentUI.md`
**Depends on:** MON-11 (scaffold with mocks first)

**What to do:**

1. **Add a "Vital Signs" section header** to the Exam tab, below the existing ABCDE section. Rename the existing section header to "Primary Survey (ABCDE)" if not already labelled. Add a visual divider between the two sections.

2. **Add 8 vital sign assessment buttons:**

   | Button | Assessment Action | Equipment Required |
   |--------|------------------|--------------------|
   | Heart Rate | `CHECK_HEART_RATE` | None |
   | Blood Pressure | `CHECK_BLOOD_PRESSURE` | BP Cuff |
   | SpO2 | `CHECK_SPO2` | Pulse Oximeter |
   | Pupils | `CHECK_PUPILS` | Penlight |
   | Temperature | `CHECK_TEMPERATURE` | Thermometer |
   | Blood Glucose | `CHECK_BLOOD_GLUCOSE` | Glucometer |
   | Cap Refill | `CHECK_CAPILLARY_REFILL` | None |
   | Skin Assessment | `CHECK_SKIN` | None |

   Buttons that require equipment should show a small equipment icon indicator.

3. **Color-coded result display** — use `MedicalStateComponent.VITAL_RANGES` (from MON-11) to determine color:
   - Green: within normal range
   - Yellow: abnormal but not critical
   - Red: critical value

   Display format example:
   ```
   Heart Rate: 118 BPM [TACHYCARDIA]      ← yellow
   Blood Pressure: 82/55 mmHg [HYPOTENSION]  ← red
   SpO2: 97% [NORMAL]                      ← green
   ```

4. **Equipment-gating feedback** — do NOT disable the button. Let the player click it. If they lack the equipment, display in the result area: `"Requires: [Equipment Name] — check your medical bag"`. This is the teaching moment.

5. **Skin assessment** — displays all 3 components: `"Skin: Pale, Cool, Diaphoretic [SHOCK SIGNS]"`. Add `[SHOCK SIGNS]` label when color=PALE AND temperature=COOL AND moisture=DIAPHORETIC.

6. **Results logged to telemetry** — emit `assessment_performed` signal for each vital sign check (already hooked into telemetry from Phase 1/3 work).

**Mock scaffold:** While waiting for MON-11, build the UI layout and button logic against a hard-coded mock `vital_results` dictionary. Wire to live `AssessmentManager` calls when Monolith files the Dependency Signal for MON-11.

**Acceptance criteria:** See ticket file.

---

## 5. Parallel Execution — Start Now vs. Wait

**Start IMMEDIATELY:**
- **ARC-12 scaffold** — Build the OPQRST button layout, question display, gating logic, and mock responses. Do NOT wait for MON-12.
- **ARC-13 scaffold** — Build the vital signs section, all 8 buttons, layout, color-coding logic, and mock result display. Do NOT wait for MON-11.

**Wire live when signals arrive:**
- When OverseerReport shows `MON-12 is COMPLETE / Dependency Signal`, replace ARC-12 mock data with live `HistoryTakingManager` calls.
- When OverseerReport shows `MON-11 is COMPLETE / Dependency Signal`, replace ARC-13 mock data with live `AssessmentManager` calls and `MedicalStateComponent.VITAL_RANGES`.

**Important:** Do NOT file ARC-12 or ARC-13 as Complete until the live wiring is done and tested. Complete = fully wired, not just scaffolded.

---

## 6. Logging & Handoff Requirements

- **Team Chat log:** `D:\Claude Code\.claude\Team Chat\3. Arcade\10-03-2026_Arcade.md`
- **OverseerReport:** Append to `D:\Claude Code\.claude\Team Chat\4. OverseerReport\10-03-2026_OverseerReport.md`
- **Ticket status:** Update `[~] IN PROGRESS` when you begin, `[x] Complete` when all criteria are checked and live-wired.
- File OverseerReport entries when: scaffold is complete (mark IN PROGRESS), and when live wiring is done (mark Complete).

---

## 7. Boundaries — Do NOT Touch

- Do not modify the Stabilize tab or Differential tab behavior
- Do not modify `HistoryTakingManager`, `AssessmentManager`, or `MedicalStateComponent` backend code — that belongs to Monolith (MON-11, MON-12)
- Do not create new manager scripts — all changes are in `patient_interaction_ui.gd` and `PatientInteractionUI.tscn`
- Do not modify any Phases 0–3 ticket files or their core implemented systems

---

## 8. If You Hit a Blocker

Stop immediately and file a blocker entry in `OverseerReport/10-03-2026_OverseerReport.md`. Do not attempt workarounds without KP sign-off. Include: what you were trying to do, what failed, and what you need to proceed.

---

*Issued by KP (Overseer) — 10-03-2026*
