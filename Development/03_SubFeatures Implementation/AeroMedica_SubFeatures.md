# AeroMedica -- Sub-Features Implementation

**Project:** AeroMedica -- Emergency Response Training Simulation
**Last Updated:** 29-03-2026

---

## Patient Assessment Sub-Features

### Action Cooldown System
**Parent:** Patient Assessment
**Files:** `scripts/ui/patient_interaction_ui.gd` (COOLDOWN_CONFIG, _start_cooldown, _can_start_cooldown)
**Description:** Per-action-group cooldown timers with circular progress overlay on buttons. Six groups with distinct delays and concurrency: DRS (0.5s, 1 concurrent), ABCDE (2.0s, 1), Vitals (1.5s, 2), Secondary Survey (2.0s, 1), Equipment (3.0s, 2), Drug Administration (5.0s, 1). Prevents spam-clicking and simulates realistic action timing.
**Status:** Implemented

### Sub-Tab UI (Exam 4 Tabs)
**Parent:** Patient Assessment
**Files:** `scripts/ui/patient_interaction_ui.gd` (_exam_sub_tabs, _exam_sub_tab_btns, _switch_exam_sub)
**Description:** The Exam tab contains 4 internal sub-tabs as a horizontal pill strip: Primary (DRSABCDE), Vitals (heart rate, BP, SpO2, etc.), GCS (Glasgow Coma Scale), and Head-to-Toe (secondary survey with 7 body regions). Only one sub-tab is visible at a time; switching is handled by _switch_exam_sub().
**Status:** Implemented

### Sub-Tab UI (Stabilize 3 Tabs)
**Parent:** Treatment System
**Files:** `scripts/ui/patient_interaction_ui.gd` (_stab_sub_tabs, _stab_sub_tab_btns, _switch_stab_sub)
**Description:** The Stabilize tab contains 3 internal sub-tabs: Equipment (deploy from medical bag), Drugs (administer medications with route/dose selection), and CPR/AED (cardiac arrest interventions). Equipment and drug sub-tabs are dynamically populated based on the active bag tier.
**Status:** Implemented

### ECG Rhythm Display and Identify Button
**Parent:** Patient Assessment
**Files:** `scripts/medical/ecg_rhythm_manager.gd`, `scripts/ui/patient_interaction_ui.gd` (_ecg_panel, _ecg_texture_rect)
**Description:** ECG rhythm images are loaded from `assets/textures/ecg/` via configurable paths in `data/ecg_rhythms.json`. Two modes: AED mode (auto-analysis recommending shock for VFib/VTach) and Monitor mode (manual identification quiz). An "Identify Rhythm" button presents all rhythm options and records the player's selection for scoring.
**Status:** Implemented

### GCS 3-Component Assessment
**Parent:** Patient Assessment
**Files:** `scripts/medical/gcs_assessment_manager.gd`, `scripts/ui/patient_interaction_ui.gd` (_gcs_component_selection, _gcs_component_btns)
**Description:** Standard 3-component GCS scoring (Eye 1-4, Verbal 1-5, Motor 1-6) with severity classification (Mild/Moderate/Severe) and AVPU equivalent mapping. GCS <= 8 triggers an airway protection warning. Each component has descriptive text for all response levels.
**Status:** Implemented

### Secondary Survey (Head-to-Toe)
**Parent:** Patient Assessment
**Files:** `scripts/medical/secondary_survey_manager.gd`, `scripts/ui/patient_interaction_ui.gd` (_secondary_buttons, _secondary_results)
**Description:** Seven body regions examined in order (head, neck, chest, abdomen, pelvis, back, extremities). Gated behind primary survey completion. Findings loaded from scenario JSON with critical keyword detection (fracture, pneumothorax, displaced, etc.). Bilingual -- loads Thai findings when locale is "th". Progress counter shows regions examined vs. total.
**Status:** Implemented

