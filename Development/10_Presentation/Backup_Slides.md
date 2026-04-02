# AeroMedica — Backup Slides (Q&A Preparation)

**Purpose:** These slides are NOT presented during the pitch. They are prepared in advance and shown only when judges ask the corresponding question. Having these ready shows thorough preparation and avoids improvised answers.

**How to use:** Keep these as hidden/appendix slides after the closing slide. When a judge asks a question, navigate directly to the relevant backup slide.

---

## B1 — Medical Accuracy: How Is It Verified?

**Anticipates:** "How do you ensure the medical protocols are correct?" / "Who verified the clinical data?"

### Visual
Table: verification method per data type

### Content

**Clinical Consultation Process:**
All patient data — vital signs, examination findings, correct diagnoses, drug dosages, protocol sequences — are verified through a clinical reference consultation process.

**What was verified:**

| Data Type | Verification Method |
|-----------|-------------------|
| Per-patient vital signs (HR, BP, SpO2, etc.) | Cross-checked against clinical presentation and triage category |
| Examination findings (Head-to-Toe) | Reviewed for anatomical accuracy, appropriate severity markers |
| Correct diagnosis per patient | Validated against presenting signs/symptoms |
| Drug dosages and routes | Compared against ACLS 2020 guidelines and EMS protocols |
| CPR/AED/ROSC logic | Verified: pulse gate, shockable rhythm detection, 70% ROSC rate for VFib |
| ACLS protocol points | Amiodarone doesn't convert VFib (only AED does), Atropine removed from arrest algorithm (AHA 2010), post-ROSC uses infusions not boluses |
| Deterioration timers | Clinically proportional: GREEN patients deteriorate very slowly, RED patients have minutes |

**Specific ACLS verifications performed:**
1. Amiodarone: correctly does NOT convert VFib/pVT — only AED shock converts
2. Atropine: flagged as ineffective for cardiac arrest (removed from ACLS 2010)
3. Post-ROSC: drug options switch to infusion-based dosing, not bolus

**Severity Marker System:**
- RED triangle = critical finding requiring immediate intervention
- YELLOW lightning = abnormal finding, monitor/treat soon
- No marker = normal finding
- ~216 individual findings tagged across all patients

---

## B2 — Technical Architecture

**Anticipates:** "What technology did you use?" / "How is the system structured?"

### Visual
6-layer architecture diagram

### Content

**6-Layer Architecture:**

| Layer | Components | Purpose |
|-------|-----------|---------|
| Scene | Tutorial, RTA, Cardiac, MCI, Building Fire | Playable 3D environments |
| UI | PatientInteractionUI (4 tabs + sub-tabs), Debrief, Dashboard | Player interface |
| Manager | GameManager, ScenarioManager, TelemetryCollector, HistoryManager, ThemeMedical | State and lifecycle |
| Medical | MedicalStateComponent, AssessmentManager, DeteriorationSystem, TriageSystem, DrugAdminManager | Clinical simulation |
| AI | OllamaDialogueClient, OllamaReviewClient, AIDemoFallback | AI dialogue + review |
| Data | 7 scenario JSONs, drugs.json, ecg_rhythms.json, translations.csv, cached_reviews.json | Game data |

**Tech Stack:**

| Component | Technology | Why |
|-----------|-----------|-----|
| Engine | Godot 4.6 (GDScript) | Open-source, cross-platform, lightweight |
| AI | Ollama (llama3.1:8b) | Offline, local, no cloud dependency |
| Data | JSON | Human-readable, easy to author new scenarios |
| Localization | TranslationServer + CSV | 300+ keys, instant language switching |
| 3D Assets | Kenney Low-Poly kits | CC0 licensed, consistent art style |
| Theme | ThemeMedical singleton | Dark navy palette, medical-professional aesthetic |
| Physics | Jolt Physics | Godot 4.6 default, reliable 3D physics |

**13 Autoload Singletons:** GameManager, LocalisationManager, TelemetryCollector, ScenarioManager, OllamaReviewClient, OllamaDialogueClient, ECGRhythmManager, GCSAssessmentManager, SecondarySurveyManager, TriageSystem, ThemeMedical, AIDemoFallback, HistoryManager

---

## B3 — Scenario Details

**Anticipates:** "Tell me more about the scenarios" / "How many patients?" / "What's different about each one?"

### Visual
Scenario comparison table with screenshots

### Content

| Scenario | Patients | Time | Difficulty | Bag Tier | Special Mechanic |
|----------|----------|------|-----------|----------|-----------------|
| Tutorial | 1 (Somchai, 28M) | Unlimited | 1/5 | BLS | Learning mode — no time pressure |
| RTA | 3 (Somchai, Nanthida, Prasert) | 10 min | 2/5 | ALS | Multi-patient triage prioritization |
| Cardiac | 1 (Wichai, 55M) | 5 min | 3/5 | ALS | CPR + AED + ROSC — focused resuscitation |
| Building Fire | 3 patients | 8 min | 4/5 | ALS | Hazard zones — fire damages EMT (15s = incapacitated) |
| MCI | 6 + 1 random event | 15 min | 5/5 | ALS (2.5x equipment) | START Triage under extreme pressure, resource scarcity |

