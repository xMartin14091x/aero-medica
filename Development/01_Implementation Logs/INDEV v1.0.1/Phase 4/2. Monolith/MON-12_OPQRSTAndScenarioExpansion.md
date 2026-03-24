# MON-12 — OPQRST History & Scenario Data Expansion

**Phase:** Phase 4 — OPQRST & Vital Signs
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** ARC-12

---

## Scope
Add OPQRST pain assessment framework to the history-taking system. Expand `PatientPersona` with OPQRST response fields, add OPQRST questions to `history_questions.json`, update `ScenarioManager` to parse OPQRST data, and add OPQRST responses to all existing scenario JSONs.

## Implementation Detail

### history_questions.json — Add OPQRST Category
Add new `opqrst` category:
```json
"opqrst": [
    {"key": "onset", "label": "What were you doing when it started?"},
    {"key": "provocation", "label": "Does anything make it worse or better?"},
    {"key": "quality", "label": "Can you describe the pain? Sharp? Dull? Crushing?"},
    {"key": "radiation", "label": "Does the pain spread anywhere else?"},
    {"key": "severity", "label": "On a scale of 0 to 10, how bad is the pain?"},
    {"key": "time_course", "label": "Is it constant or does it come and go?"}
]
```

### PatientPersona — New OPQRST Fields
Add exported Dictionary:
```gdscript
@export var history_opqrst: Dictionary = {}
```

Update `get_history_response()` to handle `"opqrst"` category:
```gdscript
"opqrst":
    return history_opqrst.get(question_key, "")
```

### OPQRST Consciousness Gating
OPQRST requires the same consciousness gating as SAMPLE — only available for ALERT and VERBAL patients. The existing `can_respond()` check in `HistoryTakingManager.ask_question()` already handles this. No additional gating needed.

### Scenario JSON — OPQRST Data
Add `opqrst` block inside each patient's `history`:
```json
"history": {
    "symptoms": { ... },
    "allergies": { ... },
    "medications": { ... },
    "past_history": { ... },
    "last_meal": { ... },
    "events": { ... },
    "opqrst": {
        "onset": "I was at my desk working... suddenly felt this tightness...",
        "provocation": "It's worse when I try to breathe deeply...",
        "quality": "It's like a heavy weight... crushing...",
        "radiation": "It goes down my left arm... and up to my jaw...",
        "severity": "9... it's the worst pain I've ever felt...",
        "time_course": "Constant... hasn't let up since it started..."
    }
}
```

### Scenario Updates Required
Update ALL existing scenario files with OPQRST data:

1. **scenario_cardiac.json** — Wichai (unresponsive): OPQRST via coworker/unavailable
2. **scenario_rta.json** — Somchai (alert, pain 6): full OPQRST with rib/breathing pain; Nanthida (verbal, pain 8): partial OPQRST with neck/chest; Prasert (unresponsive): unavailable
3. **scenario_building_fire.json** — Add appropriate OPQRST
4. **scenario_mci.json** — Add per-patient OPQRST based on consciousness
5. **scenario_tutorial.json** — Add teaching-appropriate OPQRST

### ScenarioManager — Parse OPQRST
Update history parsing to include `opqrst` key alongside existing SAMPLE categories.

### Examination Findings Data Structure (for Phase 5)
Add `examination_findings` dictionary to scenario JSON schema for secondary survey use. Each body region has a findings string:
```json
"examination_findings": {
    "head": "4cm laceration to left temporal region, actively bleeding. Left ear: blood in canal.",
    "neck": "No JVD. Trachea midline. No crepitus. Cervical tenderness at C5-C6.",
    "chest": "Bilateral breath sounds present but diminished on left. No crepitus. No flail.",
    "abdomen": "Soft, non-tender. No distension. No guarding.",
    "pelvis": "Stable on compression. No crepitus.",
    "back": "No visible injuries. No spinal tenderness.",
    "extremities_upper": "No deformity. Bilateral radial pulses present. Full motor and sensation.",
    "extremities_lower": "Left femur angulated mid-shaft, crepitus on palpation. No distal pulse left foot. Right leg normal."
}
```

Store as `@export var examination_findings: Dictionary = {}` on `MedicalStateComponent`.

## Acceptance Criteria
- [x]`history_questions.json` has 7 categories (6 SAMPLE + 1 OPQRST)
- [x]`PatientPersona` has `history_opqrst` field with `get_history_response()` support
- [x]All existing scenario JSONs updated with OPQRST data (conscious patients get responses, unresponsive get "(Patient is unresponsive)" or bystander info)
- [x]`ScenarioManager` parses `opqrst` and `examination_findings` from JSON
- [x]`examination_findings` dictionary field added to `MedicalStateComponent`
- [x]At least `scenario_cardiac.json` and `scenario_rta.json` have clinically accurate OPQRST responses
- [x]OPQRST responses are character-consistent with existing SAMPLE responses per patient
- [x]Existing SAMPLE functionality unchanged

## Boundaries — Do NOT Touch
- Do not modify `HistoryTakingManager` logic (it already handles arbitrary categories)
- Do not create UI elements (that's ARC-12)
- Do not modify vital sign fields (that's MON-11)

## Notes
- Clinical reference: Medica Consultation Log #01, Part 2A (OPQRST Pain Assessment)
- OPQRST sourced from BUMED Fundamental Concepts
- Key clinical detail: "crushing" chest pain radiating to jaw/arm suggests cardiac origin — Wichai's OPQRST (if reconstructed from coworker) should hint at this
- OPQRST quality descriptors have diagnostic significance: sharp=pleuritic/fracture, crushing=cardiac, burning=chemical/burn, colicky=abdominal
