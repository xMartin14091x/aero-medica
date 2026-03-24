# MON-16 — Drug Administration System

**Phase:** Phase 6 — Drug Administration & Medical Bag Expansion
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** MON-11 (vital signs to respond to drug effects)
**Blocks:** ARC-17

---

## Scope
Implement the drug administration system — drug database, dose/route selection, drug effect application to `MedicalStateComponent`, and medication error tracking for debrief. This is the core backend for pharmacological treatment in AeroMedica.

## Implementation Detail

### Drug Database
Create `data/drugs.json`:
```json
{
    "drugs": {
        "epinephrine_cardiac": {
            "name": "Epinephrine (1:10,000)",
            "class": "Sympathomimetic",
            "tier": "ALS",
            "routes": ["IV", "IO"],
            "default_dose": "1 mg",
            "dose_options": ["0.5 mg", "1 mg"],
            "indication": "Cardiac arrest — all rhythms",
            "contraindications": [],
            "repeat_interval_sec": 180,
            "max_doses": 10,
            "effects": {
                "heart_rate": { "change": 20, "mode": "increase" },
                "blood_pressure_systolic": { "change": 15, "mode": "increase" }
            },
            "concentration_warning": "1:10,000 for IV — NOT 1:1,000"
        },
        "epinephrine_anaphylaxis": {
            "name": "Epinephrine (1:1,000)",
            "class": "Sympathomimetic",
            "tier": "BLS",
            "routes": ["IM"],
            "default_dose": "0.3 mg",
            "dose_options": ["0.15 mg", "0.3 mg"],
            "indication": "Anaphylaxis — first-line treatment",
            "contraindications": [],
            "repeat_interval_sec": 300,
            "max_doses": 3,
            "effects": {
                "heart_rate": { "change": 15, "mode": "increase" },
                "blood_pressure_systolic": { "change": 20, "mode": "increase" },
                "spo2": { "change": 3.0, "mode": "increase" }
            },
            "concentration_warning": "1:1,000 for IM — NOT 1:10,000"
        },
        "amiodarone": {
            "name": "Amiodarone",
            "class": "Antiarrhythmic",
            "tier": "ALS",
            "routes": ["IV"],
            "default_dose": "300 mg",
            "dose_options": ["150 mg", "300 mg"],
            "indication": "Refractory VF/pVT",
            "contraindications": [],
            "repeat_interval_sec": 0,
            "max_doses": 2,
            "effects": {
                "ecg_rhythm": { "value": "NORMAL_SINUS", "mode": "set", "probability": 0.4 }
            }
        },
        "atropine": {
            "name": "Atropine",
            "class": "Anticholinergic",
            "tier": "ALS",
            "routes": ["IV"],
            "default_dose": "0.5 mg",
            "dose_options": ["0.5 mg", "1 mg"],
            "indication": "Symptomatic bradycardia",
            "contraindications": [],
            "repeat_interval_sec": 180,
            "max_doses": 6,
            "effects": {
                "heart_rate": { "change": 20, "mode": "increase" }
            }
        },
        "naloxone_iv": {
            "name": "Naloxone (IV/IM)",
            "class": "Opioid Antagonist",
            "tier": "ALS",
            "routes": ["IV", "IM"],
            "default_dose": "0.4 mg",
            "dose_options": ["0.4 mg", "1 mg", "2 mg"],
            "indication": "Opioid overdose — respiratory depression",
            "contraindications": [],
            "repeat_interval_sec": 120,
            "max_doses": 5,
            "effects": {
                "breathing_rate": { "change": 6, "mode": "increase" },
                "spo2": { "change": 5.0, "mode": "increase" }
            },
            "clinical_note": "Titrate to respiratory effort, NOT full consciousness"
        },
        "naloxone_in": {
            "name": "Naloxone (Nasal)",
            "class": "Opioid Antagonist",
            "tier": "BLS",
            "routes": ["IN"],
            "default_dose": "4 mg",
            "dose_options": ["4 mg"],
            "indication": "Opioid overdose — respiratory depression",
            "contraindications": [],
            "repeat_interval_sec": 120,
            "max_doses": 3,
            "effects": {
                "breathing_rate": { "change": 4, "mode": "increase" },
                "spo2": { "change": 3.0, "mode": "increase" }
            }
        },
        "aspirin": {
            "name": "Aspirin (chewable)",
            "class": "Antiplatelet",
            "tier": "BLS",
            "routes": ["PO"],
            "default_dose": "324 mg",
            "dose_options": ["162 mg", "324 mg"],
            "indication": "Suspected ACS/MI — chest pain with cardiac history",
            "contraindications": ["aspirin_allergy", "active_bleeding"],
            "repeat_interval_sec": 0,
            "max_doses": 1,
            "effects": {}
        },
        "midazolam": {
            "name": "Midazolam",
            "class": "Benzodiazepine",
            "tier": "ALS",
            "routes": ["IV", "IM", "IN"],
            "default_dose": "5 mg",
            "dose_options": ["2 mg", "5 mg", "10 mg"],
            "indication": "Active seizure",
            "contraindications": [],
            "repeat_interval_sec": 300,
            "max_doses": 2,
            "effects": {},
            "clinical_note": ">2 doses = high risk of airway compromise"
        },
        "morphine": {
            "name": "Morphine",
            "class": "Opioid Analgesic",
            "tier": "ALS",
            "routes": ["IV", "IM"],
            "default_dose": "4 mg",
            "dose_options": ["2 mg", "4 mg", "10 mg"],
            "indication": "Moderate-severe pain",
            "contraindications": ["hypotension", "respiratory_depression"],
            "repeat_interval_sec": 300,
            "max_doses": 3,
            "effects": {
                "breathing_rate": { "change": -2, "mode": "increase" }
            },
            "clinical_note": "May cause hypotension and respiratory depression"
        },
        "oral_glucose": {
            "name": "Oral Glucose Gel",
            "class": "Dextrose",
            "tier": "BLS",
            "routes": ["PO"],
            "default_dose": "15 g",
            "dose_options": ["15 g"],
            "indication": "Hypoglycemia — conscious patient",
            "contraindications": ["unconscious", "unable_to_swallow"],
            "repeat_interval_sec": 600,
            "max_doses": 2,
            "effects": {
                "blood_glucose": { "change": 40, "mode": "increase" }
            }
        },
        "normal_saline": {
            "name": "Normal Saline (0.9% NaCl)",
            "class": "IV Fluid",
            "tier": "ALS",
            "routes": ["IV", "IO"],
            "default_dose": "500 mL",
            "dose_options": ["250 mL", "500 mL", "1000 mL"],
            "indication": "Fluid resuscitation — shock, dehydration",
            "contraindications": [],
            "repeat_interval_sec": 0,
            "max_doses": 6,
            "effects": {
                "blood_pressure_systolic": { "change": 10, "mode": "increase" },
                "heart_rate": { "change": -5, "mode": "increase" }
            },
            "clinical_note": "Preferred over LR for crush injury (no potassium)"
        },
        "lactated_ringers": {
            "name": "Lactated Ringer's",
            "class": "IV Fluid",
            "tier": "ALS",
            "routes": ["IV", "IO"],
            "default_dose": "500 mL",
            "dose_options": ["250 mL", "500 mL", "1000 mL"],
            "indication": "Trauma, burns — fluid resuscitation",
            "contraindications": ["crush_injury", "hyperkalemia"],
            "repeat_interval_sec": 0,
            "max_doses": 6,
            "effects": {
                "blood_pressure_systolic": { "change": 10, "mode": "increase" },
                "heart_rate": { "change": -5, "mode": "increase" }
            },
            "clinical_note": "AVOID in crush injury — contains potassium"
        }
    }
}
```

