# MON-13 — ECG Rhythm System (Image-Based)

**Phase:** Phase 5 — ECG, GCS & Secondary Survey
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** MON-11 (ecg_rhythm field)
**Blocks:** ARC-14

---

## Scope
Implement the ECG rhythm recognition system with image-based rhythm strip display. The system must support swappable rhythm images — placeholder textures for now, real ECG strip images provided by Chief Manager later. Integrate with AED logic and deterioration system.

## Implementation Detail

### ECG Rhythm Definitions
Create `data/ecg_rhythms.json`:
```json
{
    "rhythms": {
        "NORMAL_SINUS": {
            "name": "Normal Sinus Rhythm",
            "rate_range": [60, 100],
            "regularity": "regular",
            "shockable": false,
            "image_path": "res://assets/textures/ecg/normal_sinus.png",
            "description": "Normal heart rhythm"
        },
        "SINUS_TACHYCARDIA": {
            "name": "Sinus Tachycardia",
            "rate_range": [101, 150],
            "regularity": "regular",
            "shockable": false,
            "image_path": "res://assets/textures/ecg/sinus_tachycardia.png",
            "description": "Fast but regular — treat underlying cause"
        },
        "SINUS_BRADYCARDIA": {
            "name": "Sinus Bradycardia",
            "rate_range": [30, 59],
            "regularity": "regular",
            "shockable": false,
            "image_path": "res://assets/textures/ecg/sinus_bradycardia.png",
            "description": "Slow but regular — may need atropine if symptomatic"
        },
        "ATRIAL_FIBRILLATION": {
            "name": "Atrial Fibrillation",
            "rate_range": [60, 180],
            "regularity": "irregularly_irregular",
            "shockable": false,
            "image_path": "res://assets/textures/ecg/atrial_fibrillation.png",
            "description": "Irregularly irregular — rate control needed"
        },
        "SVT": {
            "name": "Supraventricular Tachycardia",
            "rate_range": [150, 250],
            "regularity": "regular",
            "shockable": false,
            "image_path": "res://assets/textures/ecg/svt.png",
            "description": "Narrow complex, very fast — vagal maneuvers then adenosine"
        },
        "VENTRICULAR_TACHYCARDIA": {
            "name": "Ventricular Tachycardia",
            "rate_range": [100, 250],
            "regularity": "regular",
            "shockable": true,
            "image_path": "res://assets/textures/ecg/ventricular_tachycardia.png",
            "description": "Wide complex — amiodarone if stable, defib if pulseless"
        },
        "VENTRICULAR_FIBRILLATION": {
            "name": "Ventricular Fibrillation",
            "rate_range": [0, 0],
            "regularity": "chaotic",
            "shockable": true,
            "image_path": "res://assets/textures/ecg/ventricular_fibrillation.png",
            "description": "Cardiac arrest — SHOCKABLE — defibrillate immediately"
        },
        "ASYSTOLE": {
            "name": "Asystole",
            "rate_range": [0, 0],
            "regularity": "none",
            "shockable": false,
            "image_path": "res://assets/textures/ecg/asystole.png",
            "description": "Cardiac arrest — NOT shockable — CPR and epinephrine"
        },
        "PEA": {
            "name": "Pulseless Electrical Activity",
            "rate_range": [40, 100],
            "regularity": "regular",
            "shockable": false,
            "image_path": "res://assets/textures/ecg/pea.png",
            "description": "Organized rhythm but NO pulse — CPR + find reversible cause"
        }
    }
}
```

### Placeholder Images
Create `assets/textures/ecg/` directory with 9 placeholder PNG files (256×64 or similar strip aspect ratio). Each placeholder should be a simple colored rectangle with the rhythm name text overlaid:
- Use GDScript or a simple script to generate placeholder textures at startup if files don't exist
- OR create minimal placeholder PNGs (even solid colors with text) that will be replaced later
- **Key requirement:** The image path is configurable via JSON — swapping images later requires ONLY replacing the PNG files, no code changes

