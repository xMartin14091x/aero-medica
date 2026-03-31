# AeroMedica -- Installation Guide

**Project:** AeroMedica -- Emergency Response Training Simulation
**Version:** INDEV v1.0.1
**Last Updated:** 31-03-2026

---

## 1. Download (Recommended -- Google Drive)

The fastest way to play AeroMedica. No Godot Engine required.

### Download Link

**Google Drive:** https://drive.google.com/drive/folders/1rnqWkEMZtg3yYKeX9cIhGl3SZArkfGsf?usp=sharing

### Folder Contents

| Folder | Description |
|--------|-------------|
| `AeroMedica_WinBuild/` | Windows build -- ready to play |
| `AeroMedica_SourceCode/` | Full project source code |
| `Gameplay/` | Gameplay footage and screenshots |
| `Project Poster/` | Competition poster files |
| `Prototype/` | Prototype documentation |

### Quick Start (Windows Build)

1. Download the `AeroMedica_WinBuild/` folder from Google Drive
2. Extract if compressed
3. Run **`AeroMedica.exe`** to play
4. Alternative: Run `AeroMedica.console.exe` to play with a debug console window

**System requirements:** Windows 10/11. No additional software needed.

> **Note:** The build includes `AeroMedica.pck` (game data) alongside the executables. Keep all files in the same folder.

---

## 2. Optional: Ollama Setup (AI Features)

Ollama provides local AI capabilities for patient dialogue and performance review. It is fully optional -- the game functions without it using cached fallback reviews.

### Install Ollama

1. Download from https://ollama.ai/download
2. Install and ensure the Ollama service is running (`ollama serve`)
3. Pull the default model:

```bash
ollama pull llama3.1:8b
```

### Auto-Discovery

AeroMedica auto-discovers Ollama on startup by probing:
- `http://localhost:11434`
- `http://127.0.0.1:11434`
- All local network IPv4 addresses on port 11434

No manual URL configuration is needed for local setups.

### Verify Connection

In-game, go to Settings > AI Configuration. The status indicator shows:
- **Green dot / "Online"** -- Ollama is connected
- **Red dot / "Offline"** -- Ollama not found (game uses cached fallback)

Use the "Reconnect" button to re-trigger discovery at any time.

### Without Ollama

When Ollama is not available:

- **AI Dialogue:** Falls back to static responses defined in PatientPersona data. The Patient tab chat still functions but responses are scripted rather than AI-generated.
- **AI Reviewer:** Falls back to cached pre-written reviews via AIDemoFallback. Reviews are matched by scenario ID and performance tier (perfect/good/poor/catastrophic/empty). 70 cached reviews included (35 English + 35 Thai) in a single `cached_reviews.json`.
- **UI Notification:** A popup informs the player that Ollama was not found and the game is operating in fallback mode.

All scoring, telemetry, triage, assessment, and treatment systems function identically with or without Ollama.

---

## 3. Source Code (For Developers)

For developers who want to modify or extend AeroMedica.

### Option A: From Google Drive

Download the `AeroMedica_SourceCode/` folder from the Google Drive link above.

### Option B: From GitHub

```bash
git clone https://github.com/xMartin14091x/aero-medica.git
cd aero-medica
git checkout ui-revamp-v2
```

The working branch is `ui-revamp-v2`.

### Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Godot Engine** | 4.6 | Must be 4.6 (Forward Plus renderer). Download from https://godotengine.org/ |
| **Git** | Any recent | Only needed for GitHub clone |
| **Ollama** | Optional | Required for live AI features. Game runs without it. |

### Open in Godot

1. Launch Godot 4.6
2. Click "Import" in the Project Manager
3. Navigate to the source directory and select `project.godot`
4. Click "Import & Edit"
5. Wait for Godot to import all assets (first import may take 1-2 minutes)

### Running

- Press **F5** (or the Play button) to run the project
- The main scene is `scenes/main/MainMenu.tscn`
- Controls: WASD or arrow keys to move, E to interact with patients/equipment, Q to drop, Escape to close panels

---

## 4. Autoloads

The following singletons are registered as autoloads in `project.godot` and are available globally at runtime:

