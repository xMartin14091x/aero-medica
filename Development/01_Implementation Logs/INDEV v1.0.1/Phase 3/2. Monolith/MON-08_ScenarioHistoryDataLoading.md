# MON-08 — Scenario History Data Loading Fix

**Phase:** Phase 3 — AI Dialogue & Gameplay Systems
**Team:** Monolith — Core Systems
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** None

---

## Scope
Fix the scenario loading pipeline to map SAMPLE history data from scenario JSON into PatientPersona resources. The JSON had full history data but ScenarioManager never loaded it into the persona's history_* dictionaries.

## Root Cause
`scenario_manager.gd` line 119-128 created PatientPersona from JSON but only mapped identity fields (name, age, consciousness_level, etc.). The `"history"` section was completely ignored.

## Fix Applied
Added history data mapping in `scenario_manager.gd` after persona identity setup:
```gdscript
var history_data: Dictionary = patient_def.get("history", {})
if not history_data.is_empty():
    persona.history_symptoms = history_data.get("symptoms", {})
    persona.history_allergies = history_data.get("allergies", {})
    persona.history_medications = history_data.get("medications", {})
    persona.history_past = history_data.get("past_history", {})
    persona.history_last_meal = history_data.get("last_meal", {})
    persona.history_events = history_data.get("events", {})
```

## Acceptance Criteria
- [x] Scenario JSON history data loads into PatientPersona at runtime
- [x] SAMPLE questions return actual responses instead of "..."
- [x] Tutorial patient "Somchai" responds with scripted history when asked

## Files Modified
- `scripts/core/scenario_manager.gd` — Added history mapping (lines 129-136)
