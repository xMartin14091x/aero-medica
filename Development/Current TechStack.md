# AeroMedica — Current TechStack

**Project:** AeroMedica
**Last Updated:** 29-03-2026 (v1.0.0 Phase 0-8 complete, v1.0.1 Phase 0-6 complete, UI revamp v2.0 applied)

---

## Phase 0 — Foundation & Architecture (COMPLETE)

All 6 MON tickets implemented. Project root: `Projects/aero-medica/`

## Phase 1 — Core Gameplay Loop (COMPLETE)

MON-07 to MON-09 (entities + scenario), SYN-01 to SYN-03 (interaction + assessment), ARC-01 to ARC-03 (UI + RTA level).

## Phase 2 — Medical Protocol & Time Pressure (COMPLETE)

MON-10 to MON-11 (medical state machine + deterioration), SYN-04 to SYN-06 (protocols + triage + timer), ARC-04 to ARC-06 (triage tag visuals, patient status visuals, scenario timer HUD).

## Phase 3 — Telemetry & AI Review Pipeline (COMPLETE)

MON-12 to MON-13 (telemetry wiring + position tracking), SYN-07 to SYN-10 (protocol adherence, error detection, Ollama review, response parser), ARC-07 to ARC-08 (AI review display panel, scenario debrief screen).

## Phase 4 — Dynamic Environment & Scene Variation (COMPLETE)

MON-14 (Environmental Hazard System — HazardSystem + HazardZone), MON-15 (Random Event System — RandomEventSystem), SYN-11 (Scene Variation Engine — SceneVariation), SYN-12 (Physics Interaction System — PhysicsInteractable), ARC-09 (Hazard Visual Effects), ARC-10 (Environmental Audio Cues).

## Post-Phase Systems (21-03 to 29-03-2026)

### Bug Fixes & Polish (22 bugs fixed)
- ActionMenu artifact, movement lock, camera scroll, vital signs display, triage algorithm, DDx label mismatches, signal disconnect crashes, scenario load guards, post-incapacitation cleanup, ECG rhythm auto-update, deterioration budget scaling, patient name in reviewer, diagnosis persistence, cooldown red flash

### New Systems Added
- **Deterioration Budget** — Two-phase per-patient timer (Phase 1: 300s pre-arrest, Phase 2: 120s post-arrest). Scales by patient count. Focused interaction drains faster (3.33x/2.0x).
- **CPR + AED + ROSC** — CPR gated behind pulse assessment. AED auto-checks shockable rhythm. ROSC triggers sinus brady. Atropine auto-updates rhythm based on HR.
- **Hazard System** — Fire/traffic zones. Player incapacitation at 15s. 25% patient deterioration boost near hazards. AI reviewer feedback on hazard exposure.
- **Action Cooldown System** — Per-group delays (DRS 0.5s, ABCDE 2s, Vitals 1.5s, Equipment 3s, Drug 5s) with circular arc progress overlay and concurrent limits.
- **AI Demo Fallback** — 70 cached review files (35 EN + 35 TH) across 7 scenarios x 5 tiers. Locale-aware loading. Triggers on Ollama timeout (15s).
- **Bilingual System** — 300+ translation keys (TH/EN). examination_findings_th per patient. All UI labels use tr(). Instant locale switch.
- **Sub-Tab UI** — Exam: 4 sub-tabs (Primary/Vitals/GCS/Head-to-Toe). Stabilize: 3 sub-tabs (Equipment/Drug Admin/Triage).
- **3-Tab Dashboard** — My Performance (personal radar + history), Class Overview (class stats + radar + student table), Scenario Breakdown (per-scenario filter).
- **Severity Markers** — 3-tier system for head-to-toe findings: ⚠ RED (life-threatening), ⚡ YELLOW (significant), no marker GREEN (normal).
- **Markdown→BBCode Renderer** — Converts #/##/### headers, **bold**, - bullets to BBCode for RichTextLabel display.
- **Drug Admin State Context** — Telemetry logs patient state + rhythm at time of drug administration.
- **Post-Treatment Slowdown** — Each effective treatment reduces deterioration_rate by 20% (stacks, floor 0.1x).

### Autoloads (13 total)
GameManager, LocalisationManager, TelemetryCollector, ScenarioManager, OllamaReviewClient, OllamaDialogueClient, ECGRhythmManager, GCSAssessmentManager, SecondarySurveyManager, TriageSystem, ThemeMedical, AIDemoFallback, HistoryManager

---

## Classes & Scripts

### GameManager (`scripts/core/game_manager.gd`)
**Extends:** Node | **Autoload Singleton**
Central coordinator for game state and scene transitions.

| Type | Name | Details |
|------|------|---------|
| Enum | `GameState` | `MENU`, `PLAYING`, `PAUSED`, `DEBRIEF` |
| Signal | `state_changed` | `(old_state: GameState, new_state: GameState)` |
| Method | `change_state(new_state: GameState)` | Transitions game state, emits `state_changed` |
| Method | `change_scene(scene_path: String)` | Deferred scene change by path |

---

### IsometricCamera (`scripts/core/isometric_camera.gd`)
**Extends:** Camera3D
Orthographic camera at true isometric angle (~35.264° pitch, 45° yaw) with smooth follow and zoom.

| Type | Name | Details |
|------|------|---------|
| Export | `target: Node3D` | Node to follow |
| Export | `follow_speed: float = 5.0` | Camera lerp speed |
| Export | `offset: Vector3 = Vector3(10, 10, 10)` | Offset from target |
| Export | `zoom_min: float = 5.0` | Min orthographic size |
| Export | `zoom_max: float = 20.0` | Max orthographic size |
| Export | `zoom_step: float = 1.0` | Zoom per scroll tick |
| Method | `_ready()` | Sets orthographic projection + isometric angle |
| Method | `_process(delta)` | Smooth follow toward target + offset |
| Method | `_unhandled_input(event)` | Mouse scroll wheel zoom |

---

### PlayerController (`scripts/gameplay/player_controller.gd`)
**Extends:** CharacterBody3D
EMT player character with 8-directional isometric movement.

| Type | Name | Details |
|------|------|---------|
| Constant | `ISO_ROTATION := -PI / 4.0` | -45° rotation to align WASD input with isometric camera |
| Export | `move_speed: float = 5.0` | Movement speed (units/sec) |
| Export | `interaction_radius: float = 2.0` | Area3D detection radius |
| Method | `_ready()` | Adds to "player" group for UI lookup |
| Method | `_physics_process(_delta)` | Reads WASD input, rotates by ISO_ROTATION, applies `move_and_slide()` |

---

### InteractableComponent (`scripts/gameplay/interactable_component.gd`)
**Extends:** Node
Attach as child to any interactable entity. Defines the interaction interface.

