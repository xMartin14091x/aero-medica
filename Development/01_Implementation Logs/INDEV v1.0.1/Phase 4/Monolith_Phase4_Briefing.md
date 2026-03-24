# Team Monolith — Phase 4 Briefing
**Issued by:** KP | **Date:** 10-03-2026 | **Project:** AeroMedica | **Phase:** 4 | **Tickets:** MON-11, MON-12

---

## 0. Pre-Work: Load Your Roster

Before anything else:
1. Read `D:\Claude Code\.claude\CLAUDE.md`
2. Read `D:\Claude Code\.claude\Team Roster\2. Team_Monolith.md`
3. Adopt your team voice, code names, and coding style
4. Create today's Team Chat log at `D:\Claude Code\.claude\Team Chat\1. Monolith\10-03-2026_Monolith.md`

---

## 1. Context

- **Phases 0, 1, 3** are complete. The gameplay loop (DRSABCDE assessment, SAMPLE history taking, Ollama AI dialogue, medical bag, differential diagnosis, telemetry) is all working.
- **Phase 2** (model importation) is pending — awaiting 3D assets from Chief Manager. **You are not involved in Phase 2.**
- **Phase 4** opens now. Your job is to build the data model foundation that all of Phase 5 (ECG, GCS, Secondary Survey) and Phase 6 (Drug Administration) depend on. Do not skip steps — Phase 5 teams will be blocked if your fields are missing.
- Medica's clinical specs live at: `D:\Claude Code\.claude\Medical Reference\Consultation Log\01. AeroMedica_FeatureReview_09_03_2026.md` — read Parts 2A and 2B before writing any vital sign values.

---

## 2. Your Mission

Produce two backend expansions:

1. **MON-11** — Expand `MedicalStateComponent` with 15+ vital sign fields, add 8 new `AssessmentAction` entries with equipment-gating, add `VITAL_RANGES` constant, update `ScenarioManager` to parse new JSON fields, and wire deterioration into vital signs.
2. **MON-12** — Add OPQRST as the 7th history category in `history_questions.json`, expand `PatientPersona` with `history_opqrst` field, update ALL scenario JSON files with OPQRST responses and `examination_findings`, and ensure `ScenarioManager` parses both.

**Output locations:**
- `scripts/components/medical_state_component.gd`
- `scripts/gameplay/assessment_manager.gd`
- `scripts/gameplay/deterioration_system.gd`
- `scripts/managers/scenario_manager.gd`
- `scripts/entities/patient_persona.gd`
- `data/history_questions.json`
- `data/scenarios/scenario_cardiac.json`
- `data/scenarios/scenario_rta.json`
- `data/scenarios/scenario_building_fire.json`
- `data/scenarios/scenario_mci.json`
- `data/scenarios/scenario_tutorial.json`

---

## 3. Ticket MON-11 — Vital Signs Data Model Expansion

**Ticket file:** `Phase 4/2. Monolith/MON-11_VitalSignsDataExpansion.md`

**What to do:**

1. **Add all new exported fields** to `MedicalStateComponent`: `heart_rate`, `blood_pressure_systolic`, `blood_pressure_diastolic`, `spo2`, `temperature`, `blood_glucose`, `capillary_refill`, `pupil_left_size`, `pupil_right_size`, `pupil_left_reactive`, `pupil_right_reactive`, `gcs_eye`, `gcs_verbal`, `gcs_motor`, `ecg_rhythm`, `skin_color`, `skin_temperature`, `skin_moisture`. Use the exact field names in the ticket — Arcade and Phase 5 teams will reference these by name.

2. **Add 8 new AssessmentActions** to `assessment_manager.gd`: `CHECK_HEART_RATE`, `CHECK_BLOOD_PRESSURE`, `CHECK_SPO2`, `CHECK_PUPILS`, `CHECK_TEMPERATURE`, `CHECK_BLOOD_GLUCOSE`, `CHECK_CAPILLARY_REFILL`, `CHECK_SKIN`. Each returns the specified dictionary. Equipment-gated actions must check inventory before returning data; on failure, return `{ "error": "Requires [equipment name]" }` and emit a signal for the UI.

3. **Add `VITAL_RANGES` constant** — see ticket for exact values. This will be consumed by ARC-13 for color-coding. Make it a `const` in `MedicalStateComponent` so it is accessible via `MedicalStateComponent.VITAL_RANGES`.

4. **Update `ScenarioManager`** to parse the new `vitals` JSON block from each scenario and apply all fields to `MedicalStateComponent` on scenario load.

5. **Update `deterioration_system.gd`** to modify vital signs over time based on patient condition (bleeding → HR up, BP down, SpO2 down; airway obstruction → SpO2 drops; cardiac arrest → all vitals critical/absent).