### Vital Sign Assessment
**Parent:** Patient Assessment
**Files:** `scripts/ui/patient_interaction_ui.gd` (_vital_buttons, _vital_results), `scripts/medical/medical_state_component.gd`
**Description:** Individual assessment buttons for heart rate, blood pressure (systolic/diastolic), respiratory rate, SpO2, temperature, blood glucose, capillary refill, and pupil examination (size and reactivity per eye). Each has a 1.5-second cooldown with 2 concurrent assessments allowed. Results read from MedicalStateComponent properties.
**Status:** Implemented

---

## Treatment Sub-Features

### Medical Bag BLS/ALS Tiers
**Parent:** Treatment System
**Files:** `scripts/medical/medical_bag_tier_manager.gd`, `data/medical_bag_tiers.json`
**Description:** Two equipment tiers loaded from JSON. BLS includes 14 items across categories (Airway, Bleeding Control, Immobilization, Monitoring, Resuscitation). ALS adds cardiac drugs, IV supplies, and advanced airway equipment. Consumable items have quantity tracking and depletion signals. Tier is set per-scenario by ScenarioManager.
**Status:** Implemented

### Drug Route and Dosage Selection
**Parent:** Treatment System
**Files:** `scripts/medical/drug_administration_manager.gd`, `scripts/ui/patient_interaction_ui.gd`, `data/drugs.json`
**Description:** Full pharmacological database with per-drug valid routes (IV, IO, IM, SC, nebulised, sublingual), dose options (e.g., Adrenaline 1mg or 0.3mg), and maximum dose limits. UI presents route dropdown and dose selection buttons. IV/IO routes require prior IV_ACCESS deployment. 7-category medication error classification with telemetry logging.
**Status:** Implemented

### Atropine Auto-Update Rhythm
**Parent:** Treatment System
**Files:** `scripts/medical/medical_state_component.gd` (set_modifier, heart_rate case)
**Description:** When Atropine is administered (effect: heart_rate +20), the ECG rhythm automatically updates based on the new heart rate. Sinus rhythms auto-transition: HR < 60 = SINUS_BRADYCARDIA, HR 60-100 = NORMAL_SINUS, HR > 100 = SINUS_TACHYCARDIA, HR 0 = ASYSTOLE. VFib/VTach rhythms are excluded from auto-update to preserve explicit state transitions.
**Status:** Implemented

### CPR and AED Mechanics
**Parent:** Treatment System
**Files:** `scripts/medical/medical_state_component.gd` (apply_treatment)
**Description:** CPR resets the cardiac_to_dead timer in DeteriorationSystem but does not trigger ROSC. AED checks shockable rhythms (VFib/VTach): if shockable, triggers ROSC with post-resuscitation vitals and 70% deterioration rate reduction. Non-shockable rhythms (Asystole, PEA) result in "No shock advised". Post-treatment deterioration slowdown stacks at 20% multiplicatively per effective treatment.
**Status:** Implemented

### ROSC Logic
**Parent:** Treatment System
**Files:** `scripts/medical/medical_state_component.gd` (apply_treatment, "aed" case)
**Description:** Return of Spontaneous Circulation transitions patient from CARDIAC_ARREST to UNCONSCIOUS with specific vitals (HR 50, BP 80, SpO2 88%, rhythm SINUS_BRADYCARDIA, pulse restored). Resets deterioration budget to phase 2 and reduces deterioration rate by 70% (multiplied by 0.3). Only triggered by AED on shockable rhythms.
**Status:** Implemented

### Equipment Deployment Tracking
**Parent:** Treatment System
**Files:** `scripts/medical/medical_bag_tier_manager.gd` (deploy_item), `scripts/ui/patient_interaction_ui.gd`
**Description:** When equipment is deployed to a patient, it is recorded in both the MedicalBagTierManager's internal tracking and the patient's metadata (`deployed_equipment` meta). This metadata is read by other systems -- ECGRhythmManager checks for AED attachment, IV access gating checks for IV_ACCESS, and telemetry records all deployments for scoring.
**Status:** Implemented

---

## AI System Sub-Features

