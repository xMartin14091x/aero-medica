# AeroMedica

Emergency Medical Training Simulation built with Godot 4.6.

## Setup

1. Install **Godot 4.6** (must match exactly)
2. Clone this repo
3. Open `project.godot` in Godot
4. Press F5 to run

## AI Features (Optional)

Patient dialogue and AI performance review require [Ollama](https://ollama.com/) running locally:

```bash
ollama serve
ollama pull llama3.1:8b
```

The game auto-discovers Ollama on localhost, 127.0.0.1, and LAN IPs. Falls back to scripted responses and cached reviews if unavailable.

## Scenarios

| Scenario | Patients | Difficulty |
|----------|----------|-----------|
| Tutorial | 1 | 1 |
| Building Fire (Single) | 1 | 2 |
| Cardiac Arrest (Workplace) | 1 | 2 |
| Cardiac Arrest (Park) | 1 | 3 |
| Building Fire (Apartment) | 3 (+1 random) | 4 |
| Road Traffic Accident | 3 | 3 |
| Mass Casualty (Market) | 6 (+1 random) | 5 |

## Key Controls

- **WASD** — Move (isometric 8-directional)
- **E** — Interact with patient / Toggle patient UI
- **Escape** — Close UI / Pause menu
- **1-4** — Switch tabs in patient UI (when UI is open)
- **Scroll** — Camera zoom (disabled during UI)

## Project Structure

```
data/           JSON scenario definitions, drugs, ECG rhythms, protocols
scripts/        GDScript source (71 files)
  ai/           Ollama dialogue + review integration
  core/         GameManager, ScenarioManager, IsometricCamera
  dashboard/    Scoring engine, history tracking
  gameplay/     Player, interactions, hazards, levels
  medical/      Patient state, triage, deterioration, drugs, ECG, GCS
  telemetry/    Event logging, protocol tracking, error detection
  ui/           All UI panels, menus, HUD, charts
scenes/         Godot scene files
  gameplay/     Hand-crafted V2 level scenes
  entities/     Player, patient, equipment prefabs
  ui/           UI scene prefabs
assets/         Textures, models, audio
  textures/ecg/ ECG rhythm strip images
```
