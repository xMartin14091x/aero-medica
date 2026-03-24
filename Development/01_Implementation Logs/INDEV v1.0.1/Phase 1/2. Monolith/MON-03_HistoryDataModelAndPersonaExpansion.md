# MON-03 — History Data Model & PatientPersona Expansion

**Phase:** Phase 1 — Patient History Taking
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** MON-04

---

## Scope

Expand the `PatientPersona` resource to include structured SAMPLE history data (Symptoms, Allergies, Medications, Past history, Last meal, Events) with pre-written patient responses. Create the data model that `HistoryTakingManager` will query.

## Implementation

### 1. Expand PatientPersona Resource

Add SAMPLE history data to `scripts/medical/patient_persona.gd`:

```gdscript
## SAMPLE History — pre-written responses per category
## Each category maps to a dictionary of { question_key: response_text }
@export var history_symptoms: Dictionary = {}
@export var history_allergies: Dictionary = {}
@export var history_medications: Dictionary = {}
@export var history_past: Dictionary = {}
@export var history_last_meal: Dictionary = {}
@export var history_events: Dictionary = {}

## Response modifiers based on patient state
## consciousness_level affects whether patient can respond at all
## pain_level affects response tone (higher pain = shorter, more distressed)
## panic_level affects coherence (higher panic = fragmented responses)
## language_clarity affects response clarity (0.0 = incoherent, 1.0 = clear)

func get_history_response(category: String, question_key: String) -> String:
    var data: Dictionary
    match category:
        "symptoms": data = history_symptoms
        "allergies": data = history_allergies
        "medications": data = history_medications
        "past_history": data = history_past
        "last_meal": data = history_last_meal
        "events": data = history_events
        _: return ""
    return data.get(question_key, "")

func can_respond() -> bool:
    return consciousness_level in ["ALERT", "VERBAL"]
```

### 2. Create History Question Definitions

Create `data/history_questions.json`:

```json
{
  "symptoms": [
    {"key": "what_happened", "label": "What happened?"},
    {"key": "where_hurts", "label": "Where does it hurt?"},
    {"key": "when_started", "label": "When did it start?"},
    {"key": "pain_scale", "label": "How bad is the pain (1-10)?"}
  ],
  "allergies": [
    {"key": "any_allergies", "label": "Do you have any allergies?"},
    {"key": "medication_allergies", "label": "Allergic to any medications?"}
  ],
  "medications": [
    {"key": "current_meds", "label": "Are you taking any medications?"},
    {"key": "what_meds", "label": "What medications do you take?"}
  ],
  "past_history": [
    {"key": "medical_conditions", "label": "Any medical conditions?"},
    {"key": "surgeries", "label": "Have you had surgery before?"}
  ],
  "last_meal": [
    {"key": "when_ate", "label": "When did you last eat or drink?"},
    {"key": "what_ate", "label": "What did you have?"}
  ],
  "events": [
    {"key": "what_doing", "label": "What were you doing?"},
    {"key": "witnesses", "label": "Did anyone see what happened?"}
  ]
}
```

### 3. Update Scenario JSONs

Add `history` block to each patient definition in scenario JSON files. Example for tutorial patient:

```json
"history": {
  "symptoms": {
    "what_happened": "I was crossing the road and a car hit me...",
    "where_hurts": "My left leg... it hurts so much...",
    "when_started": "Just now, maybe 5 minutes ago...",
    "pain_scale": "It's... maybe an 8? It's really bad..."
  },
  "allergies": {
    "any_allergies": "No, I don't have any allergies.",
    "medication_allergies": "No, none that I know of."
  }
}
```

## Files to Create

- `data/history_questions.json`

## Files to Modify

- `scripts/medical/patient_persona.gd` — Add SAMPLE fields and `get_history_response()`
- `scripts/core/scenario_manager.gd` — Parse `history` block from scenario JSON and populate PatientPersona
- All 5 scenario JSONs — Add `history` data for each patient definition

## Acceptance Criteria

- [x] PatientPersona has exported SAMPLE dictionary fields
- [x] `get_history_response(category, question_key)` returns correct responses
- [x] `can_respond()` returns false for unconscious/pain-responsive patients
- [x] `data/history_questions.json` contains all SAMPLE categories with questions
- [x] At least the tutorial scenario JSON has full history data for all patients
- [x] ScenarioManager populates history data when spawning patients

## Boundaries — Do NOT Touch

- Do NOT modify the assessment system (AssessmentManager)
- Do NOT modify MedicalStateComponent
- Do NOT create UI elements (that's ARC-02/03/04)