### Patient Persona for AI Dialogue
**Parent:** AI System
**Files:** `scripts/medical/patient_persona.gd`, `scripts/ai/ollama/ollama_dialogue_client.gd` (_build_system_prompt)
**Description:** Each patient has a PatientPersona resource containing name, age, consciousness level, pain level (0-10), panic level (0.0-1.0), language clarity, and full SAMPLE history (Symptoms, Allergies, Medications, Past history, Last meal, Events) plus OPQRST data. The dialogue client builds a grounded system prompt from this data with strict rules: never fabricate symptoms, keep responses short, and respond in-character based on pain/panic levels.
**Status:** Implemented

### Ollama Auto-Discovery
**Parent:** AI System
**Files:** `scripts/ai/ollama/ollama_dialogue_client.gd` (_discover_ollama), `scripts/ai/reviewer/ollama_review_client.gd` (_discover_ollama)
**Description:** Both AI clients probe Ollama in parallel on startup. Candidate list: configured URL, localhost:11434, 127.0.0.1:11434, plus all local network IPv4 addresses. 3-second timeout per probe. First 200 response from /api/tags wins. Request queuing handles asks that arrive before discovery completes. Settings menu provides a Reconnect button for manual re-discovery.
**Status:** Implemented

### Cached AI Review Fallback (70 Files)
**Parent:** AI System
**Files:** `scripts/ai/reviewer/ai_demo_fallback.gd`, `data/prompts/cached_reviews/` (70 files)
**Description:** 35 English and 35 Thai pre-written AI review files across 6 scenarios (Tutorial, RTA, Cardiac Arrest, Building Fire single, Building Fire multi, MCI Market), each with 5 performance tiers (perfect/good/poor/catastrophic/empty). Tier is selected by overall score thresholds (90/60/30) and event count. Thai variants attempted first when locale is "th", with English fallback. Critical for competition demo without GPU.
**Status:** Implemented

### AI Review Language Injection
**Parent:** AI System
**Files:** `scripts/ai/reviewer/ollama_review_client.gd` (request_review)
**Description:** When the active locale begins with "th", the review client appends a Thai language instruction to the system prompt: "You MUST respond entirely in Thai. All section headers, feedback, and recommendations must be in Thai. Keep medical abbreviations (SpO2, HR, BP, GCS, CPR, AED, etc.) in English." English locale appends a simple "Respond in English" instruction.
**Status:** Implemented

---

## Triage Sub-Features

### START Triage Protocol
**Parent:** Triage System
**Files:** `scripts/medical/triage_system.gd`, `scripts/medical/medical_state_component.gd` (get_triage_priority)
**Description:** GREEN/YELLOW/RED/BLACK tag assignment with clinical priority computation from medical state. Once tagged, patients cannot be re-tagged. Correctness evaluation uses initial_triage_priority stored at spawn time (not end-of-scenario state). Triage summary computes accuracy for debrief.
**Status:** Implemented

### Triage Tag Visual
**Parent:** Triage System
**Files:** `scripts/ui/triage_tag_visual.gd`, `scripts/ui/patient_interaction_ui.gd`
**Description:** Visual indicator of assigned triage tag displayed on the patient interaction UI. Color-coded to match START triage colors. Shows both the assigned tag and correctness feedback in the debrief.
**Status:** Implemented

---

## Deterioration Sub-Features

### Two-Phase Budget Gate
**Parent:** Deterioration System
**Files:** `scripts/medical/deterioration_system.gd` (_budget_remaining, _in_phase2, _can_critical_transition)
**Description:** Phase 1 (pre-cardiac): 300s budget draining at 1x unfocused / 3.33x focused. Phase 2 (cardiac to death): 120s budget at 1x / 2x. Critical transitions (unconscious-to-cardiac, cardiac-to-dead) blocked until budget is zero. Budget resets on cardiac arrest entry.
**Status:** Implemented