6. **Update scenario JSON files** — add `vitals` blocks with clinically accurate values to `scenario_cardiac.json` and `scenario_rta.json` at minimum. Cross-check values against Medica Consultation Log #01 Part 2B. Note: SpO2 must be flagged inaccurate in CO poisoning scenarios.

7. **Update `get_state_summary()`** to include all new fields in its return dictionary.

**Critical warning:** Do NOT change the return format of the 5 existing assessment actions (CHECK_AIRWAY, CHECK_BREATHING, CHECK_PULSE, CHECK_CONSCIOUSNESS, CHECK_BLEEDING). Arcade's existing UI depends on these.

**Acceptance criteria:** See ticket file. All criteria must be checked before filing OverseerReport.

---

## 4. Ticket MON-12 — OPQRST History & Scenario Data Expansion

**Ticket file:** `Phase 4/2. Monolith/MON-12_OPQRSTAndScenarioExpansion.md`

**What to do:**

1. **Add OPQRST to `history_questions.json`** as a new `"opqrst"` key at the same level as the 6 SAMPLE categories. It contains 6 questions: onset, provocation, quality, radiation, severity, time_course. Use the exact question text in the ticket.

2. **Add `history_opqrst: Dictionary`** field to `PatientPersona`. Update `get_history_response()` to handle `"opqrst"` category — it should call `history_opqrst.get(question_key, "")`. No new gating needed — OPQRST uses the same consciousness check as SAMPLE.

3. **Update ALL scenario JSON files** — add `"opqrst"` block inside each patient's `"history"` section. Conscious patients get full OPQRST responses. Unresponsive patients get `"(Patient is unresponsive — information unavailable)"` or responses attributed to a bystander if clinically appropriate. See ticket for Wichai (cardiac arrest via coworker) and Somchai/Nanthida/Prasert (RTA) examples. OPQRST responses must be character-consistent with existing SAMPLE dialogue.

4. **Add `examination_findings` dictionary** to scenario JSON schema (per ticket spec — 7 body regions). Store as `@export var examination_findings: Dictionary = {}` on `MedicalStateComponent`. Update `ScenarioManager` to parse it. This field is consumed by Phase 5's secondary survey (MON-15) — it must be present even if values are empty strings.

5. **Update `ScenarioManager`** to parse both `opqrst` and `examination_findings` fields.

**Acceptance criteria:** See ticket file.

---

## 5. Parallel Execution — Start Now vs. Wait

**Start IMMEDIATELY:**
- **MON-11** — No dependencies, begin now
- **MON-12** — No dependencies, begin now (independent of MON-11)

**You do NOT wait for Arcade.** MON-11 and MON-12 can run in parallel. Your Conductor and Technologist can split these between team members.

**Important:** When MON-11 is complete, file an OverseerReport entry immediately with a **Dependency Signal** for ARC-13. When MON-12 is complete, file a Dependency Signal for ARC-12. Arcade is scaffolding with mocks and will wire up to your work as soon as you signal.

---

## 6. Logging & Handoff Requirements

- **Team Chat log:** `D:\Claude Code\.claude\Team Chat\1. Monolith\10-03-2026_Monolith.md`
- **OverseerReport:** Append to `D:\Claude Code\.claude\Team Chat\4. OverseerReport\10-03-2026_OverseerReport.md` (create if it doesn't exist)
- **Dependency Signal format** (MANDATORY — include in OverseerReport when each ticket completes):
  ```
  ### Dependency Signal
  Ticket MON-11 is COMPLETE. Teams waiting on this ticket may now proceed:
  - Arcade: ARC-13 now unblocked
  - Monolith: MON-13, MON-14 now unblocked (Phase 5)

  Ticket MON-12 is COMPLETE. Teams waiting on this ticket may now proceed:
  - Arcade: ARC-12 now unblocked
  - Monolith: MON-15 now unblocked (Phase 5)
  ```
- **Ticket status:** Update the `Status` field in each ticket file: `[~] IN PROGRESS` when you begin, `[x] Complete` when all criteria are checked.

---

## 7. Boundaries — Do NOT Touch

- Do not modify `PatientInteractionUI` or any UI scenes/scripts — that is Arcade's domain (ARC-12, ARC-13)
- Do not modify ECG, GCS, or drug system code — that is Phase 5/6 work
- Do not modify Phases 0–3 ticket files or their implemented code (except for the explicit `get_state_summary()` and scenario JSON updates above)
- Do not create any new scene files (.tscn) — backend code and JSON only

---

## 8. If You Hit a Blocker

Stop immediately and file a blocker entry in `OverseerReport/10-03-2026_OverseerReport.md`. Do not attempt workarounds without KP sign-off. Include: what you were trying to do, what failed, and what you need to proceed.

---

*Issued by KP (Overseer) — 10-03-2026*