### Drug Administration Manager
Create `scripts/medical/drug_administration_manager.gd`:
```gdscript
## DrugAdministrationManager — Handles drug selection, validation, administration, and error tracking.
extends Node

signal drug_administered(patient: Node, drug_key: String, dose: String, route: String, effective: bool)
signal drug_error(patient: Node, drug_key: String, error_type: String, error_message: String)
signal drug_contraindicated(patient: Node, drug_key: String, reason: String)

var _drug_database: Dictionary = {}
var _administration_log: Array[Dictionary] = []  # Full session drug log for debrief

func _ready() -> void:
    _load_drug_database()

func administer_drug(patient: Node, drug_key: String, dose: String, route: String) -> Dictionary:
    # Validate drug exists
    # Check route is valid for this drug
    # Check contraindications against patient state
    # Check dose count (max_doses)
    # Check repeat interval
    # Apply effects to MedicalStateComponent
    # Log administration + any errors
    # Return result dictionary
    pass
```

### Drug Effect Application
When a drug is administered:
1. Read the `effects` dictionary from the drug definition
2. Apply each effect to `MedicalStateComponent`:
   - `"increase"` mode: add `change` value to current value (can be negative for decrease)
   - `"set"` mode: set field to `value` (with optional `probability`)
3. Effects apply over time (e.g., 30-second onset delay configurable per drug)
4. Track total doses administered per drug per patient