| Type | Name | Details |
|------|------|---------|
| Signal | `interacted` | `(interactor: Node)` — emitted when player triggers interaction |
| Export | `interaction_label: String = "Interact"` | UI prompt text (e.g., "Check Pulse") |
| Export | `dialogue_capable: bool = false` | F12 hook — supports Ollama live dialogue |
| Method | `can_interact() -> bool` | Returns true if interaction available (override for conditional) |

---

### TestLevel (`scripts/gameplay/test_level.gd`)
**Extends:** Node3D
Generates the 10x10 tile grid for Phase 0 testing.

| Type | Name | Details |
|------|------|---------|
| Constant | `TILE_SIZE := 2.0` | Tile size in world units |
| Constant | `GRID_WIDTH := 10` | Grid width |
| Constant | `GRID_HEIGHT := 10` | Grid height |
| Method | `_ready()` | Generates grid, bakes NavMesh, wires camera to player |
| Method | `_generate_grid()` | Creates 10x10 mixed layout (grass border, sidewalk ring, road centre) |
| Method | `_pick_tile(x, z) -> PackedScene` | Returns tile scene based on grid position |

---

### PatientPersona (`scripts/medical/patient_persona.gd`)
**Extends:** Resource | **Class Name:** `PatientPersona`
Defines a patient's identity, medical state, and LLM persona for F12 dialogue.

| Type | Name | Details |
|------|------|---------|
| Export | `patient_name: String = "Unknown Patient"` | Patient identity |
| Export | `age: int = 30` | Patient age |
| Export | `consciousness_level: String = "ALERT"` | AVPU scale: ALERT, VERBAL, PAIN, UNRESPONSIVE |
| Export | `pain_level: int = 0` | Pain scale 0–10 |
| Export | `panic_level: float = 0.0` | Panic 0.0–1.0 |
| Export | `language_clarity: float = 1.0` | Speech coherence 0.0–1.0 |
| Method | `get_persona_prompt() -> String` | Returns formatted LLM prompt string (F12 skeleton) |

---

### TelemetryEmitter (`scripts/telemetry/telemetry_emitter.gd`)
**Extends:** Node
Attach as child to player. Emits structured action events for the telemetry pipeline.

| Type | Name | Details |
|------|------|---------|
| Signal | `action_performed` | `(action_data: Dictionary)` — format: `{type, target, timestamp, details}` |
| Signal | `dialogue_event` | `(question: String, response: String, duration: float)` — F12 hook |
| Method | `emit_action(action_type, target, details={})` | Builds and emits structured action event |

---

### TelemetryCollector (`scripts/telemetry/telemetry_collector.gd`)
**Extends:** Node | **Autoload Singleton**
Receives and stores all gameplay telemetry. Central data pipeline.

| Type | Name | Details |
|------|------|---------|
| Var | `session_events: Array[Dictionary]` | All recorded action events this session |
| Method | `start_session(scenario_id: String)` | Begin session — clears data, starts timer |
| Method | `record_event(action_data: Dictionary)` | Record an action event from TelemetryEmitter |
| Method | `end_session() -> Dictionary` | Returns `{scenario_id, duration_seconds, event_count, events}` |
| Method | `export_session_json(path: String)` | Write session data to JSON file |

---

### PositionTracker (`scripts/telemetry/position_tracker.gd`)
**Extends:** Node
Attached to Player. Records position samples at 1s intervals and tracks time near patients.

| Type | Name | Details |
|------|------|---------|
| Export | `tracking_interval: float = 1.0` | Sampling interval in seconds |
| Method | `get_heatmap_data()` | Returns position + timestamp samples for heatmap |
| Method | `get_patient_proximity_times()` | Returns time spent near each patient |

---

### PatientEntity (`scripts/medical/patient_entity.gd`)
**Extends:** CharacterBody3D
Root script for PatientBase scene. Holds persona and provides component accessors.

| Type | Name | Details |
|------|------|---------|
| Export | `persona: PatientPersona` | Patient persona resource (set per-instance) |
| Var | `medical_state: Node` | `@onready $MedicalStateComponent` |
| Var | `interactable: Node` | `@onready $InteractableComponent` |
| Var | `triage_tag: MeshInstance3D` | `@onready $TriageTagVisual` |

---

### MedicalStateComponent (`scripts/medical/medical_state_component.gd`)
**Extends:** Node
Patient medical condition tracker with state machine and treatment system.

| Type | Name | Details |
|------|------|---------|
| Enum | `PatientState` | `CONSCIOUS`, `UNCONSCIOUS`, `CARDIAC_ARREST`, `DEAD` |
| Signal | `state_changed` | `(old_state, new_state)` |
| Signal | `modifier_changed` | Emitted when any medical modifier changes |
| Export | `current_state: PatientState` | Current medical state |
| Export | `bleeding_severity: int` | 0–3 severity |
| Export | `airway_status: String` | "CLEAR" or "OBSTRUCTED" |
| Export | `breathing_rate: float` | Breaths per minute |
| Export | `pulse_present: bool` | Whether pulse is detectable |
| Method | `set_state(new_state)` | Transition with signal emission |
| Method | `get_state_summary() -> Dictionary` | Medical state for telemetry/AI |
| Method | `apply_treatment(treatment_type) -> bool` | 13 treatment types, returns success |
| Method | `get_triage_priority() -> String` | START algorithm → RED/YELLOW/GREEN/BLACK |

---

### DeteriorationSystem (`scripts/medical/deterioration_system.gd`)
**Extends:** Node
Time-based patient condition worsening across 4 tracks.

| Type | Name | Details |
|------|------|---------|
| Signal | `condition_worsened` | Emitted when a track triggers |
| Method | Track: bleeding | Configurable rate, pauses during treatment |
| Method | Track: airway | Configurable rate, pauses during treatment |
| Method | Track: unconscious | Configurable rate, pauses during treatment |
| Method | Track: cardiac arrest | Configurable rate, pauses during treatment |

---

### EquipmentData (`scripts/gameplay/equipment_data.gd`)
**Extends:** Resource
Equipment type definition with 5-type enum.

| Type | Name | Details |
|------|------|---------|
| Enum | Type | `AED`, `BANDAGE`, `SPLINT`, `OXYGEN_MASK`, `STRETCHER` |
| Export | `equipment_name: String` | Display name |
| Export | `use_label: String` | Use action label |

---

### EquipmentEntity (`scripts/gameplay/equipment_entity.gd`)
**Extends:** CharacterBody3D
Root script for equipment scenes.

| Type | Name | Details |
|------|------|---------|
| Export | `data: EquipmentData` | Equipment type and config |

