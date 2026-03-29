# AeroMedica -- Installation Guide (Source)

**Project:** AeroMedica -- Emergency Response Training Simulation
**Version:** INDEV v1.0.1
**Last Updated:** 29-03-2026

This guide covers running AeroMedica from source using the Godot editor (not an exported build).

---

## 1. Prerequisites

| Requirement | Version | Notes |
|-------------|---------|-------|
| **Godot Engine** | 4.6 | Must be 4.6 (Forward Plus renderer). Download from https://godotengine.org/ |
| **Git** | Any recent | For cloning the repository |
| **Git LFS** | Optional | Only needed if binary assets are tracked via LFS |
| **Ollama** | Optional | Required for live AI features (patient dialogue and AI reviewer). Game runs without it using cached fallback. |

**System requirements:** Windows 10/11 (D3D12 rendering backend configured). Jolt Physics engine is used for 3D physics.

---

## 2. Clone Repository

```bash
git clone https://github.com/xMartin14091x/aero-medica.git
cd aero-medica
git checkout ui-revamp-v2
```

The working branch is `ui-revamp-v2`. Ensure you are on this branch before opening in Godot.

---

## 3. Open in Godot

1. Launch Godot 4.6
2. Click "Import" in the Project Manager
3. Navigate to the cloned `aero-medica/` directory and select `project.godot`
4. Click "Import & Edit"
5. Wait for Godot to import all assets (textures, models, fonts). First import may take 1-2 minutes.

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
| ThemeMedical | `scripts/core/theme_medical.gd` | Dark/light theme system |
| AIDemoFallback | `scripts/ai/reviewer/ai_demo_fallback.gd` | Cached AI review fallback for demo mode |
| HistoryManager | `scripts/dashboard/history_manager.gd` | Session score persistence and trends |

All autoloads are prefixed with `*` in `project.godot`, meaning they are enabled.

---

## 5. Running

- Press **F5** (or the Play button) to run the project
- The main scene is `scenes/main/MainMenu.tscn` (configured in `project.godot` as `run/main_scene`)
- From the main menu, select a scenario to begin gameplay
- Controls: WASD or arrow keys to move, E to interact with patients/equipment, Q to drop, Escape to close panels

---

## 6. Optional: Ollama Setup

Ollama provides local AI capabilities for patient dialogue and performance review. It is fully optional -- the game functions without it.

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

No manual URL configuration is needed for local setups. For remote Ollama instances, edit `user_data/ai_config.json`:

```json
{
    "ollama_url": "http://your-server:11434",
    "model": "llama3.1:8b",
    "request_timeout_seconds": 60,
    "max_tokens": 1500
}
```

### Verify Connection

In-game, go to Settings > AI Configuration. The status indicator shows:
- **Green dot / "Online"** -- Ollama is connected
- **Red dot / "Offline"** -- Ollama not found (game uses cached fallback)

Use the "Reconnect" button to re-trigger discovery at any time.

---

## 7. Without Ollama

When Ollama is not available:

- **AI Dialogue:** Falls back to static responses defined in PatientPersona data. The Patient tab chat still functions but responses are scripted rather than AI-generated.
- **AI Reviewer:** Falls back to cached pre-written reviews via AIDemoFallback. Reviews are matched by scenario ID and performance tier (perfect/good/poor/catastrophic/empty) based on the player's overall score. 70 cached review files are included (35 English + 35 Thai).
- **UI Notification:** A popup or status indicator informs the player that Ollama was not found and the game is operating in demo/fallback mode.

All scoring, telemetry, triage, assessment, and treatment systems function identically with or without Ollama.

---

## 8. Folder Structure

```
aero-medica/
├── assets/                     # Visual assets
│   ├── fonts/                  # Kanit font (Thai/English)
│   ├── models/                 # 3D models (.glb)
│   └── textures/               # UI textures, ECG rhythm images
│       └── ecg/                # ECG rhythm PNGs (keyed by rhythm name)
├── data/                       # Game data (JSON, CSV, text)
│   ├── answer_sheets/          # Correct answers per scenario
│   ├── drugs.json              # Pharmacological database
│   ├── ecg_rhythms.json        # ECG rhythm definitions + image paths
│   ├── history_questions.json  # History taking question database
│   ├── medical_bag_tiers.json  # BLS/ALS equipment definitions
│   ├── prompts/                # AI prompt templates + cached reviews
│   │   ├── cached_reviews/     # 70 pre-written AI review files (EN + TH)
│   │   ├── model_recommendations.json
│   │   └── triage_reviewer_system.txt
│   ├── protocols/              # Clinical protocol definitions
│   │   ├── als_protocol.json
│   │   ├── bcls_protocol.json
│   │   └── start_triage.json
│   ├── scenarios/              # 7 scenario JSON definitions
│   ├── test_sessions/          # Pre-built test sessions for scoring
│   ├── themes/                 # Theme data (reserved)
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
├── user_data/                  # Default config files
│   └── ai_config.json          # AI configuration template
├── project.godot               # Godot project file (autoloads, input mappings, config)
└── icon.svg                    # Project icon
```

---

## 9. Known Issues

- **`.glb.import` files are gitignored.** Godot regenerates `.import` files for 3D models on first open. If models appear missing after cloning, let Godot complete its initial import process (watch the bottom progress bar).
- **First-run import delay.** The first time the project is opened, Godot processes all assets (textures, models, translations). This may take 1-2 minutes. Subsequent opens are instant.
- **Ollama timeout on first request.** If the Ollama model is not loaded in memory, the first AI request may take 30-60 seconds while the model loads. Subsequent requests are faster.
- **Display resolution.** The project targets 1920x1080 with canvas_items stretch mode. Lower resolutions may cause UI elements to overlap.