### Medication Error Types
Track these error categories for debrief scoring:
- `WRONG_DRUG` — Drug not indicated for patient's condition
- `WRONG_DOSE` — Dose outside therapeutic range
- `WRONG_ROUTE` — Route not valid for this drug
- `WRONG_CONCENTRATION` — e.g., 1:1,000 IV instead of 1:10,000
- `CONTRAINDICATED` — Drug given despite contraindication
- `EXCEEDED_MAX_DOSE` — Too many doses administered
- `TOO_SOON` — Given before repeat interval elapsed

### IV/IO Access Requirement
Drugs with routes ["IV", "IO"] require the player to have established vascular access first:
- Check if patient has `iv_access: true` or `io_access: true` on metadata
- If not: emit `drug_error` with message "IV/IO access required — start an IV first"
- BLS drugs (PO, IM, IN routes) do not require vascular access

### Telemetry Integration
Log all drug administrations to telemetry:
```gdscript
{
    "action": "drug_administered",
    "drug": drug_key,
    "dose": dose,
    "route": route,
    "timestamp": elapsed_time,
    "effective": was_effective,
    "errors": [error_list]
}
```

## Acceptance Criteria
- [x]`drugs.json` created with at least 12 drugs (5 BLS + 7 ALS) with full definitions
- [x]`DrugAdministrationManager` validates drug, dose, route, contraindications, and access requirements
- [x]Drug effects applied to `MedicalStateComponent` fields
- [x]Medication error tracking with 7 error categories
- [x]IV/IO access check before administering IV/IO drugs
- [x]Repeat interval and max dose enforcement
- [x]`drug_administered` and `drug_error` signals emitted for UI
- [x]Full administration log maintained for debrief
- [x]Epinephrine 1:1,000 vs 1:10,000 distinguished as separate drug entries
- [x]NS vs LR crush injury contraindication enforced
- [x]Telemetry logging for all drug events

## Boundaries — Do NOT Touch
- Do not create drug administration UI (that's ARC-17)
- Do not modify existing equipment system (MON-09)
- Do not modify `MedicalStateComponent` fields (that's MON-11)

## Notes
- Clinical reference: Medica Consultation Log #01, Part 4 (Medicines List)
- Source: BUMED Drugs; NASEMSO v2.2 multiple guidelines
- Medical fact: Epinephrine concentration confusion is a real clinical error — the game MUST distinguish 1:1,000 and 1:10,000
- Medical fact: Naloxone should be titrated to respiratory effort, NOT full consciousness
- Medical fact: LR contains potassium — contraindicated in crush injury/hyperkalemia
