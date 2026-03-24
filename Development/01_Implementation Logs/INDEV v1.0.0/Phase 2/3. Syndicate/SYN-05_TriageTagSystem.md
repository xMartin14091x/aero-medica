# SYN-05 — Triage Tag System (START Protocol)

**Phase:** Phase 2 — Medical Protocol System
**Team:** Syndicate — Backend/Efficiency
**Status:** `[x] Complete`
**Depends on:** SYN-04, MON-10
**Blocks:** ARC-04

---

## Scope
Implement the triage tag assignment system — player can assign Green/Yellow/Red/Black tags to patients following the START triage protocol. System validates correctness against the patient's actual medical state.

## Acceptance Criteria
- [x] `scripts/medical/triage_system.gd` — manages triage tag assignments
- [x] Triage tag enum: GREEN (minor), YELLOW (delayed), RED (immediate), BLACK (deceased)
- [x] `assign_tag()` records assignment and validates against correct tag
- [x] Player selects tag colour → assigned to patient → validated, once-only (no re-tagging)
- [x] `get_correct_tag(patient) -> TriageTag` — delegates to MedicalStateComponent.get_triage_priority()
- [x] Signal: `triage_assigned(patient, assigned_tag, correct_tag, is_correct: bool)`
- [x] TelemetryEmitter event: `triage_assign` with assigned_tag, correct_tag, is_correct, time_elapsed
- [x] Incorrect tags logged but NOT prevented (stealth assessment)
- [x] `get_triage_summary()` returns accuracy stats for debrief

## Boundaries — Do NOT Touch
- Do NOT implement the triage tag visual/colour display — ARC-04
- Do NOT implement tag reassignment — once tagged, it's final for that scenario run