### Idle Time Scaling for Unfocused Patients
**Parent:** Deterioration System
**Files:** `scripts/medical/deterioration_system.gd` (_process, idle_scale)
**Description:** When the player's mouse is captured (walking around, not in any patient UI), deterioration runs at 0.3x speed via an `idle_scale` multiplier. When the player has a patient's interaction UI open, deterioration runs at 1.0x. This prevents unfocused patients from dying unrealistically fast during multi-patient scenarios.
**Status:** Implemented

### Post-Treatment Deterioration Slowdown
**Parent:** Deterioration System
**Files:** `scripts/medical/medical_state_component.gd` (apply_treatment), `scripts/medical/deterioration_system.gd`
**Description:** Each effective treatment reduces deterioration_rate by 20% multiplicatively (rate *= 0.8, floor at 0.1). ROSC from AED applies an additional 70% reduction (rate *= 0.3). CPR resets cardiac timer but does not trigger rate reduction (handled separately). Effects stack across multiple treatments.
**Status:** Implemented

### Multi-Patient Budget Scaling
**Parent:** Deterioration System
**Files:** `scripts/core/scenario_manager.gd` (_spawn_entities, budget scaling block)
**Description:** For scenarios with more than 1 patient, deterioration budgets scale by `max(1.0, patient_count / 2.0)`. A 3-patient scenario gets 1.5x budget; a 6-patient MCI gets 3x. Applied to both phase1_budget and phase2_budget after entity spawning.
**Status:** Implemented

---

## Scenario Sub-Features

### Hazard Zones and EMT Incapacitation
**Parent:** Scenario System
**Files:** `scripts/gameplay/hazard_system.gd`, `scripts/gameplay/hazard_zone.gd`
**Description:** Environmental hazards (FIRE, COLLAPSE, TRAFFIC) spawned from scenario JSON with configurable radius, spread rate, max radius, and damage per second. FIRE hazards can spread over time. TRAFFIC hazards cycle between safe and dangerous states. Player hazard exposure time is tracked for telemetry/AI review. Extended exposure incapacitates the player and ends the scenario.
**Status:** Implemented

### Random Events System
**Parent:** Scenario System
**Files:** `scripts/gameplay/random_event_system.gd`
**Description:** Mid-scenario events triggered at randomised times within configured ranges (trigger_time_min to trigger_time_max). Three event types: NEW_PATIENT (spawns additional patient with full medical state and persona), EQUIPMENT_FAILURE (marks equipment as broken with [BROKEN] label), BYSTANDER (spawns interactable NPC with dialogue capability). Events are logged to telemetry.
**Status:** Implemented

### Scenario Timer with Minimum Time Guarantee
**Parent:** Scenario System
**Files:** `scripts/core/scenario_manager.gd` (load_scenario, _process)
**Description:** Configurable time limit per scenario with enforcement in _process(). A minimum time guarantee ensures at least 180 seconds per patient (e.g., 3 patients = minimum 540s). Time expiry is recorded to telemetry and triggers scenario end.
**Status:** Implemented

### Scene Variation
**Parent:** Scenario System
**Files:** `scripts/gameplay/scene_variation.gd`
**Description:** Support for visual variation of scenario environments. Environment scene is loaded from scenario JSON via `environment_scene_path` with async scene transition handling.
**Status:** Implemented

---

## UI Sub-Features

### Dark/Light Theme (ThemeMedical)
**Parent:** UI System
**Files:** `scripts/core/theme_medical.gd`, `scripts/core/theme_manager.gd`
**Description:** Centralized theme singleton providing dark and light color palettes with 20+ named colors each (bg_main, bg_card, accent_blue, accent_green, accent_red, text_primary, text_secondary, etc.). All UI components read from ThemeMedical via `c()` for colors and `style_*()` methods for consistent styling. Dark mode is default. Theme preference persists to `user://theme_config.json`. Emits `theme_changed` signal for live re-styling.
**Status:** Implemented