---

### ScenarioManager (`scripts/core/scenario_manager.gd`)
**Extends:** Node | **Autoload Singleton**
Loads scenario JSON, spawns entities, manages lifecycle (timer, telemetry).

| Type | Name | Details |
|------|------|---------|
| Signal | `scenario_loaded` | `(scenario_data: Dictionary)` |
| Signal | `scenario_started` | Emitted when gameplay begins |
| Signal | `scenario_ended` | `(results: Dictionary)` |
| Method | `load_scenario(path: String)` | Parse JSON, spawn patients/equipment |
| Method | `start_scenario()` | Begin timer + telemetry session |
| Method | `end_scenario()` | Stop timer, gather results |
| Method | `cleanup()` | Remove all spawned entities |

---

### InteractionManager (`scripts/gameplay/interaction_manager.gd`)
**Extends:** Node
Attached to Player. Detects nearby InteractableComponent nodes and handles E-key routing.

| Type | Name | Details |
|------|------|---------|
| Signal | `interaction_target_changed` | `(old_target: Node, new_target: Node)` |
| Var | `current_target: Node` | Nearest interactable entity |
| Method | `_interact_with_target()` | Routes: equipment→pickup, patient+empty→assess, patient+holding→use |
| Method | `_update_nearest_target()` | Recalculates nearest from in-range entities |

---

### InventoryComponent (`scripts/gameplay/inventory_component.gd`)
**Extends:** Node
Attached to Player. Single-item equipment inventory with pickup/carry/use/drop.

| Type | Name | Details |
|------|------|---------|
| Signal | `item_picked_up` | Equipment pickup event |
| Signal | `item_used` | Equipment use on patient event |
| Signal | `item_dropped` | Equipment drop event |
| Method | `try_pickup(equipment_node)` | Reparent to HeldItemMount |
| Method | `use_on_target(target)` | Use held item on patient |
| Method | `is_holding() -> bool` | Whether holding equipment |

---

### AssessmentManager (`scripts/gameplay/assessment_manager.gd`)
**Extends:** Node
Attached to Player. Manages patient assessment flow (5 ABCDE actions).

| Type | Name | Details |
|------|------|---------|
| Enum | `AssessmentAction` | `CHECK_AIRWAY`, `CHECK_BREATHING`, `CHECK_PULSE`, `CHECK_CONSCIOUSNESS`, `CHECK_BLEEDING` |
| Signal | `assessment_started` | `(patient: Node)` |
| Signal | `assessment_ended` | `(patient: Node)` |
| Signal | `assessment_performed` | `(patient, action_type, result)` |
| Var | `in_assessment: bool` | Whether in assessment mode |
| Method | `begin_assessment(patient)` | Enter assessment mode |
| Method | `end_assessment()` | Exit assessment mode |
| Method | `perform_assessment(action) -> Dictionary` | Read medical state for action |
| Method | `perform_assessment_by_name(name) -> Dictionary` | Label string → enum → perform |

---

### ProtocolValidator (`scripts/medical/protocol_validator.gd`)
**Extends:** Node
Validates player action sequences against gold-standard BLS/ALS protocols.

| Type | Name | Details |
|------|------|---------|
| Method | `validate_sequence() -> Dictionary` | Returns adherence_percentage, correct/missed/wrong_order |

---

### TriageSystem (`scripts/medical/triage_system.gd`)
**Extends:** Node
Manages triage tag assignments with stealth assessment (incorrect tags allowed but logged).

| Type | Name | Details |
|------|------|---------|
| Enum | `TriageTag` | `GREEN`, `YELLOW`, `RED`, `BLACK` |
| Signal | `triage_assigned` | `(patient, assigned_tag, correct_tag, is_correct)` |
| Method | `assign_tag(patient, tag)` | Validate against START algorithm |
| Method | `get_correct_tag(patient) -> TriageTag` | Delegate to MedicalStateComponent |
| Method | `get_triage_summary() -> Dictionary` | Accuracy stats for debrief |

---

### TimePressureSystem (`scripts/gameplay/time_pressure_system.gd`)
**Extends:** Node
Scenario countdown timer with escalating deterioration multiplier.

| Type | Name | Details |
|------|------|---------|
| Signal | `time_updated` | `(remaining: float)` — every second |
| Signal | `time_warning` | `(remaining: float)` — at 75/50/25% thresholds |
| Signal | `time_expired` | Timer reached zero |
| Export | `time_limit_seconds: float` | Configurable time limit |
| Method | `start_timer()` | Begin countdown |

---

### RTALevel (`scripts/gameplay/rta_level.gd`)
**Extends:** Node3D
Road Traffic Accident scenario level — 16x16 intersection with vehicles and spawn points.

| Type | Name | Details |
|------|------|---------|
| Constant | `TILE_SIZE := 2.0` | Tile size in world units |
| Constant | `GRID_WIDTH := 16` | Grid width |
| Constant | `GRID_HEIGHT := 16` | Grid height |
| Constant | `ROAD_HALF_WIDTH := 2` | Half-width of road bands |
| Method | `_ready()` | Generates grid, places vehicles/spawns, bakes NavMesh, wires camera |
| Method | `_generate_grid()` | Cross-shaped intersection layout |
| Method | `_pick_tile(x, z) -> PackedScene` | Road (center bands), sidewalk (adjacent), grass (outer) |
| Method | `_place_vehicles()` | 3 placeholder vehicle boxes at intersection |
| Method | `_create_vehicle_box(pos, size, angle, color)` | Creates StaticBody3D vehicle prop |
| Method | `_place_spawn_markers()` | 3 patient + 3 equipment Marker3D spawn points |

---

### InteractionPrompt (`scripts/ui/interaction_prompt.gd`)
**Extends:** Control
Floating "[E] {label}" prompt above interactable objects with fade transitions.

| Type | Name | Details |
|------|------|---------|
| Constant | `FADE_DURATION := 0.15` | Fade in/out duration in seconds |
| Constant | `SCREEN_OFFSET_Y := -60.0` | Vertical screen offset (pixels) |
| Method | `on_target_changed(target: Node3D)` | Called by HUDController when nearest target changes |
| Method | `_set_target(target, label)` | Show prompt with fade-in |
| Method | `_clear_target()` | Hide prompt with fade-out |

---

### ActionMenu (`scripts/ui/action_menu.gd`)
**Extends:** Control
Contextual assessment menu near patient. 5 ABCDE actions, keyboard (1-5) + mouse.

