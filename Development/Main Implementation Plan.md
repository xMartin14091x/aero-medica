# AeroMedica — Main Implementation Plan

**Project:** AeroMedica
**Theme:** Metaverse for Society — Play to Learn (2026 Competition)
**Engine:** Godot 4.x (GDScript)
**Status:** IMPLEMENTED — Competition Build Ready
**Created:** 07-03-2026
**Last Updated:** 29-03-2026
**Development Sessions:** 66+ across 22 days (07-03 to 29-03-2026)

---

## Project Vision

AeroMedica is an isometric 3D medical emergency simulation game that transforms passive learning ("reading") into active practice ("playing") for EMT/first responder training. Players assume the role of an Emergency Medical Technician (EMT) who must assess, triage, and treat patients following BCLS/ALS protocols in chaotic, physics-driven emergency environments. An AI-driven stealth assessment system silently evaluates player behaviour and generates natural language performance reviews — proving that Metaverse-based training delivers measurable, standards-aligned skill improvement.

---

## Core Pillars

1. **Immersive Education** — Replace static textbook learning with isometric 3D scenario-based practice
2. **Stealth Assessment** — AI (Ollama, local LLM) silently observes gameplay and generates narrative behavioural analysis using answer-sheet comparison, not just scores
3. **Measurable Mastery** — Movement patterns, decision timing, and protocol adherence are tracked and scored as clinical skill metrics
4. **B2B2C Scalability** — Design for institutional deployment (Ministry of Public Health, hospitals, EMT training centres)

---

## Feature Breakdown

### F1. Isometric Game World
The core 3D environment rendered in isometric/orthographic camera view. Resource-light visual style focused on clarity and gameplay over high-fidelity graphics.

- [ ] **F1.1 — Isometric Camera System**: Fixed orthographic camera with smooth follow, optional zoom, rotation lock
- [ ] **F1.2 — Tile/Grid-Based Level Design**: Modular environment tiles (road, sidewalk, building interior, grass) for rapid scenario construction
- [ ] **F1.3 — Environment Art Style**: Low-poly or stylised aesthetic — clear visual hierarchy, distinct interactable objects
- [ ] **F1.4 — Lighting & Atmosphere**: Time-of-day presets (day, night, rain) to vary scenario conditions

### F2. Player Controller & Interaction
The EMT player character and all interaction mechanics in isometric space.

- [ ] **F2.1 — Player Movement**: Click-to-move or WASD isometric movement with pathfinding (NavigationAgent3D)
- [ ] **F2.2 — Object Interaction System**: Proximity-based interaction prompts (press E / click to interact with patients, equipment, doors)
- [ ] **F2.3 — Equipment Inventory**: Pickup, carry, and use medical equipment (AED, bandages, splints, oxygen mask, stretcher)
- [ ] **F2.4 — Patient Interaction**: Approach patient → assess (check pulse, breathing, consciousness) → apply treatment sequence
- [ ] **F2.5 — Contextual Action Menu**: Radial or list menu appearing near patient for protocol-correct action selection (e.g., "Check Airway", "Apply Pressure", "Call for Backup")

### F3. Medical Scenario System
The framework for loading, running, and completing discrete emergency scenarios.

- [ ] **F3.1 — Scenario Data Format**: JSON/Resource-based scenario definitions (patient count, conditions, environment type, time limit, correct protocol sequence)
- [ ] **F3.2 — Scenario Loader**: Parse scenario data → spawn patients, equipment, environmental hazards at defined positions
- [ ] **F3.3 — Patient Entity**: NPC with medical state machine (conscious/unconscious, breathing/not breathing, bleeding severity, cardiac status)
- [ ] **F3.4 — Triage Tags (START Protocol)**: Colour-coded triage classification (Green/Yellow/Red/Black) — player must assign correct tag
- [ ] **F3.5 — Time Pressure System**: Scenario clock + patient condition deterioration over time (delayed treatment = worsening state)
- [ ] **F3.6 — Scenario Completion & Debrief**: End-of-scenario summary screen → transitions to AI review

### F4. Dynamic Environment & Physics
Unpredictable elements that force adaptive decision-making.

- [ ] **F4.1 — Environmental Hazards**: Fire spread, structural collapse zones, traffic — areas the player must navigate around or secure
- [ ] **F4.2 — Random Events**: Mid-scenario triggers (new patient arrives, equipment breaks, bystander interference)
- [ ] **F4.3 — Physics Interactions**: Movable debris, openable doors, draggable stretchers — lightweight RigidBody3D interactions
- [ ] **F4.4 — Scene Variation**: Same scenario template with randomised patient positions, conditions, and hazard placements for replayability

### F5. Telemetry & Data Collection (Stealth Assessment Core)
The hidden data layer that records everything the player does — the raw input for the AI reviewer.