### ECG Rhythm Manager
Create `scripts/medical/ecg_rhythm_manager.gd`:
```gdscript
## Manages ECG rhythm data and image loading.
extends Node

var _rhythm_data: Dictionary = {}

func _ready() -> void:
    _load_rhythm_definitions()

func _load_rhythm_definitions() -> void:
    var file := FileAccess.open("res://data/ecg_rhythms.json", FileAccess.READ)
    if file:
        var json := JSON.new()
        if json.parse(file.get_as_text()) == OK:
            _rhythm_data = json.data.get("rhythms", {})
        file.close()

func get_rhythm_info(rhythm_key: String) -> Dictionary:
    return _rhythm_data.get(rhythm_key, {})

func get_rhythm_image(rhythm_key: String) -> Texture2D:
    var info := get_rhythm_info(rhythm_key)
    var path: String = info.get("image_path", "")
    if path.is_empty() or not ResourceLoader.exists(path):
        return null
    return load(path) as Texture2D

func is_shockable(rhythm_key: String) -> bool:
    return get_rhythm_info(rhythm_key).get("shockable", false)

func get_rhythm_name(rhythm_key: String) -> String:
    return get_rhythm_info(rhythm_key).get("name", "Unknown Rhythm")
```

### AED Integration
Update AED equipment logic:
- When AED is attached, it reads `ecg_rhythm` from `MedicalStateComponent`
- AED automatically determines shockable vs. non-shockable using `is_shockable()`
- AED announces: "Shock advised" (VF/VT) or "No shock advised" (asystole/PEA/others)
- Player does NOT need to identify rhythm when using AED — the device does it
- AED displays the rhythm image strip after analysis

### Cardiac Monitor (ALS)
Add `CARDIAC_MONITOR` equipment type:
- When attached, continuously displays the rhythm image strip
- Player must MANUALLY identify the rhythm from a list (ARC-14 handles this UI)
- No auto-analysis — this tests the player's knowledge
- Monitor also shows HR readout from the image

### Deterioration Integration
ECG rhythm should change with deterioration:
- Normal → Sinus Tachycardia (early shock)
- Sinus Tachycardia → VT (worsening)
- VT → VF (cardiac arrest)
- VF → Asystole (prolonged arrest without treatment)
- Successful CPR+AED: VF → Normal Sinus (ROSC)

Add rhythm transition logic to `deterioration_system.gd`.

## Acceptance Criteria
- [x]`ecg_rhythms.json` created with all 9 rhythms, each with `image_path` field
- [x]`assets/textures/ecg/` directory created with 9 placeholder PNG files
- [x]`ECGRhythmManager` loads rhythm data and images from JSON paths
- [x]Images are swappable by replacing PNG files only — no code changes needed
- [x]AED reads rhythm and announces shockable/non-shockable automatically
- [x]`CARDIAC_MONITOR` equipment type added (manual rhythm identification for ALS)
- [x]Deterioration system transitions between rhythms over time
- [x]`get_rhythm_image()` returns loaded `Texture2D` from the configured path
- [x]Rhythm transitions are clinically logical (see deterioration chain above)

## Boundaries — Do NOT Touch
- Do not modify `MedicalStateComponent.ecg_rhythm` field definition (that's MON-11)
- Do not create the ECG overlay UI (that's ARC-14)
- Do not modify existing AED equipment scene structure — extend it

## Notes
- Clinical reference: Medica Consultation Log #01, Part 2C (ECG / Cardiac Monitoring)
- Chief Manager will provide real ECG strip images later — placeholder system must support drop-in replacement
- Medical fact: AED analyzes rhythm automatically — player should NOT interpret VF vs. asystole through AED
- Medical fact: PEA shows organized rhythm but NO pulse — the key distinction is checking pulse, not reading the strip
- Image aspect ratio recommendation: 4:1 (e.g., 512×128 or 1024×256) to mimic real rhythm strip paper
