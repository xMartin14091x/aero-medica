# AeroMedica -- Feature Descriptions

**Project:** AeroMedica -- Emergency Response Training Simulation
**Engine:** Godot 4.6 (Forward Plus, Jolt Physics, D3D12)
**Language:** GDScript
**Last Updated:** 29-03-2026

---

## 1. Patient Assessment System

The Patient Assessment System implements the full DRSABCDE primary survey protocol used in pre-hospital emergency care. Players assess patients sequentially through Danger, Response, Send for Help, Airway, Breathing, Circulation, Disability, and Exposure checks, each mapped to a button with a cooldown timer (DRS at 0.5s, ABCDE at 2.0s). Assessment results are displayed in real time and recorded to telemetry for protocol adherence analysis.

Vital sign assessment is handled as a dedicated sub-tab within the Exam tab, covering heart rate, blood pressure, respiratory rate, SpO2, temperature, blood glucose, capillary refill, and pupil examination. Each vital sign check has a 1.5-second cooldown with up to 2 concurrent assessments allowed. Results populate from the patient's `MedicalStateComponent`, which holds all physiological values.

ECG rhythm display is provided by `ECGRhythmManager` (autoload singleton), which loads rhythm definitions from `data/ecg_rhythms.json`. The system supports two modes -- AED mode (auto-analysis with shock advisory for VFib/VTach) and Monitor mode (manual identification). ECG rhythm images are loaded from `assets/textures/ecg/` and cached for performance. An "Identify Rhythm" button presents all rhythm options for quiz-style identification.

The Glasgow Coma Scale (GCS) assessment is managed by `GCSAssessmentManager`, which implements the standard 3-component scoring system (Eye 1-4, Verbal 1-5, Motor 1-6) with severity bands (Mild 13-15, Moderate 9-12, Severe 3-8). GCS scores of 8 or below trigger an airway protection warning per clinical protocol.

Head-to-Toe secondary survey is handled by `SecondarySurveyManager`, which gates behind primary survey completion. Seven body regions (head, neck, chest, abdomen, pelvis, back, extremities) are examined in order, with findings loaded from scenario JSON data. Critical findings containing keywords like "fracture", "pneumothorax", or "unstable" trigger visual alerts. The system supports bilingual findings -- Thai text is loaded when the locale begins with "th".

**Key Files:** `scripts/ui/patient_interaction_ui.gd`, `scripts/medical/medical_state_component.gd`, `scripts/medical/ecg_rhythm_manager.gd`, `scripts/medical/gcs_assessment_manager.gd`, `scripts/medical/secondary_survey_manager.gd`, `scripts/gameplay/assessment_manager.gd`

---

## 2. Treatment System

