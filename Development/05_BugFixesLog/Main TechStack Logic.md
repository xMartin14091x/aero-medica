# AeroMedica — Main TechStack Logic

**Project:** AeroMedica
**Engine:** Godot 4.x
**Created:** 07-03-2026
**Last Updated:** 08-03-2026
**Status:** APPROVED — Godot 4.x confirmed by Chief Manager 08-03-2026

---

## Platform Target

- **View:** Isometric / Orthographic 3D
- **Primary Build:** PC (Windows) — competition demo
- **Secondary Build:** Web (HTML5/WebGL) — accessibility for judges/institutions
- **Domain:** Medical emergency training (BCLS/ALS protocols)
- **Deployment Model:** B2B2C — institutional + individual access (post-competition)

---

## Technology Stack

### Game Engine
- **Godot 4.x** (latest stable — currently 4.6)
- **License:** MIT — fully open source, no royalties, no revenue caps
- **Language:** GDScript (primary) — Python-like, beginner-friendly
- **Rationale:** Lightweight, open source, excellent isometric/orthographic support, active community, builds to PC + Web from single project

### Rendering & Camera
- **Renderer:** Godot Forward+ (PC) / Compatibility renderer (Web export)
- **Camera:** Orthographic projection at isometric angle (approx. 30° from horizontal, 45° rotation)
- **Art Style:** Low-poly / stylised — prioritise visual clarity and gameplay readability over photorealism
- **Resolution Target:** 1920x1080 primary, responsive scaling

### AI Integration — Stealth Assessment (Claude API — Cloud)
- **AI Provider:** Claude API (Anthropic)
- **Transport:** HTTPS REST — GDScript `HTTPRequest` node → Claude Messages API
- **Data Flow:** Gameplay telemetry (JSON) → structured prompt → Claude API → narrative review (text)
- **Model:** claude-sonnet-4-6 (cost-effective for per-session analysis) — configurable
- **Prompt Architecture:**
  - System prompt: clinical instructor persona + BCLS/ALS protocol knowledge
  - User prompt: structured telemetry payload (actions, timings, errors, movement data)
  - Response: natural language behavioural analysis + strength/weakness identification

### AI Integration — Live NPC Dialogue (Ollama — Local, Post-Core Scope)
- **AI Provider:** Ollama (local LLM runtime)
- **Transport:** HTTP REST — GDScript `HTTPRequest` node → `localhost:11434/api/generate` (Ollama default)
- **Model:** TBD — lightweight model that fits in VRAM alongside Godot (candidates: Llama 3.x 8B, Mistral 7B, Gemma 2 9B, Phi-3, Qwen 2.5 7B)
- **Fully Offline:** No cloud dependency — Ollama runs the model locally on the player's GPU/CPU
- **Use Cases:**
  - **Patient Dialogue:** Conscious patients respond dynamically to player questions during SAMPLE history taking (Symptoms, Allergies, Medications, Past history, Last meal, Events). Patient persona (age, pain, consciousness, panic) shapes response tone and accuracy
  - **Dispatch Radio:** AI-driven dispatch generates contextual mission updates mid-scenario ("Unit 7, second patient found at north entrance")
  - **Bystander/Witness:** Environmental NPCs provide scene information when questioned ("The power line fell about 5 minutes ago, he was standing right there")
- **Architecture Requirement:** The interaction system (F2) and telemetry pipeline (F5) must be designed with dialogue hooks from Phase 0 — even though Ollama integration is implemented later. Specifically:
  - `InteractableComponent` must support a `dialogue_capable` flag
  - `TelemetryEmitter` must log dialogue events (question asked, response received, time spent)
  - Patient entity must expose persona data for prompt injection

### Data & Storage
- **Session Data:** Local JSON files — one file per gameplay session containing full telemetry
- **Player Profile:** Local JSON — cumulative stats, historical scores, session history
- **Scenario Definitions:** Godot Resource files (`.tres`) or JSON — scenario parameters, patient configs, spawn points
- **No Remote Database (Competition):** All data stored locally. Remote storage is post-competition scope (F11)