- [ ] **F5.1 — Movement Telemetry**: Record player position every N seconds → heatmap of movement patterns, time spent in zones
- [ ] **F5.2 — Decision Event Log**: Timestamped log of every action (equipment picked up, patient assessed, triage tag assigned, treatment applied)
- [ ] **F5.3 — Timing Metrics**: Time-to-first-patient, time-to-triage, time-to-treatment, total scenario duration
- [ ] **F5.4 — Protocol Adherence Tracker**: Compare player's action sequence against the gold-standard BCLS/ALS protocol for each patient
- [ ] **F5.5 — Error Tracker**: Log incorrect actions (wrong triage tag, skipped assessment step, treated lower-priority patient first)
- [ ] **F5.6 — Session Data Export**: Package all telemetry into a structured JSON payload for the AI reviewer

### F6. AI-Driven Triage Reviewer
The centrepiece feature — Ollama (local LLM) analyses telemetry data against a protocol answer sheet and generates natural language performance review. Fully offline, zero cost.

- [ ] **F6.1 — Ollama Integration Layer**: GDScript HTTP client → Ollama REST API (localhost:11434) with structured prompt + telemetry payload + answer sheet
- [ ] **F6.2 — Prompt Engineering + Answer Sheet**: Carefully crafted system prompt instructing AI to act as clinical instructor + per-scenario answer sheet (correct protocol steps, triage tags, timing benchmarks) for rubric-based comparison
- [ ] **F6.3 — Behavioural Analysis Output**: AI generates narrative feedback — e.g., "You spent 45 seconds deciding at the first patient but only 8 seconds at the critical case — this suggests triage hesitation under pressure"
- [ ] **F6.4 — Strength/Weakness Identification**: AI identifies what the player did well and what needs improvement, mapped to specific BCLS/ALS competencies
- [ ] **F6.5 — Review Display UI**: In-game panel showing the AI's narrative review alongside quantitative metrics
- [ ] **F6.6 — Historical Comparison**: "Compared to your last 3 attempts, your triage speed improved by 20% but equipment selection accuracy dropped"

### F7. Skill-Specific Dashboards
Quantitative performance visualisation for players and instructors.

- [ ] **F7.1 — Player Performance Summary**: Radar chart of clinical skill axes (Triage Speed, Protocol Accuracy, Decision Quality, Equipment Handling, Patient Prioritisation)
- [ ] **F7.2 — Per-Scenario Breakdown**: Detailed score per scenario with pass/fail against competency thresholds
- [ ] **F7.3 — Progress Over Time**: Line graphs showing skill improvement across multiple attempts
- [ ] **F7.4 — Instructor View (B2B)**: Aggregate dashboard showing class/cohort performance — identify students who need additional training
- [ ] **F7.5 — Export & Reporting**: PDF/CSV export of performance data for institutional record-keeping

### F8. Scenario Content (Initial Set)
The actual medical scenarios shipped with the game.

- [ ] **F8.1 — Tutorial Scenario**: Guided walkthrough of controls and basic patient assessment (no time pressure, UI hints enabled)
- [ ] **F8.2 — Scenario: Road Traffic Accident**: Multi-patient scene, vehicle debris, varying injury severity, triage required
- [ ] **F8.3 — Scenario: Cardiac Arrest (Single Patient)**: Focused BLS scenario — CPR sequence, AED use, protocol adherence
- [ ] **F8.4 — Scenario: Mass Casualty Event**: 5+ patients, limited equipment, START triage under extreme time pressure
- [ ] **F8.5 — Scenario: Building Fire Evacuation**: Hazard navigation + patient extraction + treatment prioritisation

### F9. UI/UX System
All menus, HUD, and interface elements.

- [ ] **F9.1 — Main Menu**: Start, Scenario Select, Dashboard, Settings, Quit
- [ ] **F9.2 — In-Game HUD**: Minimap, scenario timer, active equipment indicator, patient status overview
- [ ] **F9.3 — Scenario Select Screen**: List/grid of available scenarios with difficulty rating, best score, and lock/unlock status
- [ ] **F9.4 — Settings Menu**: Audio, controls, language, accessibility options
- [ ] **F9.5 — Localisation Foundation**: Thai (primary) + English — all UI strings externalised for translation

### F10. Audio System
Sound design for immersion and feedback.

- [ ] **F10.1 — Ambient Soundscapes**: Per-environment audio (traffic, fire crackling, rain, crowd murmur)
- [ ] **F10.2 — UI Feedback Sounds**: Button clicks, equipment pickup, action confirmation, error buzzer
- [ ] **F10.3 — Patient Audio Cues**: Groaning, calling for help, breathing difficulty sounds — audio triage hints
- [ ] **F10.4 — Background Music**: Low-tension ambient tracks, escalating tension during time-critical moments

### F11. B2B2C Platform Layer (Post-Competition Scope)
Institutional features for deployment at scale. **Lower priority — design now, implement later.**

- [ ] **F11.1 — User Authentication**: Login/registration system (email or institutional SSO)
- [ ] **F11.2 — Curriculum Alignment Tools**: Map scenarios to specific BCLS/ALS learning objectives
- [ ] **F11.3 — Institutional Admin Panel**: Manage users, assign scenarios, view aggregate analytics
- [ ] **F11.4 — Scenario Editor (Stretch Goal)**: Visual tool for instructors to create custom scenarios without coding