| Autoload Name | Script Path | Purpose |
|---------------|-------------|---------|
| GameManager | `scripts/core/game_manager.gd` | Game state management (MENU, PLAYING, DEBRIEF) |
| LocalisationManager | `scripts/core/localisation_manager.gd` | Bilingual TH/EN language switching |
| TelemetryCollector | `scripts/telemetry/telemetry_collector.gd` | Session event recording |
| ScenarioManager | `scripts/core/scenario_manager.gd` | Scenario loading, entity spawning, lifecycle |
| OllamaReviewClient | `scripts/ai/reviewer/ollama_review_client.gd` | AI performance review via Ollama |
| OllamaDialogueClient | `scripts/ai/ollama/ollama_dialogue_client.gd` | AI patient conversation via Ollama |
| ECGRhythmManager | `scripts/medical/ecg_rhythm_manager.gd` | ECG rhythm database and image loading |
| GCSAssessmentManager | `scripts/medical/gcs_assessment_manager.gd` | Glasgow Coma Scale assessment |
| SecondarySurveyManager | `scripts/medical/secondary_survey_manager.gd` | Head-to-toe secondary survey |
| TriageSystem | `scripts/medical/triage_system.gd` | START triage tag management |
| ThemeMedical | `scripts/core/theme_medical.gd` | Dark theme system |
| AIDemoFallback | `scripts/ai/reviewer/ai_demo_fallback.gd` | Cached AI review fallback |
| HistoryManager | `scripts/dashboard/history_manager.gd` | Session score persistence and trends |

---

## 5. Folder Structure

```
aero-medica/
├── assets/                     # Visual assets
│   ├── fonts/                  # Kanit font (Thai/English)
│   ├── models/                 # 3D models (.glb)
│   └── textures/               # UI textures, ECG rhythm images
│       └── ecg/                # ECG rhythm PNGs (keyed by rhythm name)
├── data/                       # Game data (JSON, CSV, text)
│   ├── answer_sheets/          # Correct answers per scenario
│   ├── cached_reviews.json     # 70 cached AI reviews (TH + EN) in single file
│   ├── drugs.json              # Pharmacological database
│   ├── ecg_rhythms.json        # ECG rhythm definitions + image paths
│   ├── history_questions.json  # History taking question database
│   ├── medical_bag_tiers.json  # BLS/ALS equipment definitions
│   ├── prompts/                # AI prompt templates
│   │   ├── model_recommendations.json
│   │   └── triage_reviewer_system.txt
│   ├── protocols/              # Clinical protocol definitions
│   │   ├── als_protocol.json
│   │   ├── bcls_protocol.json
│   │   └── start_triage.json
│   ├── scenarios/              # 7 scenario JSON definitions
│   ├── test_sessions/          # Pre-built test sessions for scoring
│   └── translations/           # translations.csv (360+ keys, TH/EN)
├── scenes/                     # Godot scene files (.tscn)
│   ├── entities/               # Patient, equipment scene files
│   ├── environments/           # 3D environment scenes
│   ├── gameplay/               # Level-specific scenes
│   ├── main/                   # MainMenu.tscn
│   └── ui/                     # UI scene files
├── scripts/                    # All GDScript source code
│   ├── ai/                     # AI clients (Ollama dialogue, reviewer, fallback)
│   ├── core/                   # Game manager, scenario manager, theme, localisation
│   ├── dashboard/              # Scoring engine, history manager, data exporter
│   ├── gameplay/               # Player controller, hazards, random events, levels
│   ├── medical/                # Patient entity, medical state, drugs, triage, deterioration
│   ├── telemetry/              # Event collection, protocol adherence, error detection
│   └── ui/                     # All UI scripts (patient interaction, dashboard, HUD, menus)
├── project.godot               # Godot project file (autoloads, input mappings, config)
└── icon.svg                    # Project icon
```

---

## 6. Known Issues

- **First-run import delay (source only).** The first time the project is opened in Godot, all assets are processed. This may take 1-2 minutes. Subsequent opens are instant.
- **Ollama timeout on first request.** If the Ollama model is not loaded in memory, the first AI request may take 30-60 seconds while the model loads. Subsequent requests are faster.
- **Display resolution.** The project targets 1920x1080 with canvas_items stretch mode. Lower resolutions may cause UI elements to overlap.
