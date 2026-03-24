# MON-11 — Vital Signs Data Model Expansion

**Phase:** Phase 4 — OPQRST & Vital Signs
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** None (prior phases provide foundation)
**Blocks:** ARC-13, MON-13, MON-14, MON-15

---

## Scope
Expand `MedicalStateComponent` with comprehensive vital sign fields and add corresponding assessment actions to `AssessmentManager`. This is the data foundation that all Phase 5 and 6 features build on. Also expand scenario JSON schema with vital sign initial values.

## Implementation Detail

### MedicalStateComponent — New Exported Fields
```gdscript
## Vital Signs
@export_range(0, 250) var heart_rate: int = 80
@export var blood_pressure_systolic: int = 120
@export var blood_pressure_diastolic: int = 80
@export_range(0.0, 100.0) var spo2: float = 98.0
@export_range(25.0, 45.0) var temperature: float = 37.0  # Celsius
@export_range(0, 600) var blood_glucose: int = 100  # mg/dL
@export_range(0.0, 10.0) var capillary_refill: float = 1.5  # seconds

## Pupil Assessment
@export_range(1, 9) var pupil_left_size: int = 4  # mm
@export_range(1, 9) var pupil_right_size: int = 4  # mm
@export var pupil_left_reactive: bool = true
@export var pupil_right_reactive: bool = true

## GCS Components (used by MON-14)
@export_range(1, 4) var gcs_eye: int = 4
@export_range(1, 5) var gcs_verbal: int = 5
@export_range(1, 6) var gcs_motor: int = 6

## ECG Rhythm (used by MON-13)
@export var ecg_rhythm: String = "NORMAL_SINUS"

## Skin Assessment
@export_enum("NORMAL", "PALE", "FLUSHED", "CYANOTIC", "MOTTLED", "JAUNDICED") var skin_color: String = "NORMAL"
@export_enum("WARM", "COOL", "HOT", "COLD") var skin_temperature: String = "WARM"
@export_enum("DRY", "MOIST", "DIAPHORETIC") var skin_moisture: String = "DRY"
```

### AssessmentManager — New Assessment Actions
Add to `AssessmentAction` enum:
- `CHECK_HEART_RATE` — returns `{ heart_rate: int, regular: bool }`
- `CHECK_BLOOD_PRESSURE` — returns `{ systolic: int, diastolic: int }` — **equipment-gated: BP cuff**
- `CHECK_SPO2` — returns `{ spo2: float }` — **equipment-gated: pulse oximeter**
- `CHECK_PUPILS` — returns `{ left_size: int, left_reactive: bool, right_size: int, right_reactive: bool, equal: bool }` — **equipment-gated: penlight**
- `CHECK_TEMPERATURE` — returns `{ temperature: float, unit: "C" }` — **equipment-gated: thermometer**
- `CHECK_BLOOD_GLUCOSE` — returns `{ glucose: int }` — **equipment-gated: glucometer**
- `CHECK_CAPILLARY_REFILL` — returns `{ refill_seconds: float, normal: bool }`
- `CHECK_SKIN` — returns `{ color: String, temperature: String, moisture: String }`

### Equipment Gating
Add `perform_assessment()` check: if action requires equipment, verify player has it (check `InventoryComponent` or medical bag). If not, return `{ error: "Requires [equipment name]" }` and emit a signal for UI to display.

### Scenario JSON — New Fields
Add `vitals` block to each patient in scenario JSONs:
```json
"vitals": {
    "heart_rate": 110,
    "blood_pressure_systolic": 85,
    "blood_pressure_diastolic": 55,
    "spo2": 92.0,
    "temperature": 36.8,
    "blood_glucose": 95,
    "capillary_refill": 3.0,
    "pupil_left_size": 4,
    "pupil_right_size": 4,
    "pupil_left_reactive": true,
    "pupil_right_reactive": true,
    "skin_color": "PALE",
    "skin_temperature": "COOL",
    "skin_moisture": "DIAPHORETIC",
    "ecg_rhythm": "SINUS_TACHYCARDIA",
    "gcs_eye": 4,
    "gcs_verbal": 5,
    "gcs_motor": 6
}
```

Update `ScenarioManager` to parse `vitals` block and apply to `MedicalStateComponent`.

### Normal Ranges Constant
Add a `VITAL_RANGES` constant for UI color-coding:
```gdscript
const VITAL_RANGES := {
    "heart_rate": { "low": 60, "high": 100, "critical_low": 40, "critical_high": 150 },
    "blood_pressure_systolic": { "low": 90, "high": 140, "critical_low": 70, "critical_high": 180 },
    "spo2": { "low": 94.0, "high": 100.0, "critical_low": 90.0 },
    "temperature": { "low": 36.0, "high": 37.5, "critical_low": 35.0, "critical_high": 40.0 },
    "blood_glucose": { "low": 60, "high": 140, "critical_low": 40, "critical_high": 300 },
    "capillary_refill": { "high": 2.0, "critical_high": 4.0 },
}
```

### Deterioration Integration
Update `deterioration_system.gd` to also deteriorate vital signs over time:
- Bleeding → HR increases, BP decreases, SpO2 decreases
- Airway obstruction → SpO2 drops, RR changes
- Cardiac arrest → all vitals zero/absent
- Add configurable deterioration rates per vital sign in scenario JSON

## Acceptance Criteria
- [x]All new fields added to `MedicalStateComponent` with appropriate export ranges
- [x]All 8 new `AssessmentAction` entries added with correct return dictionaries
- [x]Equipment-gating logic implemented for BP, SpO2, temperature, blood glucose, and pupils
- [x]Scenario JSON schema documented with `vitals` block
- [x]At least `scenario_cardiac.json` and `scenario_rta.json` updated with clinically accurate vital sign data
- [x]`VITAL_RANGES` constant available for UI color-coding
- [x]`ScenarioManager` parses `vitals` block and applies to `MedicalStateComponent`
- [x]Deterioration system updates vital signs over time
- [x]All new fields included in `get_state_summary()` return dictionary
- [x]Existing functionality (5 original assessment actions) unchanged

## Boundaries — Do NOT Touch
- Do not modify existing assessment return formats for CHECK_AIRWAY, CHECK_BREATHING, CHECK_PULSE, CHECK_CONSCIOUSNESS, CHECK_BLEEDING
- Do not modify PatientPersona (that's MON-12)
- Do not create UI elements (that's ARC-13)

## Notes
- Clinical reference: Medica Consultation Log #01, Part 2B (Vital Signs Assessment)
- Normal adult ranges sourced from BUMED Fundamental Concepts and NASEMSO v2.2 Universal Patient Care
- SpO2 must be flagged as INACCURATE in CO poisoning scenarios (add `co_exposure: bool` field if needed)