### UI Framework
- **In-Game UI:** Godot Control nodes (native UI system)
- **Dashboard Charts:** Custom `Control` nodes drawing with `_draw()` — radar charts, line graphs, bar charts
- **Theming:** Godot Theme resources (`.tres`) — consistent colour palette, typography across all screens
- **Localisation:** Godot's built-in Translation system — `.csv` translation files for Thai + English

### Audio
- **Format:** OGG Vorbis (music/ambience), WAV (short SFX)
- **System:** Godot `AudioStreamPlayer` / `AudioStreamPlayer3D` for positional audio
- **Music:** Ambient low-tension tracks, dynamic layers for time pressure escalation

### Build & Export
- **PC:** Godot export template → Windows `.exe` (primary competition build)
- **Web:** Godot export template → HTML5/WebGL (secondary — for accessibility)
- **Version Control:** Git (repository TBD)

---

## Architecture Overview

```
AeroMedica/
├── project.godot                    # Godot project config
├── addons/                          # Third-party plugins (if any)
├── assets/
│   ├── models/                      # 3D models (.glb/.gltf)
│   ├── textures/                    # Texture files
│   ├── audio/
│   │   ├── music/                   # Background tracks (.ogg)
│   │   └── sfx/                     # Sound effects (.wav)
│   └── ui/                          # UI sprites, icons
├── scenes/
│   ├── main/                        # Main menu, settings, scenario select
│   ├── gameplay/                    # Core gameplay scene, HUD
│   ├── environments/                # Tileset scenes, environment prefabs
│   ├── entities/
│   │   ├── player/                  # Player character scene + scripts
│   │   ├── patients/                # Patient NPC scenes + state machines
│   │   └── equipment/               # Interactable equipment scenes
│   └── ui/
│       ├── hud/                     # In-game HUD elements
│       ├── dashboard/               # Performance dashboards
│       └── review/                  # AI review display panel
├── scripts/
│   ├── core/                        # Singletons, game manager, scene manager
│   ├── gameplay/                    # Interaction, inventory, scenario logic
│   ├── medical/                     # Protocol definitions, triage logic, patient state
│   ├── telemetry/                   # Data collection, event logging, session export
│   ├── ai/                          # Claude API client, prompt builder, response parser
│   │   ├── claude/                  # Triage Reviewer (F6) — cloud API
│   │   └── ollama/                  # NPC Dialogue (F12) — local LLM
│   ├── dashboard/                   # Scoring calculations, chart rendering
│   └── ui/                          # Menu logic, settings, localisation helpers
├── data/
│   ├── scenarios/                   # Scenario definition files (.tres / .json)
│   ├── protocols/                   # BCLS/ALS protocol reference data
│   ├── translations/                # Localisation .csv files
│   └── themes/                      # UI theme resources
└── user_data/                       # (runtime) saved sessions, player profiles
```

---

## Core Systems Architecture

### 1. Scene Management
- **GameManager** (Autoload/Singleton): Global state, scene transitions, session lifecycle
- **ScenarioManager**: Load scenario data → instantiate environment, patients, equipment → manage scenario clock → trigger completion
- **Pattern:** Scene tree composition — each entity is a self-contained scene with its own script

### 2. Entity Component Pattern
Godot's node/scene system naturally supports composition:
- **Player** = `CharacterBody3D` + `NavigationAgent3D` + `InteractionArea` (Area3D) + `InventoryComponent` + `TelemetryEmitter`
- **Patient** = `CharacterBody3D` + `MedicalStateComponent` + `InteractableComponent` + `TriageTagVisual` + `PatientPersona` (F12-ready: age, pain, consciousness, panic, dialogue history)
- **Equipment** = `StaticBody3D` / `RigidBody3D` + `InteractableComponent` + `EquipmentData`