The Treatment System provides two tiers of equipment -- BLS (Basic Life Support) and ALS (Advanced Life Support) -- managed by `MedicalBagTierManager`. BLS equipment includes items like bandages, tourniquets, cervical collars, splints, oxygen masks, BVM, pulse oximeter, BP cuff, and AED. ALS scenarios add IV access kits, cardiac drugs (Adrenaline, Atropine, Amiodarone, Naloxone), fluid bags (Normal Saline, Lactated Ringer's), and glucose solutions. Equipment has quantity tracking and consumable depletion -- once used, consumable items decrement and can run out.

Drug administration is handled by `DrugAdministrationManager`, which loads the full pharmacological database from `data/drugs.json`. The system enforces clinical safety rules: route validation (IV, IO, IM, SC, nebulised, sublingual), IV access requirement for IV/IO routes, contraindication checking (hypotension, tachycardia, respiratory depression), and maximum dose limits. Medication errors are classified into 7 categories (WRONG_DRUG, WRONG_DOSE, WRONG_ROUTE, WRONG_CONCENTRATION, CONTRAINDICATED, EXCEEDED_MAX_DOSE, TOO_SOON) and logged for AI review. Drug effects modify patient vital signs through the `MedicalStateComponent` modifier system.

CPR and AED logic is implemented directly in `MedicalStateComponent.apply_treatment()`. CPR resets the cardiac arrest death countdown timer in `DeteriorationSystem` but does not trigger ROSC on its own. AED checks for shockable rhythms (VFib, VTach) -- if shockable, it triggers ROSC (Return of Spontaneous Circulation), setting the patient to UNCONSCIOUS state with post-resuscitation vitals (HR 50, BP 80, SpO2 88%, rhythm SINUS_BRADYCARDIA) and slowing deterioration rate by 70%. For non-shockable rhythms (Asystole, PEA), the AED advises "No shock" and CPR remains the only option. Each effective treatment also reduces deterioration rate by 20% (stacking multiplicatively, floor at 0.1x).

**Key Files:** `scripts/medical/drug_administration_manager.gd`, `scripts/medical/medical_bag_tier_manager.gd`, `scripts/medical/medical_state_component.gd`, `data/drugs.json`, `data/medical_bag_tiers.json`

---

## 3. AI System

The AI system consists of two independent Ollama clients that auto-discover a local Ollama instance on startup. Both `OllamaDialogueClient` and `OllamaReviewClient` probe candidate addresses in parallel -- configured URL first, then localhost, 127.0.0.1, and all local network IPv4 addresses on port 11434. The first successful probe (HTTP 200 from `/api/tags`) wins. Default model is `llama3.1:8b`, configurable via `user_data/ai_config.json`.

The Patient Dialogue system (`OllamaDialogueClient`) enables free-form conversation between the player and AI-controlled patients. When the player opens the Patient tab and types a question, the system sends it to Ollama with a structured system prompt built from the patient's `PatientPersona` data -- including name, age, consciousness level, pain/panic levels, and SAMPLE history. The AI is instructed to stay in character, keep responses short (1-3 sentences), and never fabricate symptoms or medical history not provided in the persona data. Conversation history is maintained per-patient session (limited to 6 recent exchanges for context). When Ollama is offline, the system falls back to static `PatientPersona` responses.

The AI Reviewer (`OllamaReviewClient`) generates narrative performance reviews from structured telemetry data after each scenario. It composes a detailed prompt containing scenario overview, per-patient summaries (final state, triage correctness, equipment deployed, diagnoses, time attention), treatment timeline, triage accuracy, diagnosis summary, and hazard exposure data. The system prompt (`data/prompts/triage_reviewer_system.txt`) defines the clinical instructor persona. Language is controlled by locale -- Thai locale appends instructions to respond entirely in Thai while keeping medical abbreviations in English. The review client supports one retry on failure.

The Cached Fallback system (`AIDemoFallback`, registered as autoload) serves pre-written AI reviews when Ollama is unavailable -- critical for competition demos without GPU. It maintains 35 English cached review files and 35 Thai translations across 6 scenarios, each with 5 performance tiers (perfect, good, poor, catastrophic, empty). Tier selection is based on overall score and event count thresholds (perfect >= 90, good >= 60, poor >= 30, catastrophic < 30, empty <= 3 events). The system attempts Thai variants first when locale is "th", falling back to English if the Thai file does not exist.

**Key Files:** `scripts/ai/ollama/ollama_dialogue_client.gd`, `scripts/ai/reviewer/ollama_review_client.gd`, `scripts/ai/reviewer/ai_demo_fallback.gd`, `scripts/medical/patient_persona.gd`, `data/prompts/triage_reviewer_system.txt`, `data/prompts/cached_reviews/` (70 files)

---

## 4. Triage System

The Triage System implements the START (Simple Triage and Rapid Treatment) protocol through `TriageSystem` (autoload singleton). Players assign one of four triage tags to each patient -- GREEN (Minor/Walking Wounded), YELLOW (Delayed), RED (Immediate), or BLACK (Deceased). The system validates the assigned tag against the correct tag computed from the patient's medical state but does not prevent incorrect assignments -- this is a stealth assessment design where the player's triage decisions are silently recorded and evaluated in the debrief.

Correct triage priority is computed by `MedicalStateComponent.get_triage_priority()` using clinical criteria: DEAD state = BLACK; cardiac arrest, no pulse, breathing rate < 8, obstructed airway, bleeding severity >= 2, unconscious, BP < 70, HR > 150, or SpO2 < 90 = RED; abnormal breathing or moderate injuries = YELLOW; all others = GREEN. To prevent deterioration from invalidating the player's assessment, the system stores the initial triage priority at spawn time via patient metadata (`initial_triage_priority`) and uses this for correctness evaluation rather than the end-of-scenario state.

Once tagged, a patient cannot be re-tagged -- the assignment is final. All triage assignments are logged to telemetry with timestamps, assigned/correct tags, and correctness flags. The `get_triage_summary()` method computes aggregate accuracy (total tagged, correct count, accuracy percentage) for the debrief screen and AI reviewer.

**Key Files:** `scripts/medical/triage_system.gd`, `scripts/medical/medical_state_component.gd` (get_triage_priority), `scripts/ui/patient_interaction_ui.gd` (triage tab UI)

---

## 5. Deterioration System

The Deterioration System (`DeteriorationSystem`) is attached to each patient entity and simulates time-based clinical deterioration of untreated conditions. It operates on a two-phase budget gate designed to give players fair time to intervene before critical state transitions.

Phase 1 (pre-cardiac arrest) has a 300-second budget that drains at 1x speed when the player is not interacting with the patient, and 3.33x speed when the patient's interaction UI is open (effectively 90 seconds focused). Critical transitions (unconscious-to-cardiac arrest) are blocked until the budget reaches zero. Phase 2 (cardiac arrest to death) resets the budget to 120 seconds, draining at 1x unfocused or 2x focused (60 seconds). Multi-patient scenarios scale budgets by `max(1, patient_count / 2)` -- so 6 patients get 3x budget.

Non-critical deterioration runs independently of the budget gate: bleeding severity increases every 30 seconds (interval configurable per scenario), airway obstruction gradually drops breathing rate toward unconsciousness, and vital signs deteriorate periodically (haemorrhage causes tachycardia and hypotension, airway obstruction causes hypoxia). An idle time scaling factor of 0.3x applies when the player's mouse is captured (walking around), meaning deterioration runs at 30% speed when the player is not in any patient's interaction UI. This prevents unfocused patients from dying too quickly while the player treats someone else.

Deterioration pauses entirely during active treatment (`is_being_treated` flag). Successful treatments reduce the deterioration rate by 20% multiplicatively (floor 0.1x). Post-ROSC deterioration rate is reduced by 70%. The DEAD state permanently disables processing via `set_process(false)`.

**Key Files:** `scripts/medical/deterioration_system.gd`, `scripts/medical/medical_state_component.gd` (apply_treatment, ROSC logic), `scripts/core/scenario_manager.gd` (budget scaling)

---

## 6. Scoring and Dashboard System

The Scoring Engine (`ScoringEngine`) calculates 5-axis clinical skill scores from session telemetry, each on a 0-100 scale: Triage Speed (20% weight), Protocol Accuracy (25%), Decision Quality (20%), Equipment Handling (15%), and Patient Outcome (20%). Triage Speed uses benchmark times (excellent if first assessment under 15s, first triage under 30s; zero if over 60s/120s respectively). Protocol Accuracy penalizes wrong-order steps (-5 points each). Decision Quality penalizes wrong priority (-25 critical, -15 minor) and wrong triage (-20/-10). Equipment Handling scores correct usage ratio with penalties for wrong equipment. Patient Outcome maps final patient states (CONSCIOUS=100, UNCONSCIOUS=60, CARDIAC_ARREST=20, DEAD=0). Pass threshold is 60%.

The Dashboard (`dashboard.gd`) presents a 2-tab interface: "My Performance" (overall trends and best scores across all scenarios) and "Scenario Breakdown" (per-scenario detail with radar chart and history table). It reads from `HistoryManager` autoload and is fully styled by `ThemeMedical`. A custom `RadarChart` control draws the 5-axis scores as a radar polygon. Five scenario pills (Tutorial, RTA, Cardiac, MCI, Fire) allow switching between scenarios.

`HistoryManager` persists session scores to `user://history/` as individual JSON files (one per session). It provides query methods for per-scenario history, best scores, and improvement trend detection. Trends are calculated by comparing the average of the most recent half of a 5-session window against the earlier half, classifying as IMPROVING (delta > 3%), DECLINING (delta < -3%), or STABLE. Maximum retention is 100 sessions per scenario, with oldest entries pruned automatically.

`DataExporter` supports CSV and JSON export of performance data. CSV includes date, scenario ID, all 5 axis scores, overall score, pass/fail, and AI review summary. JSON export adds per-scenario summary statistics including best scores and trend data. Export can be triggered via file dialog or quick-exported to `user://exports/`.

**Key Files:** `scripts/dashboard/scoring_engine.gd`, `scripts/ui/dashboard.gd`, `scripts/dashboard/history_manager.gd`, `scripts/dashboard/data_exporter.gd`, `scripts/ui/radar_chart.gd`

---

## 7. Scenario System

The Scenario System is managed by `ScenarioManager` (autoload singleton), which loads scenario definitions from JSON files in `data/scenarios/`. Seven scenario JSON files exist: `scenario_tutorial.json`, `scenario_rta.json`, `scenario_cardiac_arrest.json`, `scenario_building_fire.json`, `scenario_fire.json`, `scenario_mci.json`, and `scenario_cardiac.json`. Each scenario defines patients (with positions, personas, medical states, vital signs, deterioration rates, examination findings), equipment placements, environmental hazards, random events, time limits, correct diagnoses, and bag tier (BLS/ALS).

Scenario loading handles environment scene transitions via `get_tree().change_scene_to_file()` with proper async awaiting. Patient entities are instantiated from `PatientBase.tscn` and configured with persona data (name, age, consciousness, pain/panic levels, SAMPLE history including OPQRST), medical state modifiers, vital signs, and deterioration parameters. Equipment entities (AED, Bandage, Splint, Oxygen Mask, Stretcher) are spawned from individual scene files. Time limits enforce a minimum of 180 seconds per patient to prevent unsolvable scenarios.

The Hazard System (`HazardSystem`) spawns environmental hazard zones defined in scenario data, supporting three types: FIRE (with spread rate and damage per second), COLLAPSE, and TRAFFIC (intermittent danger with configurable interval). Hazard zones track player exposure time for telemetry and can incapacitate the player, ending the scenario. The Random Event System (`RandomEventSystem`) triggers mid-scenario events at randomised times within configured ranges, supporting NEW_PATIENT (spawn additional patient), EQUIPMENT_FAILURE (mark equipment as broken), and BYSTANDER (spawn interactable NPC) event types.

**Key Files:** `scripts/core/scenario_manager.gd`, `scripts/gameplay/hazard_system.gd`, `scripts/gameplay/hazard_zone.gd`, `scripts/gameplay/random_event_system.gd`, `data/scenarios/` (7 JSON files)

---

## 8. Localization System

The Localization System provides full bilingual support for Thai and English through `LocalisationManager` (autoload singleton). It loads translations from `data/translations/translations.csv`, which contains 362 rows (approximately 360 translation keys) across 3 columns (key, th, en). The CSV is parsed at startup and registered with Godot's `TranslationServer`, enabling the standard `tr()` function to work throughout the codebase.

Language switching is handled by `toggle_locale()`, which flips between "th" and "en" and emits a `locale_changed` signal. UI components that listen to this signal refresh their translated text immediately. The Settings menu provides a one-click language toggle button. Locale preference persists to `user://settings.json`.

Localization extends beyond UI text: cached AI reviews have Thai variants (35 `_th.txt` files), secondary survey examination findings load from `examination_findings_th` in scenario JSON when the locale is Thai, and the AI Reviewer client appends Thai language instructions to its system prompt when `TranslationServer.get_locale()` begins with "th".

**Key Files:** `scripts/core/localisation_manager.gd`, `data/translations/translations.csv`, `scripts/ai/reviewer/ai_demo_fallback.gd` (Thai fallback), `scripts/ai/reviewer/ollama_review_client.gd` (Thai instruction injection)

---

## 9. Differential Diagnosis System

The Differential Diagnosis system presents 47 conditions organized into 6 collapsible categories in the Differential tab of the Patient Interaction UI. Categories and condition counts: Cardiac (11 conditions including Cardiac Arrest, MI STEMI/NSTEMI, VFib, VTach, Aortic Dissection), Respiratory (8 including Tension Pneumothorax, Pulmonary Embolism, Smoke Inhalation), Trauma (9 including Multi-system Trauma, Crush Injury, Burns), Neurological (5 including Stroke, TBI, Spinal Injury), Medical (10 including Anaphylaxis, Sepsis, CO Poisoning, Opioid Overdose), and Other (4 including Acute Abdomen, Ectopic Pregnancy).

Players select up to 3 diagnoses from the categorized grid and submit them. Selected diagnoses are ranked 1-3 by selection order. Once submitted, the selection is locked and stored as patient metadata (`player_diagnoses`). The system compares submitted diagnoses against the scenario's `correct_diagnosis` array and records the number of matches (`diagnosis_matches`). Diagnosis accuracy feeds into the Decision Quality axis of the scoring engine and is included in the AI reviewer's prompt for narrative feedback.

The first two categories (Cardiac and Respiratory) are expanded by default, with remaining categories collapsed behind toggle headers. A search filter allows narrowing the visible conditions.

**Key Files:** `scripts/ui/patient_interaction_ui.gd` (_build_differential_tab, _populate_differential_tab), `scripts/core/scenario_manager.gd` (_compute_diagnosis_summary)