**Patient Deterioration System:**
- 4 states: CONSCIOUS → UNCONSCIOUS → CARDIAC_ARREST → DEAD
- Configurable transition timers per patient (e.g., Somchai a→u: 240s, Prasert u→c: 240s)
- Post-treatment slowdown: each effective treatment reduces deterioration 20% (stacks multiplicatively)
- Idle scaling: unfocused patients deteriorate at 0.3x rate
- Hazard zone boost: 25% faster deterioration in fire zones

**MCI Random Event:**
- Between 5-8 minutes, a 7th patient (Anong, 19F) arrives at the scene
- Player must reassess triage priorities with limited remaining equipment
- Tests adaptability under changing conditions

---

## B4 — What Happens Without Ollama?

**Anticipates:** "What if the computer can't run AI?" / "Does it work on low-spec machines?"

### Visual
Flowchart: Ollama check → available/unavailable → two paths

### Content

**The game works identically without Ollama. Here's what changes:**

| Feature | With Ollama | Without Ollama |
|---------|------------|----------------|
| Patient Dialogue | AI-generated natural responses based on PatientPersona | Scripted responses from scenario JSON data |
| Performance Review | AI analyzes full telemetry, generates unique feedback | Cached pre-written review matched by scenario + performance tier |
| Review Quality | Unique per session, references specific actions | Generic per tier (perfect/good/poor/catastrophic/empty) |
| Languages | Thai or English (player choice) | Same — cached reviews exist in both languages |

**Cached Review System:**
- 70 pre-written reviews stored in `cached_reviews.json`
- 7 scenarios x 5 performance tiers x 2 languages = 70 entries
- Tier selection based on overall score: 80%+ = perfect, 60-79% = good, 40-59% = poor, 1-39% = catastrophic, 0% = empty
- Reviews are authored to give actionable medical feedback, not generic praise

**Auto-Discovery Process:**
1. Game probes `http://localhost:11434` on startup
2. If no response, probes `http://127.0.0.1:11434`
3. If still no response, scans all local IPv4 addresses on port 11434
4. Timeout: 4 seconds total
5. If nothing found: popup informs player, switches to cached mode
6. Settings > AI > "Reconnect" button to retry at any time

**System Requirements:**
- Game only (no AI): Any Windows 10/11 PC
- Game + AI: Recommend 8GB+ RAM for Ollama to load llama3.1:8b
- Ollama runs as a separate background service — can be on same machine or another LAN machine

---

## B5 — Development Process

**Anticipates:** "How did you build this in 25 days?" / "What was your development process?"

### Visual
Phase timeline + session count per phase

### Content

**Development Stats:**
- **Period:** 7-31 March 2026 (25 days)
- **Sessions:** 86 logged sessions
- **Bugs Fixed:** 22+
- **Phases:** 9 (Phase 0 through Phase 8)

**Phase Breakdown:**

| Phase | Dates | Focus | Sessions |
|-------|-------|-------|----------|
| 0 | 7-8 Mar | Infrastructure: Godot project, GameManager, Camera, Player, HUD | ~4 |
| 1 | 9-10 Mar | Core Gameplay: Patient entity, Scenario loader, Interaction, Assessment | ~6 |
| 2 | 11-12 Mar | Medical Protocol: State machine, Deterioration, Triage, Timer | ~6 |
| 3 | 13-14 Mar | AI Pipeline: Telemetry, Protocol adherence, Ollama review, Parser | ~6 |
| 4 | 15-16 Mar | Dynamic Environment: Hazard zones, Random events, Scene variation | ~6 |
| 5 | 17-18 Mar | Advanced UI: 4-tab Patient UI, ECG, GCS, Drug admin, Medical bag | ~8 |
| 6 | 19-20 Mar | Scoring: Dashboard, Radar chart, Performance tracking, History | ~6 |
| 7 | 21-22 Mar | Bug Fixing: 22 bugs fixed, E2E testing every scenario | ~10 |
| 8 | 23-31 Mar | Polish: UI revamp v2.0, Bilingual, Cached reviews, Cooldown, 3D assets | ~34 |

**Development Methodology:**
- Agile Iterative, Phase-based
- Ticket-driven: every code change requires a ticket before implementation
- Every session documented in Development Log
- Parallel execution across sub-teams
- E2E testing per phase before advancing

**AI Tools Used in Development (Transparent Disclosure):**
1. **Ollama (llama3.1:8b):** In-game AI — patient dialogue + performance review
2. **Claude Opus 4.6:** Code writing assistant + documentation — team decides architecture, design, every decision point
3. **Google Gemini 3 Pro:** Brainstorming + visual media — banner image, poster draft
4. All AI output reviewed and edited by team before use

