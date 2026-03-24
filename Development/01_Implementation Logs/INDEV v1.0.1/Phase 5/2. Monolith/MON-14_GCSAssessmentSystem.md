# MON-14 — GCS Assessment System

**Phase:** Phase 5 — ECG, GCS & Secondary Survey
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** MON-11 (gcs_eye, gcs_verbal, gcs_motor fields)
**Blocks:** ARC-15

---

## Scope
Implement Glasgow Coma Scale (GCS) as a detailed 3-component neurological assessment system. GCS complements the existing AVPU quick-check with a 3-15 numeric score. Include automatic clinical threshold warnings.

## Implementation Detail

### GCS Data Model
Create `data/gcs_definitions.json`:
```json
{
    "eye_opening": {
        "4": {"label": "Spontaneous", "description": "Eyes open without stimulation"},
        "3": {"label": "To Voice", "description": "Eyes open when spoken to"},
        "2": {"label": "To Pain", "description": "Eyes open only to painful stimulus"},
        "1": {"label": "None", "description": "No eye opening"}
    },
    "verbal_response": {
        "5": {"label": "Oriented", "description": "Knows who, where, when"},
        "4": {"label": "Confused", "description": "Speaks but disoriented"},
        "3": {"label": "Inappropriate Words", "description": "Random or exclamatory words"},
        "2": {"label": "Incomprehensible", "description": "Moaning, groaning only"},
        "1": {"label": "None", "description": "No verbal response"}
    },
    "motor_response": {
        "6": {"label": "Obeys Commands", "description": "Performs requested movements"},
        "5": {"label": "Localizes Pain", "description": "Reaches toward and pushes away pain source"},
        "4": {"label": "Withdrawal", "description": "Pulls away from painful stimulus"},
        "3": {"label": "Abnormal Flexion", "description": "Decorticate posturing — arms flex, legs extend"},
        "2": {"label": "Extension", "description": "Decerebrate posturing — all limbs extend"},
        "1": {"label": "None", "description": "No motor response"}
    }
}
```

### GCS Assessment Flow
Create `scripts/medical/gcs_assessment.gd`:
```gdscript
## GCSAssessment — 3-component neurological scoring system.
extends Node

signal gcs_component_assessed(component: String, score: int, label: String)
signal gcs_complete(total: int, severity: String)

const SEVERITY_THRESHOLDS := {
    "MILD": 13,      # 13-15
    "MODERATE": 9,    # 9-12
    "SEVERE": 3,      # 3-8
}

## Returns GCS total from MedicalStateComponent
func get_gcs_total(medical_state: Node) -> int:
    return medical_state.gcs_eye + medical_state.gcs_verbal + medical_state.gcs_motor

## Returns severity string
func get_severity(total: int) -> String:
    if total >= 13: return "MILD"
    if total >= 9: return "MODERATE"
    return "SEVERE"

## Returns true if GCS indicates need for airway protection
func needs_airway_protection(total: int) -> bool:
    return total <= 8
```

### Clinical Threshold Alerts
When GCS is assessed and total ≤ 8:
- Emit a special signal: `gcs_airway_warning(total: int)`
- UI should display a prominent warning: "GCS ≤8 — AIRWAY PROTECTION NEEDED"
- This is a non-negotiable medical threshold (Source: BUMED/NASEMSO)

### GCS-AVPU Mapping
Provide a utility function for cross-reference:
```gdscript
func gcs_to_avpu(total: int) -> String:
    if total >= 13: return "ALERT"
    if total >= 9: return "VERBAL"
    if total >= 4: return "PAIN"
    return "UNRESPONSIVE"
```

### Deterioration Integration
GCS should change with patient deterioration:
- Worsening head injury: Eye → decreases, Verbal → decreases, Motor → decreases
- Intoxication: Verbal drops first
- Cardiac arrest: All components → 1 (total = 3)
- Post-ROSC: May partially recover

### Assessment Action Integration
Add `CHECK_GCS` to `AssessmentManager`:
- Unlike other single-value checks, GCS is a 3-step assessment
- Player assesses Eye, Verbal, Motor separately (or as a single action that returns all 3)
- Returns: `{ eye: int, verbal: int, motor: int, total: int, severity: String, needs_airway: bool }`

## Acceptance Criteria
- [x]`gcs_definitions.json` created with all 3 components and descriptive labels
- [x]`GCSAssessment` node created with scoring, severity, and threshold logic
- [x]`CHECK_GCS` assessment action added to `AssessmentManager`
- [x]GCS assessment returns all 3 components + total + severity + airway warning
- [x]GCS ≤8 triggers `gcs_airway_warning` signal
- [x]`gcs_to_avpu()` utility function available for cross-reference
- [x]Deterioration system updates GCS components over time
- [x]Severity classification: Mild (13-15), Moderate (9-12), Severe (3-8)

## Boundaries — Do NOT Touch
- Do not modify existing AVPU logic in `AssessmentManager.CHECK_CONSCIOUSNESS` — GCS is an additional option, not a replacement
- Do not create UI (that's ARC-15)

## Notes
- Clinical reference: Medica Consultation Log #01, Part 2D (GCS Scoring)
- Source: BUMED Fundamental Concepts — GCS section; NASEMSO v2.2, Head Injury guideline
- Medical fact: GCS ≤8 = airway protection needed — this is a hard clinical threshold
- GCS is preferred for trending — serial GCS scores track neurological improvement/deterioration
