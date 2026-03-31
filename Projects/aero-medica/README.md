# AeroMedica: Protocol Playground

3D isometric emergency medical training simulation built with Godot 4.6. Practice EMT protocols offline with AI-powered patient dialogue and performance review.

## Download & Play

**Google Drive (Recommended):** [Download here](https://drive.google.com/drive/folders/1rnqWkEMZtg3yYKeX9cIhGl3SZArkfGsf?usp=sharing)

Download the `AeroMedica_WinBuild/` folder and run `AeroMedica.exe`. No installation required.

## What Is This?

AeroMedica is an offline EMT training simulator where players assess patients using real emergency medical protocols. Designed for EMT/Paramedic students and medical training institutions.

### Core Mechanics

- **DRSABCDE Primary Survey** — 8-step assessment with action cooldowns
- **Vital Signs** — HR, BP, SpO2, Temp, BGL, CRT, Pupils, Skin (equipment deployment required)
- **ECG Display** — 7 cardiac rhythms with strip images and rhythm identification
- **GCS Assessment** — Eye (4), Verbal (5), Motor (6) scoring
- **Head-to-Toe Examination** — 7 body regions with severity markers (bilingual TH/EN)
- **SAMPLE/OPQRST History** — AI-powered patient dialogue via Ollama
- **Medical Bag** — BLS/ALS tiers with consumable tracking
- **Drug Administration** — Drug, dose, and route selection with telemetry logging
- **CPR + AED** — Pulse-gated CPR, shockable rhythm detection, ROSC logic
- **START Triage** — GREEN / YELLOW / RED / BLACK classification
- **Differential Diagnosis** — 47 conditions across 6 categories

### Scenarios (5 Playable)

| Scenario | Patients | Time | Difficulty |
|----------|----------|------|------------|
| Tutorial | 1 | Unlimited | 1/5 |
| Road Traffic Accident | 3 | 10 min | 2/5 |
| Cardiac Arrest | 1 | 5 min | 3/5 |
| Building Fire | 3 | 8 min | 4/5 |
| Mass Casualty Incident | 6 (+1 random) | 15 min | 5/5 |

### AI System

- **Ollama (llama3.1:8b)** — Offline AI for patient dialogue and post-scenario performance review
- **Cached Fallback** — 70 pre-written reviews (35 TH + 35 EN) when Ollama is unavailable
- **Auto-Discovery** — Probes localhost and local network IPs for Ollama on startup

### Scoring & Debrief

- **5-Axis Scoring** — Triage Speed, Protocol Accuracy, Decision Quality, Equipment Handling, Patient Outcome
- **AI Review** — Detailed feedback in Thai or English
- **Dashboard** — 2 tabs: My Performance + Scenario Breakdown with radar charts and trend graphs
- **Data Export** — CSV/JSON export of session history

## Key Controls

- **WASD** — Move (isometric 8-directional)
- **E** — Interact with patient / Toggle patient UI
- **Escape** — Close UI / Pause menu
- **1-4** — Switch tabs in patient UI (when UI is open)
- **Scroll** — Camera zoom (disabled during UI)

## Running from Source

### Prerequisites

- [Godot 4.6](https://godotengine.org/) (Forward Plus renderer)
- [Ollama](https://ollama.ai/) (optional — for AI features)

### Setup

```bash
git clone https://github.com/xMartin14091x/aero-medica.git
cd aero-medica
git checkout ui-revamp-v2
```

Open `project.godot` in Godot 4.6 and press F5 to run.

### Optional: Ollama

```bash
ollama pull llama3.1:8b
ollama serve
```

The game auto-discovers Ollama on port 11434. No manual configuration needed.

## Tech Stack

| Component | Technology |
|-----------|------------|
| Game Engine | Godot 4.6 (GDScript) |
| AI Dialogue & Review | Ollama (llama3.1:8b) |
| Data Format | JSON (scenarios, drugs, ECG rhythms) |
| Localization | TranslationServer + CSV (300+ keys, TH/EN) |
| 3D Assets | Kenney Low-Poly kits |
| Theme | Dark navy medical UI (ThemeMedical singleton) |

## Project Structure

```
data/           JSON scenario definitions, drugs, ECG rhythms, protocols
scripts/        GDScript source
  ai/           Ollama dialogue + review integration
  core/         GameManager, ScenarioManager, IsometricCamera
  dashboard/    Scoring engine, history tracking
  gameplay/     Player, interactions, hazards, levels
  medical/      Patient state, triage, deterioration, drugs, ECG, GCS
  telemetry/    Event logging, protocol tracking, error detection
  ui/           All UI panels, menus, HUD, charts
scenes/         Godot scene files
assets/         Textures, 3D models, audio
```

## Development

- **Period:** 7-31 March 2026 (25 days, 86 sessions)
- **Team:** Ollama Paramedic
- **Competition:** TMH 2026

## AI Tools Disclosure

See [CONTRIBUTION.md](CONTRIBUTION.md) for details on AI tools used in development.

## License

This project is developed for the TMH 2026 competition. All Kenney assets are used under [CC0 1.0](https://creativecommons.org/publicdomain/zero/1.0/).