---

## B6 — Future Roadmap

**Anticipates:** "What's next?" / "Will you continue developing this?"

### Visual
Roadmap: v1.0 (now) → v1.1 (Instructor Dashboard) → v2.0 (Advanced Features)

### Content

**v1.1 — Instructor Web Dashboard (Approved, Ready to Implement)**
- **Tech:** FastAPI + SQLite + WebSocket server
- **How it works:** Godot game sends telemetry to local server via HTTP. Instructor opens browser on any device on the same LAN. Dashboard shows:
  - Which student is playing which scenario
  - Live score progression
  - Alerts when student is struggling (low scores, patient deaths)
  - Historical performance per student
- **Offline queue:** If server is down, telemetry queued in `user://pending_telemetry/` and sent when reconnected
- **8 implementation tickets already written**

**v2.0 — Advanced Features (Mentor Recommended)**
- **Step-Up Timer:** Unvisited patients deteriorate 1.5x faster, increasing by 0.25x every 60 seconds. Forces real triage prioritization.
- **Adverse Drug Effects:** Wrong drug/dose triggers observable negative effects (HR spike, BP drop, new arrhythmia). Teaches consequences.
- **AED Manual Rhythm Recognition:** Player must identify rhythm from ECG strip before shocking, instead of auto-detection.
- **Simplified Mode:** Reduced medical terminology, guided prompts, separate scoring — for non-medical users
- **Action Cooldown Queue:** Instead of rejecting concurrent actions, queue them with position indicator

**Scenario Expansion:**
- JSON-driven system means new scenarios can be authored without code changes
- Add new conditions, new patient profiles, new hazard types by editing JSON files
- Community scenario authoring possible

---

## B7 — Competitive Differentiation

**Anticipates:** "What makes you different from other medical training tools?" / "How do you compare to existing solutions?"

### Visual
Comparison table

### Content

| Feature | AeroMedica | Traditional Simulation | Online Courses | VR Training |
|---------|-----------|----------------------|----------------|-------------|
| **Cost** | Free (open source) | High (mannequins, venue) | Subscription | High (VR headsets) |
| **Offline** | 100% | Yes | No | Mostly no |
| **Repeatable** | Unlimited, same scenario | Limited by scheduling | Yes but passive | Yes |
| **Active Practice** | Full hands-on protocol | Full hands-on | Passive (read/watch) | Full hands-on |
| **AI Feedback** | Per-session, specific | Instructor-dependent | Generic quiz scores | Varies |
| **Setup Time** | Download and run | Hours (setup mannequins) | Account creation | Calibration |
| **Data Privacy** | Local only | N/A | Cloud-dependent | Cloud-dependent |
| **Bilingual** | Thai + English | Instructor language | Usually English | Varies |
| **Hardware** | Any PC | Specialized equipment | Any device | VR headset required |
| **Protocol Coverage** | Full DRSABCDE + ACLS | Scenario-dependent | Topic-dependent | Scenario-dependent |

**Key Differentiators:**
1. **Offline-first with AI** — no other solution combines local AI with zero cloud dependency
2. **Full protocol coverage** — from DRSABCDE to DDx in a single integrated experience
3. **5-axis quantitative scoring** — not just pass/fail, but detailed breakdown of performance dimensions
4. **Zero infrastructure cost** — no server, no subscription, no recurring fees for institutions
5. **Bilingual Thai/English** — switches instantly, medical terminology accurate in both languages

---

## B8 — Scalability & Extensibility

**Anticipates:** "Can you add more scenarios?" / "Can other institutions customize it?"

### Visual
JSON example + "add a scenario" flow

### Content

**JSON-Driven Design:**
Every scenario is defined by a single JSON file containing:
- Patient definitions (persona, vitals, examination findings, history, correct diagnosis)
- Deterioration parameters per patient
- Equipment tier (BLS/ALS) and multiplier
- Time limits and difficulty rating
- Random events (new patients arriving mid-scenario)
- Correct protocol sequences for scoring

**Adding a New Scenario:**
1. Create a new JSON file in `data/scenarios/`
2. Define patients with all clinical data
3. Add the scenario to the scenario select screen array
4. No GDScript code changes required for standard scenarios

**Customization Options for Institutions:**
- Modify existing patient data (change vitals, findings, diagnoses)
- Adjust difficulty (deterioration rates, time limits)
- Add institution-specific scenarios (local disaster types, common call types)
- Change equipment quantities (multiplier field)
- Modify drug database (`drugs.json`)
- Add translations for additional languages (CSV-based)

**Current Scale:**
- 7 scenario JSON files (5 active + 2 variants)
- 14 unique patients with full clinical data
- 47 differential diagnosis conditions
- 24+ BLS items + 17 ALS items in medical bag
- 7 ECG rhythms with strip images
- 300+ translation keys (TH/EN)