### F12. Ollama AI — Live Patient & Dispatch Dialogue (Post-Core Scope)
Local LLM-powered NPCs that respond dynamically to player interactions — making history taking, patient communication, and dispatch radio realistic and unpredictable. **Designed for post-competition integration. Architecture must accommodate it from Phase 0.**

- [ ] **F12.1 — Ollama Integration Layer**: GDScript HTTP client → local Ollama REST API (localhost:11434). Runs entirely offline — no cloud dependency
- [ ] **F12.2 — Patient Dialogue System**: Conscious patients respond to player questions via LLM. Player selects question type (SAMPLE history: Symptoms, Allergies, Medications, Past history, Last meal, Events) → LLM generates contextual patient response based on scenario data and patient medical state
- [ ] **F12.3 — Patient Persona Engine**: Each patient NPC has a persona profile (age, pain level, consciousness, panic level, language clarity) fed as system prompt context. A disoriented patient gives confused answers; a child patient responds differently than an adult
- [ ] **F12.4 — Dispatch Radio Channel**: AI-driven dispatch that provides dynamic mission updates, redirects, and new information mid-scenario. Player receives radio calls: "Unit 7, additional casualty reported north side" — generated contextually by LLM based on scenario state
- [ ] **F12.5 — Electrical/Environmental Emergency Dialogue**: Specialised patient/bystander dialogue for electrical injury, chemical exposure, and hazardous material scenarios — patients describe symptoms that the player must interpret for correct protocol selection
- [ ] **F12.6 — History Taking Scoring Integration**: Player's questioning technique during AI dialogue is fed into the telemetry pipeline (F5) and evaluated by the Triage Reviewer (F6) — "The trainee failed to ask about allergies before administering medication"
- [ ] **F12.7 — Dialogue UI**: Chat-style or speech-bubble interface for patient/dispatch conversations, with selectable question categories and free-text input option

---

## Phase Roadmap

| Phase | Name | Scope | Status |
|-------|------|-------|--------|
| 0 | **Foundation & Architecture** | Project setup, isometric camera, player movement, tile system, core scene structure | `[ ] PENDING` |
| 1 | **Core Gameplay Loop** | Patient entity, interaction system, equipment, basic scenario flow (1 scenario) | `[ ] PENDING` |
| 2 | **Medical Protocol System** | Triage tags, BCLS/ALS action sequences, patient state machine, time pressure | `[ ] PENDING` |
| 3 | **Telemetry & AI Reviewer** | Data collection pipeline, Ollama integration, AI narrative review (answer sheet approach), review UI | `[ ] PENDING` |
| 4 | **Dynamic Environment** | Hazards, random events, physics interactions, scene variation | `[ ] PENDING` |
| 5 | **Dashboards & Scoring** | Skill radar chart, progress tracking, per-scenario breakdown, instructor view | `[ ] PENDING` |
| 6 | **Content Expansion** | All 5 scenarios (tutorial + 4 core), audio system, polish | `[ ] PENDING` |
| 7 | **UI/UX & Localisation** | Main menu, settings, scenario select, Thai + English localisation | `[ ] PENDING` |
| 8 | **Testing & Competition Build** | Full QA pass, performance optimisation, competition submission build | `[ ] PENDING` |

> **Note:** F11 (B2B2C Platform Layer) and F12 (Ollama AI Patient & Dispatch Dialogue) are deliberately excluded from the competition phase roadmap — they are post-core scope. Architecture decisions (especially the interaction system in F2 and telemetry pipeline in F5) must accommodate F12 integration from Phase 0, but implementation is deferred until the core loop is solid.

---

## Phase Dependencies (High-Level)

```
Phase 0 (Foundation)
  └─→ Phase 1 (Gameplay Loop)
        └─→ Phase 2 (Medical Protocol)
              ├─→ Phase 3 (Telemetry & AI) — needs gameplay data to assess
              └─→ Phase 4 (Dynamic Environment) — extends scenario system
                    └─→ Phase 5 (Dashboards) — needs telemetry data
                          └─→ Phase 6 (Content) — builds on all systems
                                └─→ Phase 7 (UI/UX & L10n)
                                      └─→ Phase 8 (Testing & Build)
```

---

## Success Criteria (Competition)

1. **Playable demo** with at least 2 complete scenarios (1 tutorial + 1 core)
2. **AI Triage Reviewer** generates meaningful, natural language feedback from gameplay data
3. **Measurable Learning Outcomes** demonstrated via skill dashboards with real telemetry data
4. **Isometric 3D** runs smoothly at 60fps on mid-range hardware
5. **Thai language** primary interface with English fallback

---

*This document is READ-ONLY after Chief Manager approval. To propose changes, create `Indev Implementation Plan.md` and get Chief Manager approval.*