| Type | Name | Details |
|------|------|---------|
| Signal | `action_selected` | `(action_name: String)` — routed to AssessmentManager via HUDController |
| Constant | `CLOSE_DISTANCE := 3.5` | Auto-close distance threshold |
| Constant | `ACTIONS` | Array of 5 action label strings |
| Method | `open_menu(patient: Node)` | Show menu for patient |
| Method | `close_menu()` | Hide menu, clear target |
| Method | `_select_action(index: int)` | Emit selected action, close menu |

---

### ProtocolAdherenceTracker (`scripts/telemetry/protocol_adherence_tracker.gd`)
**Extends:** Node
Post-scenario analysis of session telemetry against gold-standard protocols.

| Type | Name | Details |
|------|------|---------|
| Method | `analyse_session(session_data) -> Dictionary` | Groups events by patient, validates sequences, returns per-patient + overall adherence |
| Output | Per-patient report | `adherence_percentage`, `correct/missed/wrong_order` steps, timing metrics |
| Output | Timing metrics | `time_to_first_assessment`, `time_to_first_treatment`, `time_to_first_triage` |
| Output | Prioritisation | Checks if critical patients treated first |

---

### ErrorDetector (`scripts/telemetry/error_detector.gd`)
**Extends:** Node
Detects and categorises player mistakes from session telemetry + protocol analysis.

| Type | Name | Details |
|------|------|---------|
| Enum | ErrorType | `WRONG_TRIAGE`, `SKIPPED_ASSESSMENT`, `WRONG_PRIORITY`, `WRONG_EQUIPMENT`, `PROTOCOL_VIOLATION`, `DELAYED_ACTION` |
| Enum | Severity | `CRITICAL`, `MAJOR`, `MINOR` |
| Method | `detect_errors(session_data, protocol_analysis) -> Array[Dictionary]` | Returns errors sorted by severity |
| Output | Error dict | `{type, severity, patient_id, description, timestamp, details}` |

---

### OllamaReviewClient (`scripts/ai/reviewer/ollama_review_client.gd`)
**Extends:** Node
HTTPRequest-based Ollama API client for AI performance review.

| Type | Name | Details |
|------|------|---------|
| Signal | `review_received` | `(review_text: String)` |
| Signal | `review_failed` | `(error: String)` |
| Method | `request_review(session_data, protocol_analysis, errors, answer_sheet)` | Async HTTP to localhost:11434 |
| Method | `check_ollama_available() -> bool` | Connectivity check |
| Config | `user_data/ai_config.json` | Model (default: llama3.1:8b), timeout, max_tokens |

---

### ReviewParser (`scripts/ai/claude/review_parser.gd`)
**Extends:** Node
Parses AI review response text into structured Dictionary.

| Type | Name | Details |
|------|------|---------|
| Signal | `review_parsed` | `(review_data: Dictionary)` |
| Method | `parse_review(response_text) -> Dictionary` | Returns 5 sections + raw_text |
| Output | Sections | `overall_assessment`, `strengths`, `improvements`, `critical_errors`, `recommendations` |
| Fallback | | Returns `{raw_text}` if parsing fails |

---

### HazardSystem (`scripts/gameplay/hazard_system.gd`)
**Extends:** Node
Manages all environmental hazards in a scenario. Spawns HazardZone nodes from scenario JSON `hazards[]` definitions.

| Type | Name | Details |
|------|------|---------|
| Signal | `hazard_activated` | `(hazard_zone: Node)` — hazard zone becomes active |
| Signal | `hazard_expanded` | `(hazard_zone: Node)` — fire hazard radius grew |
| Signal | `entity_in_hazard` | `(entity: Node3D, hazard_type: String)` — entity entered hazard |
| Signal | `entity_left_hazard` | `(entity: Node3D, hazard_type: String)` — entity exited hazard |
| Method | `spawn_hazards(hazard_defs, scene_root)` | Creates and places all hazard zones from scenario data |
| Method | `get_active_hazards() -> Array[Node]` | Returns all currently active zones |
| Method | `get_hazard_at_position(pos) -> String` | Returns hazard type name at world position, or "" |
| Method | `activate_hazard(index)` | Activate a delayed hazard by index |
| Method | `deactivate_hazard(index)` | Deactivate a hazard by index |
| Method | `cleanup()` | Remove all hazard zones |

---

### HazardZone (`scripts/gameplay/hazard_zone.gd`)
**Extends:** Area3D
Individual hazard area. FIRE spreads + damages, COLLAPSE blocks, TRAFFIC cycles safe/danger windows.

| Type | Name | Details |
|------|------|---------|
| Enum | `HazardType` | `FIRE`, `COLLAPSE`, `TRAFFIC` |
| Signal | `entity_entered` | `(entity: Node3D, hazard: Area3D)` |
| Signal | `entity_exited` | `(entity: Node3D, hazard: Area3D)` |
| Signal | `hazard_expanded` | `(new_radius: float)` — fire spread |
| Export | `hazard_type: HazardType` | Type determines behaviour |
| Export | `radius: float = 3.0` | Current zone radius |
| Export | `spread_rate: float = 0.0` | Fire spread per second (0 = static) |
| Export | `max_radius: float = 15.0` | Maximum spread radius |
| Export | `damage_per_second: float = 10.0` | Damage to entities inside |
| Export | `is_active: bool = true` | Whether zone is active |
| Export | `traffic_interval: float = 10.0` | Seconds between TRAFFIC danger windows |
| Export | `traffic_danger_duration: float = 3.0` | TRAFFIC danger window length |
| Method | `activate()` | Activate this zone |
| Method | `deactivate()` | Deactivate this zone |
| Method | `is_position_inside(pos) -> bool` | Distance check against radius |
| Method | `is_traffic_danger_active() -> bool` | Whether TRAFFIC is in danger window |

---

### RandomEventSystem (`scripts/gameplay/random_event_system.gd`)
**Extends:** Node
Mid-scenario random events. Triggers at randomised times from scenario JSON `random_events[]`.

| Type | Name | Details |
|------|------|---------|
| Signal | `random_event_triggered` | `(event_type: String, event_data: Dictionary)` |
| Method | `setup(event_defs, scene_root)` | Initialize with event definitions, resolve random trigger times |
| Method | `start()` | Begin processing events |
| Method | `stop()` | Stop processing events |
| Event | `NEW_PATIENT` | Spawns patient mid-scenario with full medical state + persona + deterioration |
| Event | `EQUIPMENT_FAILURE` | Marks equipment as broken via metadata flag, disables interactable |
| Event | `BYSTANDER` | Spawns dialogue-capable NPC (CharacterBody3D, blue capsule) |

---

### SceneVariation (`scripts/gameplay/scene_variation.gd`)
**Extends:** Node
Pre-processes scenario data for replayability. Seed-based randomisation of positions, conditions, hazards, event times. Difficulty scaling presets.

