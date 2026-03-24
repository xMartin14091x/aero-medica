# AeroMedica — Handover Notes

**Date:** 24-03-2026
**From:** RoundTable Team (Overseer)
**Project:** AeroMedica — Emergency Medical Training Simulation (Godot 4.6)

---

## Setup on macOS

1. Download **Godot 4.6** (must match Windows version exactly)
2. Copy the entire `AeroMedica/` folder via AnyDesk or file transfer
3. Open `Projects/aero-medica/project.godot` in Godot
4. Godot will re-import all assets automatically (textures, scenes) — first open takes ~30 seconds
5. Press F5 to run

---

## Project Structure

| Path | Purpose |
|------|---------|
| `Projects/aero-medica/` | Godot project root |
| `data/scenarios/` | JSON scenario definitions (patients, hazards, equipment) |
| `scripts/` | All GDScript source (71 files) |
| `scenes/gameplay/` | Hand-crafted V2 level scenes (USE THESE) |
| `scenes/environments/` | Legacy procedural scenes (DO NOT USE) |
| `assets/textures/ecg/` | ECG rhythm strip images (7 files, just placed) |
| `Development/` | Planning docs, tickets, test cases |
| `Development/09_TestCase/QA_PatientCheatSheet.md` | Full patient cheat sheet with triage answers |

---

## Key Systems — Do Not Break

### Patient Spawning
ScenarioManager reads positions from JSON files in `data/scenarios/`. If you move PatientSpawn markers in the Godot editor, you must ALSO update the JSON coordinates — JSON is the source of truth, not the markers. Markers are visual guides only.

### Mouse Mode Chain
`Input.mouse_mode` controls both player movement lock and camera scroll lock:
- `MOUSE_MODE_CAPTURED` = gameplay (player can move, camera can zoom)
- `MOUSE_MODE_VISIBLE` = UI open (player frozen, camera locked)
- HUDController sets CAPTURED on scene load (`_ready`)
- PatientInteractionUI sets VISIBLE on open, CAPTURED on close
- Do NOT change mouse mode without understanding this chain

### PatientInteractionUI Visibility Order
`_assessment_manager.begin_assessment()` must be called AFTER `visible = true` in `open_ui()`. Reversing this order brings back the ActionMenu artifact bug (BUG-GC-02).

### Diagnosis Persistence
Diagnosis results are stored on patient node metadata (`set_meta`). They reset if you re-instance the patient node. The UI checks `_diagnosis_submitted` flag which resets per `open_ui()` call, but the metadata on the patient node persists across UI open/close cycles.

### Hazard System
- Fire hazards damage entities inside and track player exposure time
- 15 seconds in fire = EMT incapacitated, scenario ends
- Player presence boosts patient damage by 25% (scene safety penalty)
- `hazard_system.gd` tracks total player hazard time for AI reviewer

### Time Scaling
- Timer runs at 0.3x when player is walking around (idle)
- Timer runs at 1.0x when PatientInteractionUI is open (interacting)
- Minimum time = max(scenario_time, patient_count * 180 seconds)
- Tutorial (time_limit = 0) is always unlimited

---

## AI Features (Optional — Require Ollama)

Both AI systems auto-discover Ollama on localhost, 127.0.0.1, and LAN IPs (port 11434).

- **Patient Dialogue:** Ollama generates in-character patient responses grounded to SAMPLE history data. Falls back to scripted responses if offline.
- **AI Reviewer:** Ollama generates post-scenario performance review from telemetry data. Falls back to cached demo reviews if offline.
- **Config:** `user_data/ai_config.json` — model, timeout, max tokens
- **HTTP 500 from Ollama** = GPU busy (e.g., training another model). Expected, fallback handles it.

---

## ECG Strips

7 rhythm images in `assets/textures/ecg/`. Loaded by `ecg_rhythm_manager.gd` using the filename as key:
- `NORMAL_SINUS.png`
- `SINUS_TACHYCARDIA.png`
- `SINUS_BRADYCARDIA.png`
- `VENTRICULAR_FIBRILLATION.png`
- `VENTRICULAR_TACHYCARDIA.png`
- `ASYSTOLE.png`
- `PULSELESS_ELECTRICAL_ACTIVITY.png`

Clinical note (Medica verified): PEA cannot be diagnosed from ECG alone — the game requires pulse check first.

---

## Triage Algorithm

Located in `scripts/medical/medical_state_component.gd:get_triage_priority()`. Evaluation order:
1. DEAD → BLACK
2. CARDIAC_ARREST → RED
3. No pulse → RED
4. Breathing < 8 → RED
5. Airway "OBSTRUCTED" (exact string) → RED
6. Bleeding >= 2 → RED
7. UNCONSCIOUS → RED
8. BP < 70 or HR > 150 or SpO2 < 90 → RED
9. Breathing < 12 or > 30 → YELLOW
10. Mild bleeding + (BP < 100 or HR > 110 or SpO2 < 95) → YELLOW
11. BP < 90 or HR < 60 or HR > 100 or SpO2 < 94 → YELLOW
12. Otherwise → GREEN

Note: "COMPROMISED" airway does NOT match "OBSTRUCTED" — only exact string "OBSTRUCTED" triggers RED.

---

## Remaining Work

### Code-Side (Done)
All gameplay code, AI integration, hazard system, time scaling, triage, diagnosis, and telemetry are complete.

### Needs Godot Editor Work
- **ARC-26:** Visual polish pass — scene decoration (buildings, barriers, props)
- **v1.0.1 Phase 2:** Model importation (patient models, equipment visuals) — deferred unless time permits

### Final Step
- **OVR-03:** Competition build export — use Godot Export menu for target platform

---

## Scenarios Quick Reference

| Scenario | Patients | Time | Key Challenge |
|----------|----------|------|--------------|
| Tutorial | 1 (Somchai) | Unlimited | Basic assessment, GREEN triage |
| Building Fire (1p) | 1 (Anong) | 9 min | Smoke inhalation, RED |
| Cardiac Arrest (Workplace) | 1 (Wichai) | 8 min | VFib, CPR + AED |
| Cardiac Arrest (Park) | 1 (Prasert) | 8 min | VFib + obstructed airway |
| Building Fire (3p) | 3 + 1 random | 12 min | Multi-patient, triage, CO exposure |
| Mass Casualty (MCI) | 6 + 1 random | 20 min | START triage, blast injuries |
| Road Traffic Accident | 3 | 15 min | Multi-trauma, fire hazard |

Full patient data: `Development/09_TestCase/QA_PatientCheatSheet.md`

---

*Written by KP (Overseer) — 24-03-2026*
