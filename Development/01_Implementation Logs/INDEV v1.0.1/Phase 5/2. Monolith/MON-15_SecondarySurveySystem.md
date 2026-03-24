# MON-15 — Secondary Survey Examination System

**Phase:** Phase 5 — ECG, GCS & Secondary Survey
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** MON-12 (examination_findings field)
**Blocks:** ARC-16

---

## Scope
Implement a body-region examination system for secondary survey (head-to-toe assessment). Each body region returns text-based clinical findings from the patient's scenario data. This adds a diagnostic puzzle where the player must systematically examine the patient to discover all injuries.

## Implementation Detail

### Body Regions
Define 7 examinable regions:
```gdscript
enum BodyRegion {
    HEAD,
    NECK,
    CHEST,
    ABDOMEN,
    PELVIS,
    BACK,
    EXTREMITIES,
}
```

### Secondary Survey Manager
Create `scripts/medical/secondary_survey_manager.gd`:
```gdscript
## SecondarySurveyManager — Body-region examination system.
extends Node

signal region_examined(patient: Node, region: String, findings: String)
signal survey_started(patient: Node)
signal survey_complete(patient: Node, all_findings: Dictionary)

## Track which regions have been examined per patient
var _examined_regions: Dictionary = {}  # { patient_name: [region_keys] }

func begin_survey(patient: Node) -> void:
    if not _examined_regions.has(patient.name):
        _examined_regions[patient.name] = []
    survey_started.emit(patient)

func examine_region(patient: Node, region: String) -> String:
    var medical_state := patient.get_node_or_null("MedicalStateComponent")
    if not medical_state:
        return "Unable to examine."

    var findings: Dictionary = medical_state.examination_findings
    var result: String = findings.get(region, "No abnormalities detected.")

    # Track examined regions
    if not _examined_regions.get(patient.name, []).has(region):
        _examined_regions[patient.name].append(region)

    region_examined.emit(patient, region, result)
    return result

func get_examined_regions(patient: Node) -> Array:
    return _examined_regions.get(patient.name, [])

func is_survey_complete(patient: Node) -> bool:
    return get_examined_regions(patient).size() >= BodyRegion.size()

func get_completion_percentage(patient: Node) -> float:
    return float(get_examined_regions(patient).size()) / float(BodyRegion.size()) * 100.0
```

### Examination Findings per Region
Each region returns findings based on the scenario JSON `examination_findings` dictionary. Examples of findings by region:

**Head:**
- "4cm laceration to left temporal region, actively bleeding. Pupils: left 6mm unreactive, right 3mm reactive."
- "No visible injuries. PERRL (pupils equal, round, reactive to light)."

**Neck:**
- "JVD present bilaterally. Trachea deviated to the right. Cervical tenderness at C5."
- "No JVD. Trachea midline. No crepitus or tenderness."

**Chest:**
- "Flail segment left lateral ribs 4-7. Paradoxical movement on inspiration. Diminished breath sounds left."
- "Equal bilateral breath sounds. No crepitus. Chest wall stable."

**Abdomen:**
- "Rigid, distended. Guarding in all quadrants. Possible internal hemorrhage."
- "Soft, non-tender. No distension."

**Pelvis:**
- "Unstable on gentle compression. Crepitus felt. Do NOT repeat pelvic exam."
- "Stable. No pain on compression."

**Back:**
- "Midline spinal tenderness at T12-L1. No step-off deformity."
- "No injuries. No spinal tenderness."

**Extremities:**
- "Left femur: angulated mid-shaft, shortening, external rotation. No distal pulse left foot. Right: normal, pulses present."
- "All extremities: normal alignment, full ROM, bilateral pulses present, sensation intact."

### Default Findings
If a scenario JSON doesn't include `examination_findings` for a region, return: "No abnormalities detected." This ensures backward compatibility.

### Telemetry Integration
Log each region examination to telemetry:
- Action: `"examine_region"`
- Data: `{ region: String, findings: String, examination_order: int }`
- Track examination order (which region the player checked first) for debrief analysis

### Assessment Manager Integration
Add `SECONDARY_SURVEY` to `AssessmentManager` as a meta-action that opens the secondary survey mode (ARC-16 handles the UI). Alternatively, secondary survey can be a separate interaction mode alongside primary assessment and history taking.

## Acceptance Criteria
- [x]`SecondarySurveyManager` created with region examination, tracking, and completion logic
- [x]7 body regions defined and examinable
- [x]Findings sourced from `examination_findings` dictionary on `MedicalStateComponent`
- [x]Examined regions tracked per patient (prevent duplicate examining UX but allow re-examination)
- [x]Survey completion percentage calculated
- [x]`region_examined` signal emitted with findings for UI display
- [x]Telemetry logging for each region examination
- [x]Default "No abnormalities" for missing region data (backward compatibility)
- [x]At least `scenario_rta.json` updated with examination findings for all 3 patients

## Boundaries — Do NOT Touch
- Do not create body-region UI (that's ARC-16)
- Do not modify primary survey assessment actions
- Do not modify `PatientPersona` (examination_findings lives on `MedicalStateComponent` via MON-12)

## Notes
- Clinical reference: Medica Consultation Log #01, Part 2E (Secondary Survey)
- Source: BUMED Fundamental Concepts — Secondary Survey; NASEMSO v2.2, General Trauma
- Secondary survey should only be available AFTER primary survey (ABCDE) is complete on the patient
- The examination order the player chooses is a training metric — head-to-toe is the correct systematic approach