| Type | Name | Details |
|------|------|---------|
| Constant | `DIFFICULTY_EASY/NORMAL/HARD` | Difficulty preset keys |
| Constant | `DIFFICULTY_MODIFIERS` | Per-preset: extra_patients, deterioration_multiplier, equipment_bonus, time_multiplier |
| Constant | `DEFAULT_ZONE_RADIUS := 3.0` | Default position variation radius |
| Method | `randomise_scenario(scenario_data, seed) -> Dictionary` | Deep-copy with varied positions, conditions, hazards, event times. Same seed = same layout |
| Method | `apply_difficulty(scenario_data, difficulty) -> Dictionary` | Scale time_limit, deterioration, equipment count, patient count per preset |
| Static | `generate_seed() -> int` | Random seed generator |
| Variation | Patient positions | Within zone radius (explicit or marker-based offset) |
| Variation | Patient conditions | bleeding ±1, breathing ±4, pain ±2, panic ±0.2 |
| Variation | Equipment positions | Within zone radius |
| Variation | Hazard placements | Position ±radius, initial radius ±20% |
| Variation | Event trigger times | Re-rolled within [trigger_time_min, trigger_time_max] |

---

### PhysicsInteractable (`scripts/gameplay/physics_interactable.gd`)
**Extends:** Node
Physics-based interactions for debris, doors, and stretchers. Hooks into InteractableComponent signal.

| Type | Name | Details |
|------|------|---------|
| Enum | `PhysicsType` | `DEBRIS`, `DOOR`, `STRETCHER` |
| Export | `physics_type: PhysicsType` | Interaction mode |
| Export | `mass_limit: float = 100.0` | Max pushable weight (DEBRIS) |
| Export | `push_force: float = 5.0` | Force applied to RigidBody3D (DEBRIS) |
| Var | `is_active: bool` | Currently being pushed/dragged |
| Var | `is_open: bool` | Door open state (DOOR) |
| Var | `loaded_patient: Node3D` | Patient on stretcher or null (STRETCHER) |
| Method | `_toggle_push(interactor)` | DEBRIS: start/stop push mode with mass check |
| Method | `_toggle_door()` | DOOR: open/close via AnimationPlayer or rotation fallback, NavMesh rebake |
| Method | `_handle_stretcher_interact(interactor)` | STRETCHER: load patient / start drag / release |
| Method | `_load_patient(patient)` | Reparent patient to stretcher, disable interaction |
| Method | `unload_patient() -> Node3D` | Reparent patient back to scene, re-enable interaction |
| Telemetry | `physics_interact` | Logs object_type + action (push/release/open/close/drag/load_patient) |

---

### HUDController (`scripts/ui/hud_controller.gd`)
**Extends:** CanvasLayer
Wires InteractionManager + AssessmentManager signals to InteractionPrompt + ActionMenu.

| Type | Name | Details |
|------|------|---------|
| Method | `_wire_managers()` | Finds Player, connects InteractionManager + AssessmentManager signals |
| Method | `_on_target_changed(old, new)` | Routes to InteractionPrompt.on_target_changed |
| Method | `_on_assessment_started(patient)` | Hides prompt, opens ActionMenu |
| Method | `_on_assessment_ended(patient)` | Closes menu, restores prompt |
| Method | `_on_action_selected(name)` | Routes to AssessmentManager.perform_assessment_by_name |
| Method | `_wire_triage_system()` | Finds TriageSystem in scene tree, connects triage_assigned signal |
| Method | `_on_triage_assigned(patient, assigned_tag, correct_tag, is_correct)` | Maps enum to label, calls patient TriageTagVisual.set_triage_tag() |
| Method | `_find_node_with_signal(node, signal_name) -> Node` | Recursive scene tree search for node with named signal |

---

### TriageTagVisual (`scripts/ui/triage_tag_visual.gd`)
**Extends:** MeshInstance3D
Colour-coded 3D tag above patient after triage assignment. Hidden until assigned. Incorrect tags pulse subtly.

| Type | Name | Details |
|------|------|---------|
| Constant | `TAG_COLOURS` | Dictionary: GREEN=#00FF00, YELLOW=#FFFF00, RED=#FF0000, BLACK=#333333 |
| Var | `_is_assigned: bool` | Whether a tag has been set |
| Var | `_pulse_tween: Tween` | Looping tween for incorrect tag pulse |
| Method | `_ready()` | Hide tag until assigned |
| Method | `set_triage_tag(tag_label: String, is_correct: bool)` | Set colour + emission from TAG_COLOURS, start pulse if incorrect |

---

### PatientStatusVisual (`scripts/ui/patient_status_visual.gd`)
**Extends:** Node
4 visual channels driven by MedicalStateComponent signals: breathing, bleeding, consciousness, colour tint.

| Type | Name | Details |
|------|------|---------|
| Var | `_medical: Node` | MedicalStateComponent reference (sibling) |
| Var | `_parent_mesh: MeshInstance3D` | Patient's visual mesh for posture/tint |
| Var | `_breathing_tween: Tween` | Scale oscillation synced to breathing_rate |
| Var | `_blood_pool: MeshInstance3D` | Red PlaneMesh beneath patient, scales with bleeding severity |
| Method | `_ready()` | Find medical component + mesh, connect signals, init visuals |
| Method | `_on_state_changed(old, new)` | Update posture (Transform3D) + colour tint per state |
| Method | `_on_modifier_changed(name, old, new)` | Update breathing tween cycle / blood pool scale |
| Method | `_update_breathing(rate)` | Restart scale oscillation tween (cycle_duration = 60.0/rate) |
| Method | `_update_bleeding(severity)` | Scale blood pool diameter (0.4 * severity) |
| Method | `_set_posture(state)` | CONSCIOUS=upright, UNCONSCIOUS/CARDIAC_ARREST/DEAD=lying |
| Method | `_desaturate(color, amount)` | Lerp toward grey for cardiac arrest (0.6) |

---

### ScenarioTimer (`scripts/ui/scenario_timer.gd`)
**Extends:** Control
MM:SS countdown display anchored top-right. Colour-coded urgency states with pulse at ≤10%.

| Type | Name | Details |
|------|------|---------|
| Constant | `WARNING_THRESHOLD_YELLOW := 0.5` | 50% remaining → yellow |
| Constant | `WARNING_THRESHOLD_RED := 0.25` | 25% remaining → red |
| Constant | `WARNING_THRESHOLD_PULSE := 0.1` | 10% remaining → pulsing red |
| Var | `_time_label: Label` | MM:SS display, font_size 28 |
| Var | `_total_time: float` | Total scenario time for threshold calculation |
| Var | `_pulse_tween: Tween` | Looping alpha tween for critical warning |
| Method | `_ready()` | Build UI, find TimePressureSystem, connect signals |
| Method | `_on_time_updated(remaining)` | Update label text + colour state |
| Method | `_on_time_warning(remaining)` | Trigger pulse if ≤10% |
| Method | `_on_time_expired()` | Show "00:00" in red |