### Settings Menu (5 Cards)
**Parent:** UI System
**Files:** `scripts/ui/settings_menu.gd`
**Description:** Card-based settings panel with 5 sections: Appearance (dark/light toggle with accent bar), Language (TH/EN toggle with description), Audio (master/music/SFX volume sliders with percentage labels), AI Configuration (Ollama status dot with green/red indicator, model name, URL, reconnect button with 15s polling), and About (version, description, copyright). Settings persist to `user://settings.json`, AI config from `user://ai_config.json`.
**Status:** Implemented

### Radar Chart
**Parent:** Dashboard
**Files:** `scripts/ui/radar_chart.gd`
**Description:** Custom Control that draws a 5-axis radar polygon for visualizing performance scores. Used in the Dashboard Scenario Breakdown tab. Axes correspond to the 5 scoring dimensions (Triage Speed, Protocol Accuracy, Decision Quality, Equipment Handling, Patient Outcome).
**Status:** Implemented

### Data Export (CSV/JSON)
**Parent:** Dashboard
**Files:** `scripts/dashboard/data_exporter.gd`
**Description:** Export performance history as CSV (with headers: Date, Scenario ID, 5 axis scores, Overall, Pass/Fail, AI Review Summary) or JSON (includes per-scenario summaries, best scores, and trend data). Supports file dialog selection and quick-export to `user://exports/`. Integrates with HistoryManager for data retrieval.
**Status:** Implemented

### History Tracking and Trends
**Parent:** Dashboard
**Files:** `scripts/dashboard/history_manager.gd`
**Description:** Persists session scores as individual JSON files in `user://history/`. Provides per-scenario history retrieval, best score lookup, and improvement trend detection (IMPROVING/DECLINING/STABLE using 5-session window comparison with 3% delta threshold). Automatic pruning at 100 sessions per scenario.
**Status:** Implemented

---

## Localization Sub-Features

### Bilingual TH/EN with TranslationServer
**Parent:** Localization System
**Files:** `scripts/core/localisation_manager.gd`, `data/translations/translations.csv`
**Description:** CSV-based translation system with ~360 keys registered with Godot's TranslationServer at startup. Toggle between Thai and English via `toggle_locale()`. Emits `locale_changed` signal for UI refresh. Locale persists across sessions via settings.json.
**Status:** Implemented

### Thai Cached AI Reviews
**Parent:** Localization System
**Files:** `scripts/ai/reviewer/ai_demo_fallback.gd`, `data/prompts/cached_reviews/` (35 `_th.txt` files)
**Description:** 35 Thai translations of cached AI review files with medical abbreviations preserved in English. Locale-aware loading: `try_serve_cached()` checks TranslationServer locale and attempts Thai variant first, with English fallback if Thai file not found.
**Status:** Implemented

---

## Telemetry Sub-Features

### Protocol Adherence Tracking
**Parent:** Telemetry
**Files:** `scripts/telemetry/protocol_adherence_tracker.gd`
**Description:** Analyses session telemetry to compute protocol adherence metrics: correct steps, missed steps, wrong-order steps, timing data (time to first assessment, first triage, first treatment), and per-patient protocol reports. Used by ScoringEngine for Protocol Accuracy axis.
**Status:** Implemented

### Error Detection
**Parent:** Telemetry
**Files:** `scripts/telemetry/error_detector.gd`
**Description:** Detects clinical errors from telemetry events: WRONG_PRIORITY, WRONG_TRIAGE, SKIPPED_ASSESSMENT, WRONG_EQUIPMENT. Each error includes type, severity (CRITICAL/WARNING), and description. Feeds into ScoringEngine Decision Quality and Equipment Handling axes.
**Status:** Implemented

### Telemetry Collection
**Parent:** Telemetry
**Files:** `scripts/telemetry/telemetry_collector.gd`, `scripts/telemetry/telemetry_emitter.gd`
**Description:** TelemetryCollector (autoload) records all gameplay events with timestamps and player position. TelemetryEmitter (attached to player) provides `emit_action()` for event logging. Session data includes events, duration, and is consumed by ScoringEngine, AI Reviewer, and HistoryManager.
**Status:** Implemented
