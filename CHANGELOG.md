# AeroMedica — Changelog

## 25-03-2026 — Post-Clone Fixes (macOS Session)

### Parse Error Fix
- **SidewalkV2.tscn** (`scenes/environments/SidewalkV2.tscn`): Removed malformed UID `acg_ioqca357` from ext_resource line. Godot requires UIDs in `uid://` format; this non-standard prefix caused a scene parse error on project startup.
- **GrassV3.tscn** (`scenes/environments/GrassV3.tscn`): Removed malformed UID `acg_x2fpqmg8` from ext_resource line. Same root cause as above.

### DDx Label Mismatch Fix
- **scenario_building_fire.json**: `correct_diagnosis` value "Acute Respiratory Distress" changed to "Respiratory Failure" to match DDx button label.
- **scenario_fire.json**: "Second-Degree Burns" changed to "Burns (Thermal)"; "Crush Injury" changed to "Crush Injury / Rhabdomyolysis".
- **scenario_mci.json**: "Traumatic Cardiac Arrest" changed to "Cardiac Arrest"; "Hemorrhagic Shock" changed to "Haemorrhagic Shock" (British spelling to match UI).
- **scenario_rta.json**: "Blunt Thoracic Trauma" changed to "Trauma — Multi-system"; "Cervical Spine Injury" changed to "Spinal Injury"; "Hemorrhagic Shock" changed to "Haemorrhagic Shock".
- **Root cause**: Scenario authors used free-text diagnosis names instead of the exact 47 DDx button labels defined in `patient_interaction_ui.gd`. The scoring system requires character-for-character match.

### Notes
- Both scenes still reference `.tres` material files in `assets/` which are not in the Git repo. Godot will log warnings about missing resources but will load the scenes with default grey materials. Transfer the `assets/` folder from the Windows machine to restore textures.
