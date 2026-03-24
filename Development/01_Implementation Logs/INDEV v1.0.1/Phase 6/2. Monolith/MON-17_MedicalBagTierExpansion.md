# MON-17 — Medical Bag Tier System Expansion

**Phase:** Phase 6 — Drug Administration & Medical Bag Expansion
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** MON-09 (existing medical bag system), MON-11 (equipment-gated assessments), MON-16 (drug administration)
**Blocks:** ARC-18

---

## Scope
Expand the existing medical bag system (MON-09) with a tiered BLS/ALS equipment structure. BLS bag available in all scenarios; ALS bag unlocked for advanced scenarios. Equipment-gate assessment actions to require the correct tool from the bag. Add diagnostic/assessment tools (BP cuff, pulse oximeter, etc.) alongside existing treatment items.

## Implementation Detail

### Bag Tier Definitions
Create `data/medical_bag_tiers.json`:
```json
{
    "BLS": {
        "name": "BLS Medical Bag",
        "description": "Basic Life Support equipment — standard first-response kit",
        "items": [
            {"item_key": "gloves", "name": "Nitrile Gloves", "quantity": 10, "category": "ppe"},
            {"item_key": "pocket_mask", "name": "Pocket Mask", "quantity": 1, "category": "airway"},
            {"item_key": "bvm_adult", "name": "BVM (Adult)", "quantity": 1, "category": "airway"},
            {"item_key": "opa_set", "name": "OPA Set (sizes 0-5)", "quantity": 1, "category": "airway"},
            {"item_key": "npa_set", "name": "NPA Set (sizes 24-32 Fr)", "quantity": 1, "category": "airway"},
            {"item_key": "oxygen_cylinder", "name": "Portable O2 Cylinder", "quantity": 1, "category": "breathing"},
            {"item_key": "nrb_mask", "name": "Non-Rebreather Mask", "quantity": 2, "category": "breathing"},
            {"item_key": "nasal_cannula", "name": "Nasal Cannula", "quantity": 2, "category": "breathing"},
            {"item_key": "pulse_oximeter", "name": "Pulse Oximeter", "quantity": 1, "category": "diagnostic"},
            {"item_key": "bp_cuff", "name": "BP Cuff (Manual)", "quantity": 1, "category": "diagnostic"},
            {"item_key": "stethoscope", "name": "Stethoscope", "quantity": 1, "category": "diagnostic"},
            {"item_key": "penlight", "name": "Penlight", "quantity": 1, "category": "diagnostic"},
            {"item_key": "thermometer", "name": "Thermometer", "quantity": 1, "category": "diagnostic"},
            {"item_key": "glucometer", "name": "Glucometer + Strips", "quantity": 1, "category": "diagnostic"},
            {"item_key": "bandage_roll", "name": "Bandage Roll", "quantity": 6, "category": "wound_care"},
            {"item_key": "gauze_pad", "name": "Gauze Pads (4x4)", "quantity": 20, "category": "wound_care"},
            {"item_key": "triangular_bandage", "name": "Triangular Bandage", "quantity": 4, "category": "wound_care"},
            {"item_key": "trauma_shears", "name": "Trauma Shears", "quantity": 1, "category": "tools"},
            {"item_key": "adhesive_tape", "name": "Adhesive Tape", "quantity": 2, "category": "wound_care"},
            {"item_key": "sam_splint", "name": "SAM Splint", "quantity": 2, "category": "immobilization"},
            {"item_key": "cervical_collar", "name": "Cervical Collar (Adjustable)", "quantity": 1, "category": "immobilization"},
            {"item_key": "tourniquet", "name": "CAT Tourniquet", "quantity": 2, "category": "hemorrhage"},
            {"item_key": "emergency_blanket", "name": "Emergency Blanket", "quantity": 2, "category": "thermal"}
        ]
    },
    "ALS": {
        "name": "ALS Medical Bag",
        "description": "Advanced Life Support additions — requires ALS certification context",
        "includes_bls": true,
        "additional_items": [
            {"item_key": "cardiac_monitor", "name": "Cardiac Monitor / Lifepak", "quantity": 1, "category": "diagnostic"},
            {"item_key": "ecg_cables", "name": "12-Lead ECG Cables", "quantity": 1, "category": "diagnostic"},
            {"item_key": "capnography", "name": "Capnography (ETCO2)", "quantity": 1, "category": "diagnostic"},
            {"item_key": "iv_start_kit", "name": "IV Start Kit (14-24ga)", "quantity": 5, "category": "vascular"},
            {"item_key": "io_drill", "name": "IO Drill (EZ-IO)", "quantity": 1, "category": "vascular"},
            {"item_key": "iv_tubing", "name": "IV Tubing + Admin Set", "quantity": 3, "category": "vascular"},
            {"item_key": "sga", "name": "Supraglottic Airway (King/iGel)", "quantity": 1, "category": "airway"},
            {"item_key": "et_tube_set", "name": "ET Tubes (5.5-8.0)", "quantity": 1, "category": "airway"},
            {"item_key": "laryngoscope", "name": "Laryngoscope (Blade Set)", "quantity": 1, "category": "airway"},
            {"item_key": "needle_decomp_kit", "name": "Needle Decompression Kit (14ga)", "quantity": 2, "category": "chest"},
            {"item_key": "chest_seal", "name": "Chest Seal (Vented, HyFin)", "quantity": 2, "category": "chest"},
            {"item_key": "hemostatic_gauze", "name": "Hemostatic Gauze (QuikClot)", "quantity": 4, "category": "hemorrhage"},
            {"item_key": "israeli_bandage", "name": "Israeli Bandage", "quantity": 2, "category": "hemorrhage"},
            {"item_key": "suction_unit", "name": "Portable Suction Unit", "quantity": 1, "category": "airway"},
            {"item_key": "cric_kit", "name": "Cricothyroidotomy Kit", "quantity": 1, "category": "airway"},
            {"item_key": "pelvic_binder", "name": "Pelvic Binder", "quantity": 1, "category": "immobilization"},
            {"item_key": "ng_tube", "name": "Nasogastric Tube", "quantity": 1, "category": "gastric"}
        ]
    }
}
```