---

### ReviewPanel (`scripts/ui/review_panel.gd`)
**Extends:** Control
AI performance review display. Left: scrollable colour-coded narrative. Right: metrics sidebar.

| Type | Name | Details |
|------|------|---------|
| Enum | `PanelState` | `HIDDEN`, `LOADING`, `REVIEW`, `ERROR` |
| Constant | `COLOUR_OVERALL` | White (1.0, 1.0, 1.0) |
| Constant | `COLOUR_STRENGTHS` | Green (0.3, 0.9, 0.3) |
| Constant | `COLOUR_IMPROVEMENTS` | Yellow (1.0, 0.9, 0.2) |
| Constant | `COLOUR_ERRORS` | Red (1.0, 0.3, 0.3) |
| Constant | `COLOUR_RECOMMENDATIONS` | Blue (0.4, 0.7, 1.0) |
| Signal | `review_closed` | Emitted on Continue button press |
| Method | `show_loading()` | Show loading spinner state |
| Method | `show_review(review_data, metrics)` | Populate narrative + metrics sidebar |
| Method | `show_error(message)` | Show error fallback message |
| Method | `_populate_narrative(review_data)` | Build colour-coded sections: overall, strengths, improvements, errors, recommendations |
| Method | `_populate_metrics(metrics)` | Build sidebar: scenario_time, patients_treated, triage_accuracy, protocol_adherence |

---

### DebriefScreen (`scripts/ui/debrief_screen.gd`)
**Extends:** Control
Immediate end-of-scenario debrief. Quick stats + per-patient summary cards. Transitions to ReviewPanel when AI review arrives.

| Type | Name | Details |
|------|------|---------|
| Signal | `return_to_menu` | Emitted on Return to Menu button |
| Method | `show_debrief(results)` | Populate stats + patient cards, show panel |
| Method | `_populate_stats(results)` | GridContainer: time, patients assessed, triage accuracy, actions |
| Method | `_populate_patient_cards(results)` | ScrollContainer: per-patient name, state (colour-coded), triage tag, correct/incorrect |
| Method | `_build_patient_summaries_from_events(results)` | Build patient list from telemetry events if not provided |
| Method | `_on_scenario_ended(results)` | ScenarioManager signal handler |
| Method | `_on_review_parsed(review_data)` | Hand off to ReviewPanel.show_review() |
| Method | `_on_review_failed(error)` | Show "AI Review unavailable" status |
| Method | `_build_metrics_dict()` | Build metrics Dictionary for ReviewPanel sidebar |

---

### HazardVisualEffects (`scripts/ui/hazard_visual_effects.gd`)
**Extends:** Node
Visual effects for environmental hazards — fire/smoke particles, collapse dust/barrier, traffic flashing, zone borders, screen warning.

| Type | Name | Details |
|------|------|---------|
| Constant | `FIRE_PARTICLE_COUNT := 64` | Fire GPUParticles3D amount |
| Constant | `SMOKE_PARTICLE_COUNT := 32` | Smoke GPUParticles3D amount |
| Constant | `DUST_PARTICLE_COUNT := 24` | Collapse dust amount |
| Var | `_zone_effects: Dictionary` | Zone → {particles, light, border, smoke} mapping |
| Var | `_warning_overlay: ColorRect` | Screen-edge red flash on hazard entry |
| Method | `_on_hazard_activated(zone)` | Create VFX suite per hazard type |
| Method | `_create_fire_vfx(zone)` | GPUParticles3D (orange→red) + OmniLight3D (warm) + smoke particles |
| Method | `_create_collapse_vfx(zone)` | Dust GPUParticles3D (brown) + barrier BoxMesh |
| Method | `_create_traffic_vfx(zone)` | Flashing OmniLight3D (orange, 0.3s tween loop) |
| Method | `_create_zone_border(zone, color)` | CylinderMesh ring, semi-transparent |
| Method | `_update_fire_radius(zone, new_radius)` | Rescale emission, light range, border on hazard_expanded |
| Method | `_on_entity_in_hazard(entity, type)` | Start screen warning pulse for player |
| Method | `_on_entity_left_hazard(entity, type)` | Stop screen warning for player |

---

### EnvironmentalAudio (`scripts/ui/environmental_audio.gd`)
**Extends:** Node
Procedural spatial audio for hazards and event notifications. No external audio files.

| Type | Name | Details |
|------|------|---------|
| Constant | `TYPE_FIRE := 0` | Hazard type constant |
| Constant | `TYPE_COLLAPSE := 1` | Hazard type constant |
| Constant | `TYPE_TRAFFIC := 2` | Hazard type constant |
| Constant | `MAX_DISTANCE := 25.0` | AudioStreamPlayer3D max falloff distance |
| Var | `_audio_players: Dictionary` | Zone → AudioStreamPlayer3D mapping |
| Var | `_notification_player: AudioStreamPlayer` | Non-spatial UI chime player |
| Var | `_proximity_player: AudioStreamPlayer` | Non-spatial proximity warning player |
| Method | `_create_audio_for_zone(zone)` | Create AudioStreamPlayer3D with procedural stream per hazard type |
| Method | `_generate_hazard_audio(type) -> AudioStream` | Generate 8-bit 22050Hz 2s loop: fire (noise+pops), collapse (40Hz rumble), traffic (80Hz drone+horn) |
| Method | `_play_notification_chime()` | Two-tone C5+E5 with decay envelope on random_event_triggered |
| Method | `_play_proximity_warning(type)` | Looping beep: 880Hz fire, 440Hz collapse, 660Hz traffic |
| Method | `cleanup()` | Free all audio players |

---

## Scenes