### 3. Medical State Machine
Each patient has a finite state machine tracking:
```
States: CONSCIOUS → UNCONSCIOUS → CARDIAC_ARREST → DEAD
Modifiers: bleeding_severity (0-3), airway_status (clear/obstructed), breathing_rate, pulse_present
Deterioration: Untreated conditions worsen over time (configurable rate per scenario)
Treatment: Correct player actions stabilise or improve state
```

### 4. Telemetry Pipeline
```
Player Action → TelemetryEmitter (signal) → TelemetryCollector (singleton)
                                                    ↓
                                            SessionData (in-memory)
                                                    ↓
                                            JSON Export → AI Reviewer
```

**Data points collected:**
- Position snapshots (every 1s) → movement heatmap
- Action events (timestamped): `{action: "assess_breathing", target: "patient_02", time: 34.5, correct: true}`
- Protocol sequence comparison: player's action order vs. gold standard
- Timing metrics: response times, idle periods, total duration

### 5. AI Review Pipeline
```
SessionData (JSON) → PromptBuilder → HTTPRequest → Claude API
                                                        ↓
                                                  ReviewResponse (text)
                                                        ↓
                                                  ReviewParser → ReviewUI
```

**Prompt structure:**
- System: "You are a senior EMT clinical instructor reviewing a trainee's performance..."
- User: `{scenario_id, patient_outcomes[], action_log[], timing_metrics{}, protocol_adherence%, errors[]}`
- Expected output: structured narrative with sections (Overall Assessment, Strengths, Areas for Improvement, Critical Errors, Recommendations)

### 6. Scoring System
Five clinical skill axes, each scored 0–100:
| Axis | Data Source |
|------|-----------|
| **Triage Speed** | Time-to-first-assessment, time-to-triage-tag |
| **Protocol Accuracy** | Action sequence match against gold standard |
| **Decision Quality** | Patient prioritisation correctness (most critical first) |
| **Equipment Handling** | Correct equipment selected for condition, usage sequence |
| **Patient Outcome** | Final patient states vs. best achievable outcome |

---

## Integration Points

| System A | System B | Interface |
|----------|----------|-----------|
| Player Controller | Telemetry | Signal: `action_performed(action_data)` |
| Scenario Manager | Patient Entity | Signal: `patient_state_changed(patient_id, new_state)` |
| Telemetry Collector | AI Reviewer | JSON payload via `export_session()` |
| AI Reviewer | Review UI | Parsed response object |
| Telemetry Collector | Dashboard | Scoring calculations on session data |
| Scenario Data (JSON) | Scenario Manager | `load_scenario(path)` |
| Player Controller | Patient Dialogue (F12) | Signal: `dialogue_initiated(patient_id, question_type)` |
| Patient Persona | Ollama Client (F12) | System prompt injection via `get_persona_prompt()` |
| Ollama Client (F12) | Telemetry | Signal: `dialogue_event(question, response, duration)` |

---

## Design Constraints

1. **No server dependency for gameplay** — game runs fully offline; AI review (Claude) is the only online feature; NPC dialogue (Ollama) is also fully local
2. **AI review is optional** — if Claude API is unavailable, show quantitative scores only (graceful degradation)
3. **NPC dialogue is optional** — if Ollama is not running, patients use pre-scripted dialogue trees as fallback (F12 graceful degradation)
3. **Scenario-agnostic telemetry** — the data collection system must work identically regardless of which scenario is loaded
4. **Modular scenarios** — adding a new scenario requires only a new data file + environment scene, no engine code changes
5. **Performance target** — 60fps on mid-range hardware (GTX 1060 / equivalent) at 1080p

---

## External Dependencies

| Dependency | Purpose | Risk |
|------------|---------|------|
| Claude API (Anthropic) | AI Triage Reviewer (F6) | Requires API key + internet; game functions without it |
| Ollama (local) | Live NPC Dialogue (F12) | Requires local install + compatible GPU; falls back to scripted dialogue |
| Godot 4.x | Game engine | MIT license, no risk |
| Blender (optional) | 3D model creation | Free, open source |

---

*This document is READ-ONLY after Chief Manager approval. To propose changes, create `Indev TechStack.md` and get Chief Manager approval.*
