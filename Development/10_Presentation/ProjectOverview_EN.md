# AeroMedica: Protocol Playground — Project Overview

## What Is AeroMedica?

AeroMedica: Protocol Playground is a 3D isometric emergency medical training simulation built with Godot 4.6. Players take on the role of an Emergency Medical Technician (EMT) and assess, treat, and triage patients using real-world emergency medical protocols — entirely offline.

The project was developed for the **Thailand Metaverse Hackathon and Exhibition 2026** (Medical Track) by **Team Ollama Paramedic**.

---

## The Problem

Emergency medical skills degrade rapidly after training:

- **61% skill loss** within 2 years of certification (Stept & Stross, 1980, *Annals of Emergency Medicine*)
- **ACLS pass rates drop to 14%** at 12 months post-certification (Smith et al., 2008)

Traditional simulation drills are expensive (mannequins, venue, instructors), infrequent (a few times per year), and non-repeatable (you can't practice the same scenario twice). Medical personnel lose critical skills before they ever need them in the field.

**What's needed:** A tool that allows unlimited, repeatable practice of emergency protocols — without external dependencies.

---

## The Solution

AeroMedica provides a complete EMT training workflow in a single offline application:

### Patient Assessment
- **DRSABCDE Primary Survey** — 8-step assessment with action cooldowns preventing button spam
- **Vital Signs** — 8 values (HR, BP, SpO2, Temperature, Blood Glucose, Capillary Refill, Pupils, Skin) requiring equipment deployment before readings
- **ECG Display** — 7 cardiac rhythms with strip images and rhythm identification
- **GCS Assessment** — Eye (4), Verbal (5), Motor (6) scoring with auto-read from patient data
- **Head-to-Toe Examination** — 7 body regions with 3-tier severity markers (red = critical, yellow = abnormal, green = normal), bilingual Thai/English
- **SAMPLE/OPQRST History** — Patient interview powered by offline AI (Ollama) or scripted fallback

### Treatment
- **Medical Bag** — BLS and ALS tiers with consumable tracking and limited quantities
- **Drug Administration** — Select drug, dose, and route with full telemetry logging and patient state context
- **CPR + AED** — CPR gated behind pulse assessment, AED auto-checks shockable rhythm, ROSC logic with 70% conversion rate for VFib
- **Atropine Response** — Auto-updates rhythm from Sinus Bradycardia to Normal Sinus (clinically accurate)

### Triage & Diagnosis
- **START Triage** — GREEN (Minor), YELLOW (Delayed), RED (Immediate), BLACK (Expectant/Deceased)
- **Differential Diagnosis** — 47 conditions across 6 categories with search and bilingual labels

---

## Scenarios

Five playable scenarios with progressive difficulty:

| Scenario | Patients | Time Limit | Difficulty | Special Mechanic |
|----------|----------|-----------|------------|-----------------|
| Tutorial | 1 | Unlimited | 1/5 | Learning mode — no time pressure |
| Road Traffic Accident | 3 | 10 min | 2/5 | Multi-patient triage prioritization |
| Cardiac Arrest | 1 | 5 min | 3/5 | CPR + AED + ROSC — focused resuscitation |
| Building Fire | 3 | 8 min | 4/5 | Hazard zones — fire damages EMT (15s = incapacitated) |
| Mass Casualty Incident | 6 (+1 random) | 15 min | 5/5 | START Triage under extreme pressure, 2.5x equipment scaling |

### Patient Deterioration
Patients deteriorate in real-time through 4 states: **CONSCIOUS → UNCONSCIOUS → CARDIAC_ARREST → DEAD**. Each patient has individual deterioration timers. Effective treatment slows deterioration by 20% per intervention (stacks multiplicatively). Untreated patients will die.

---

## AI System

### Ollama (llama3.1:8b) — Fully Offline
- **Patient Dialogue:** AI responds as the patient, grounded in that patient's medical data (name, age, symptoms, history, medications). Each patient has a unique PatientPersona.
- **AI Reviewer:** After each scenario, AI analyzes the full telemetry log — assessment sequence, drug choices, timing, patient states — and generates detailed feedback in Thai or English.
- **Auto-Discovery:** The game probes localhost, 127.0.0.1, and all LAN IPs on port 11434 to find Ollama automatically. No configuration needed.

### Cached Fallback
When Ollama is unavailable (insufficient hardware, not installed):
- Patient dialogue falls back to scripted responses from scenario data
- AI Review falls back to **70 cached reviews** (7 scenarios x 5 performance tiers x 2 languages)
- All gameplay systems (scoring, triage, deterioration, equipment) function identically
- A popup informs the player of fallback mode on startup

---

## Scoring & Debrief

### 5-Axis Scoring Engine
| Axis | What It Measures |
|------|-----------------|
| Triage Speed | Time to first triage tag — full marks under 60 seconds |
| Protocol Accuracy | Player's action sequence compared against correct DRSABCDE protocol |
| Decision Quality | Triage tag correctness + differential diagnosis accuracy |
| Equipment Handling | Appropriate equipment selection for patient condition |
| Patient Outcome | Final patient state compared to initial presentation |

### Debrief Screen
- Per-patient outcome cards with triage color borders
- Correct diagnosis displayed per patient
- 5-axis radar chart for visual strength/weakness identification
- AI-generated natural language review (or cached equivalent)

### Dashboard
- **Tab 1: My Performance** — Overall stats, score trends over time, best/worst axes
- **Tab 2: Scenario Breakdown** — Per-scenario radar charts and history
- **Data Export:** CSV and JSON export for institutional analysis

---

## Technical Details

| Component | Technology | Why |
|-----------|-----------|-----|
| Game Engine | Godot 4.6 (GDScript) | Open-source, cross-platform, lightweight |
| AI | Ollama (llama3.1:8b) | Offline, local, no cloud dependency |
| Data | JSON | Human-readable, easy scenario authoring |
| Localization | TranslationServer + CSV | 300+ keys, instant TH/EN switching |
| 3D Assets | Kenney Low-Poly kits | CC0 licensed, consistent art style |
| Theme | ThemeMedical singleton | Dark navy medical-professional UI |
| Physics | Jolt Physics | Godot 4.6 default |

### Architecture (6 Layers)
1. **Scene Layer** — Tutorial, RTA, Cardiac, MCI, Building Fire
2. **UI Layer** — PatientInteractionUI (4 tabs + sub-tabs), Debrief, Dashboard
3. **Manager Layer** — GameManager, ScenarioManager, TelemetryCollector, HistoryManager, ThemeMedical
4. **Medical Layer** — MedicalStateComponent, AssessmentManager, DeteriorationSystem, TriageSystem, DrugAdminManager
5. **AI Layer** — OllamaDialogueClient, OllamaReviewClient, AIDemoFallback
6. **Data Layer** — 7 scenario JSONs, drugs.json, ecg_rhythms.json, translations.csv, cached_reviews.json

**13 Autoload Singletons** manage global state across all scenes.

---

## Business Model

**Target:** B2B — EMT training institutions, hospitals, medical schools, EMS agencies.

**Value Proposition:**
- **Zero infrastructure cost** — no server, no subscription, no recurring fees
- **Data stays on-premises** — no student data leaves the building, privacy compliant
- **Unlimited practice** — students can repeat any scenario as many times as needed
- **Bilingual** — Thai and English with instant switching
- **No internet required** — runs entirely offline

---

## Development

- **Period:** 7-31 March 2026 (25 days)
- **Sessions:** 86 logged development sessions
- **Methodology:** Agile Iterative, Phase-based (9 phases), Ticket-driven
- **Bugs Fixed:** 22+
- **Documentation:** Full development log, bug reports, modification logs, feature descriptions, test plans

### AI Tools Used in Development (Transparent Disclosure)
1. **Ollama (llama3.1:8b)** — In-game AI: patient dialogue and performance review
2. **Claude Opus 4.6** — Code writing assistant and documentation. Team decides architecture, design, and every decision point. Claude accelerates writing and review.
3. **Google Gemini 3 Pro** — Brainstorming and visual media: banner image, poster draft
4. All AI output was reviewed and edited by the team before use.

---

## Future Roadmap

### v1.1 — Instructor Web Dashboard (Approved)
- FastAPI + SQLite + WebSocket server
- Browser-based dashboard for instructors on the same LAN
- Real-time student monitoring: who is playing what, live scores, struggle alerts
- Offline telemetry queue when server is down
- 8 implementation tickets written and approved

### v2.0 — Advanced Features (Mentor Recommended)
- **Step-Up Timer:** Unvisited patients deteriorate faster over time, forcing real triage decisions
- **Adverse Drug Effects:** Wrong drug/dose triggers observable negative patient effects
- **AED Manual Rhythm Recognition:** Player identifies rhythm before shocking
- **Simplified Mode:** Reduced medical terminology for non-medical users

### Scenario Expansion
- JSON-driven system allows new scenarios without code changes
- Institutions can customize patient data, difficulty, equipment, and drug databases

---

## Downloads

- **Google Drive (Play):** https://drive.google.com/drive/folders/1rnqWkEMZtg3yYKeX9cIhGl3SZArkfGsf?usp=sharing
- **GitHub (Source):** https://github.com/xMartin14091x/aero-medica (branch: ui-revamp-v2)