| Scene | Path | Type | Purpose |
|-------|------|------|---------|
| Player | `scenes/entities/player/Player.tscn` | CharacterBody3D | EMT character + InteractionManager, InventoryComponent, AssessmentManager, TelemetryEmitter, PositionTracker, HeldItemMount |
| IsometricCamera | `scenes/gameplay/IsometricCamera.tscn` | Camera3D | Orthographic isometric camera rig |
| TestLevel | `scenes/gameplay/TestLevel.tscn` | Node3D | 10x10 tile grid test environment + HUD |
| Road | `scenes/environments/Road.tscn` | StaticBody3D | Road tile (grey) with collision |
| Sidewalk | `scenes/environments/Sidewalk.tscn` | StaticBody3D | Sidewalk tile (light grey) with collision |
| Grass | `scenes/environments/Grass.tscn` | StaticBody3D | Grass tile (green) with collision |
| RoadTrafficAccident | `scenes/environments/RoadTrafficAccident.tscn` | Node3D | 16x16 RTA scenario level + HUD |
| PatientBase | `scenes/entities/patients/PatientBase.tscn` | CharacterBody3D | Patient entity: MedicalState, Interactable, TriageTag, DeteriorationSystem |
| AED | `scenes/entities/equipment/AED.tscn` | CharacterBody3D | AED equipment variant (red box) |
| Bandage | `scenes/entities/equipment/Bandage.tscn` | CharacterBody3D | Bandage variant (white box) |
| Splint | `scenes/entities/equipment/Splint.tscn` | CharacterBody3D | Splint variant (brown box) |
| OxygenMask | `scenes/entities/equipment/OxygenMask.tscn` | CharacterBody3D | Oxygen mask variant (blue box) |
| Stretcher | `scenes/entities/equipment/Stretcher.tscn` | CharacterBody3D | Stretcher variant (green box) |
| HUD | `scenes/ui/hud/HUD.tscn` | CanvasLayer | HUDController + InteractionPrompt + ActionMenu + ScenarioTimer + DebriefScreen + ReviewPanel + HazardVisualEffects + EnvironmentalAudio |
| InteractionPrompt | `scenes/ui/hud/InteractionPrompt.tscn` | Control | Floating "[E] {label}" prompt |
| ActionMenu | `scenes/ui/hud/ActionMenu.tscn` | Control | 5-button assessment menu |
| ScenarioTimer | `scenes/ui/hud/ScenarioTimer.tscn` | Control | MM:SS countdown timer, anchored top-right |
| ReviewPanel | `scenes/ui/review/ReviewPanel.tscn` | Control | AI review display overlay (narrative + metrics) |
| DebriefScreen | `scenes/ui/review/DebriefScreen.tscn` | Control | End-of-scenario debrief (stats + patient cards) |

---

## Autoload Singletons

| Name | Script | Purpose |
|------|--------|---------|
| `GameManager` | `scripts/core/game_manager.gd` | Global state, scene transitions |
| `TelemetryCollector` | `scripts/telemetry/telemetry_collector.gd` | Session data collection, JSON export |
| `ScenarioManager` | `scripts/core/scenario_manager.gd` | Scenario loading, entity spawning, lifecycle |

---

## Input Map

| Action | Default Binding | Purpose |
|--------|----------------|---------|
| `move_up` | W / Up Arrow | Move toward top-right (isometric) |
| `move_down` | S / Down Arrow | Move toward bottom-left (isometric) |
| `move_left` | A / Left Arrow | Move toward top-left (isometric) |
| `move_right` | D / Right Arrow | Move toward bottom-right (isometric) |
| `interact` | E | Interact with nearest interactable |
| `drop` | Q | Drop held equipment |

---

## Data Files

| File | Format | Purpose |
|------|--------|---------|
| `data/scenarios/scenario_tutorial.json` | JSON | Tutorial scenario — 1 patient, 2 equipment, 300s |
| `data/scenarios/scenario_rta.json` | JSON | RTA scenario — 3 patients, 3 equipment, 600s |
| `data/protocols/bcls_protocol.json` | JSON | 9-step BLS sequence (AHA/Thai Red Cross) |
| `data/prompts/triage_reviewer_system.txt` | Text | System prompt: EMT instructor persona for AI review |
| `user_data/ai_config.json` | JSON | AI config defaults (model, timeout, max_tokens) |
| `data/protocols/als_protocol.json` | JSON | 10-step ALS sequence |
| `data/protocols/start_triage.json` | JSON | START triage decision tree (6 nodes) |

---

## Asset Strategy — Sources & Locations

**Art Direction:** Clean low-poly realistic — correct human proportions, professional muted palette, clean geometry. NOT cartoon, NOT anime, NOT stylised.

**Competition Rule:** Open source assets are explicitly allowed per TMH2026 handbook: *"ยกเว้นโค้ด Open Source ที่อนุญาตให้ใช้ได้"*

### Primary Asset Sources

#### 1. [Mixamo](https://www.mixamo.com/) — Characters & Animations (Free, Adobe Account)
**What to find here:**
- **EMT Character** — Search: "character" → pick a realistic adult humanoid → retexture uniform in Blender
- **Patient NPCs** — Search: varied body types → use lying/sitting poses for injured patients
- **Animations** — Search: "walk", "run", "crouch", "idle", "pickup", "kneel" → apply to any Mixamo character
- **How:** Download as `.fbx` → import to Blender → retexture → export as `.glb` for Godot

#### 2. [Poly Haven](https://polyhaven.com/) — PBR Textures & Materials (CC0)
**What to find here:**
- **Ground surfaces** — Search: "[asphalt](https://polyhaven.com/textures?s=asphalt)", "[concrete](https://polyhaven.com/textures?s=concrete)", "[grass](https://polyhaven.com/textures?s=grass)", "[gravel](https://polyhaven.com/textures?s=gravel)"
- **Building surfaces** — Search: "[brick](https://polyhaven.com/textures?s=brick)", "[plaster](https://polyhaven.com/textures?s=plaster)", "[metal](https://polyhaven.com/textures?s=metal)"
- **HDRIs** — Search: "[outdoor](https://polyhaven.com/hdris?s=outdoor)", "[overcast](https://polyhaven.com/hdris?s=overcast)" → realistic sky/lighting for scenes
- **How:** Download texture set (diffuse, normal, roughness) → apply to tile meshes in Godot material inspector

#### 3. [ambientCG](https://ambientcg.com/) — PBR Materials (CC0)
**What to find here:**
- **Medical surfaces** — Search: "[plastic](https://ambientcg.com/list?type=Material&q=plastic)", "[fabric](https://ambientcg.com/list?type=Material&q=fabric)", "[rubber](https://ambientcg.com/list?type=Material&q=rubber)"
- **Vehicle surfaces** — Search: "[paint](https://ambientcg.com/list?type=Material&q=paint)", "[metal](https://ambientcg.com/list?type=Material&q=metal)"
- **Environment** — Search: "[tiles](https://ambientcg.com/list?type=Material&q=tiles)", "[wood](https://ambientcg.com/list?type=Material&q=wood)"
- **How:** Same as Poly Haven — download PBR set, apply in Godot