### Equipment-Gating Integration
Wire the bag items to assessment actions from MON-11:
```gdscript
const EQUIPMENT_REQUIREMENTS := {
    "CHECK_BLOOD_PRESSURE": "bp_cuff",
    "CHECK_SPO2": "pulse_oximeter",
    "CHECK_PUPILS": "penlight",
    "CHECK_TEMPERATURE": "thermometer",
    "CHECK_BLOOD_GLUCOSE": "glucometer",
    "CHECK_ECG": "cardiac_monitor",
    "CHECK_ETCO2": "capnography",
}
```

When `perform_assessment()` is called for an equipment-gated action:
1. Check if the player has opened the medical bag
2. Check if the required item exists in the bag inventory
3. If available: allow assessment, consume if single-use or mark as deployed
4. If unavailable: return error with equipment name for UI display

### Scenario Bag Assignment
Add `medical_bag_tier` field to scenario JSON:
```json
{
    "scenario_id": "...",
    "medical_bag_tier": "BLS",
    ...
}
```

`ScenarioManager` loads the appropriate bag contents based on this field. Tutorial and early scenarios use BLS; advanced scenarios use ALS.

### Bag Interaction
The medical bag should be:
- A scene-placed entity (like existing equipment) OR
- Auto-available in the player's inventory at scenario start
- Player opens bag → sees categorized contents → selects item to deploy
- Deployed diagnostic tools stay on the patient (e.g., cardiac monitor stays attached)
- Consumable items (bandages, gauze) decrease in quantity when used

### Drug Bag Integration
ALS bag should also contain the drug inventory from MON-16. When player opens the drug section of the bag:
- Show available drugs filtered by tier (BLS shows only BLS drugs, ALS shows all)
- Drug administration requires IV/IO access for IV drugs (MON-16 handles validation)

## Acceptance Criteria
- [x]`medical_bag_tiers.json` created with BLS (23 items) and ALS (17 additional) definitions
- [x]Bag tier loaded from scenario JSON `medical_bag_tier` field
- [x]ALS bag includes all BLS items plus ALS additions
- [x]Equipment-gated assessments check bag inventory for required tools
- [x]Consumable items track quantity (decrease on use)
- [x]Diagnostic tools mark as "deployed" when used on a patient
- [x]Drug inventory integrated with bag (filtered by tier)
- [x]Bag contents categorized (PPE, airway, breathing, diagnostic, wound care, etc.)
- [x]Existing MON-09 bag system extended, not replaced

## Boundaries — Do NOT Touch
- Do not create bag UI (that's ARC-18)
- Do not modify drug administration logic (that's MON-16)
- Do not modify assessment manager directly — use the equipment check hook from MON-11

## Notes
- Clinical reference: Medica Consultation Log #01, Part 3 (Medical Bag Equipment List)
- Source: BUMED Equipment; BUMED Procedures
- The tier system mirrors real EMS training progression — BLS first, ALS unlocked for advanced play