#### 4. [Sketchfab](https://sketchfab.com/) — 3D Models (Filter: Downloadable + CC0/CC-BY)
**What to find here:**
- **Medical Equipment** — Search: "[AED defibrillator](https://sketchfab.com/search?q=AED+defibrillator&type=models&downloadable=true)", "[stretcher](https://sketchfab.com/search?q=stretcher&type=models&downloadable=true)", "[first aid kit](https://sketchfab.com/search?q=first+aid+kit&type=models&downloadable=true)", "[oxygen mask](https://sketchfab.com/search?q=oxygen+mask&type=models&downloadable=true)", "[medical bag](https://sketchfab.com/search?q=medical+bag&type=models&downloadable=true)"
- **Vehicles** — Search: "[ambulance](https://sketchfab.com/search?q=ambulance&type=models&downloadable=true)", "[fire truck](https://sketchfab.com/search?q=fire+truck&type=models&downloadable=true)", "[police car](https://sketchfab.com/search?q=police+car&type=models&downloadable=true)"
- **Urban props** — Search: "[traffic cone](https://sketchfab.com/search?q=traffic+cone&type=models&downloadable=true)", "[barrier](https://sketchfab.com/search?q=barrier&type=models&downloadable=true)", "[fire hydrant](https://sketchfab.com/search?q=fire+hydrant&type=models&downloadable=true)", "[street light](https://sketchfab.com/search?q=street+light&type=models&downloadable=true)"
- **Buildings** — Search: "[low poly building](https://sketchfab.com/search?q=low+poly+building&type=models&downloadable=true)", "[hospital](https://sketchfab.com/search?q=hospital&type=models&downloadable=true)"
- **How:** Download as `.glb` → import directly to Godot (or via Blender for adjustments)
- **Important:** Always check the license on each model — filter for CC0 or CC-BY. CC-BY requires attribution in credits

#### 5. [Quaternius](https://quaternius.com/) — Game-Ready 3D Packs (CC0)
**What to find here:**
- **Characters** — [Ultimate Character Pack](https://quaternius.com/packs/ultimatecharacter.html) — rigged, animated humanoids
- **Vehicles** — [Ultimate Vehicle Pack](https://quaternius.com/packs/ultimatevehicle.html) — cars, trucks (check for ambulance/emergency)
- **Urban** — [Ultimate City Pack](https://quaternius.com/packs/ultimatecity.html) — buildings, roads, props
- **Animations** — [Universal Animation Library](https://quaternius.com/packs/universalanimation.html) — 120+ game-ready animations, retargetable to any character in Godot
- **How:** Download from Google Drive links on each pack page → `.fbx` or `.glb` → import to Godot
- **Note:** Quaternius style is clean low-poly — realistic proportions, not cartoon. Good fit for our art direction

#### 6. [OpenGameArt](https://opengameart.org/) — Community Assets (Various CC Licenses)
**What to find here:**
- **Isometric tiles** — Search: "[isometric](https://opengameart.org/art-search-advanced?keys=isometric&type=art3d)", "[city](https://opengameart.org/art-search-advanced?keys=city&type=art3d)"
- **Props** — Search: "[medical](https://opengameart.org/art-search-advanced?keys=medical&type=art3d)", "[urban](https://opengameart.org/art-search-advanced?keys=urban&type=art3d)"
- **How:** Check license per asset. Prefer CC0 or CC-BY
- **Caution:** Quality varies widely — curate carefully

#### 7. [Kenney](https://kenney.nl/assets) — Rapid Prototyping Only (CC0)
**What to find here:**
- **Placeholder geometry** — [City Kit (Roads)](https://kenney.nl/assets/city-kit-roads), [City Kit (Commercial)](https://kenney.nl/assets/city-kit-commercial)
- **UI elements** — [UI Pack](https://kenney.nl/assets/ui-pack), [Game Icons](https://kenney.nl/assets/game-icons)
- **How:** Use as placeholder during development. Replace with realistic assets before competition
- **Note:** Kenney's style is distinctly stylised — use for prototyping ONLY, not final

#### 8. [Game-icons.net](https://game-icons.net/) — UI Icons (CC-BY)
**What to find here:**
- **Medical icons** — Search: "heart", "bandage", "syringe", "pulse", "hospital", "ambulance"
- **Gameplay icons** — Search: "timer", "target", "shield", "warning"
- **How:** Download as SVG or PNG → use in Godot UI Control nodes
- **Note:** CC-BY license — must credit in game credits screen

### Required Tool

#### [Blender](https://www.blender.org/) (Free, Open Source)
**You need this for:**
- Retexturing Mixamo characters (apply EMT uniform colours/materials)
- Adjusting scale/rotation of downloaded assets for Godot import
- Minor modifications (colour changes, combining props)
- Exporting to `.glb`/`.gltf` (Godot's preferred 3D import format)
- **No modelling from scratch required** — import → adjust → export

### Asset Mapping Per Game Entity

| Game Entity | Primary Source | Search Terms | Format |
|-------------|---------------|-------------|--------|
| EMT Player Character | Mixamo → Blender | "character" → retexture as EMT | .fbx → .glb |
| Patient NPCs (conscious) | Mixamo → Blender | "character" + sitting/lying animations | .fbx → .glb |
| Patient NPCs (unconscious) | Mixamo → Blender | "character" + lying pose | .fbx → .glb |
| AED Defibrillator | Sketchfab | "AED defibrillator" | .glb |
| Stretcher | Sketchfab | "stretcher medical" | .glb |
| First Aid Kit | Sketchfab | "first aid kit" | .glb |
| Oxygen Mask | Sketchfab | "oxygen mask medical" | .glb |
| Bandages/Splints | Sketchfab | "bandage", "splint" | .glb |
| Ambulance | Sketchfab / Quaternius | "ambulance" | .glb |
| Fire Truck | Sketchfab / Quaternius | "fire truck" | .glb |
| Traffic Cones/Barriers | Sketchfab / Quaternius | "traffic cone", "barrier" | .glb |
| Road Tiles | Poly Haven textures on box mesh | "asphalt" texture | .png PBR set |
| Sidewalk Tiles | Poly Haven textures on box mesh | "concrete" texture | .png PBR set |
| Grass Tiles | Poly Haven textures on box mesh | "grass" texture | .png PBR set |
| Buildings | Sketchfab / Quaternius City Pack | "low poly building" | .glb |
| Street Lights/Props | Sketchfab / Quaternius | "street light", "fire hydrant" | .glb |
| Triage Tags (visual) | Custom — coloured 3D labels | Green/Yellow/Red/Black | Made in Godot |
| UI Icons | Game-icons.net / Kenney UI Pack | "heart", "bandage", "timer" | .svg / .png |
| HUD Elements | Kenney UI Pack | UI components | .png |
| Sky/Lighting | Poly Haven HDRIs | "overcast", "outdoor" | .hdr / .exr |

---

*This is a living document. Update whenever new code is implemented or assets are acquired.*
