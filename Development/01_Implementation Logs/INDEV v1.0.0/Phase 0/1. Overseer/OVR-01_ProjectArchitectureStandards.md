# OVR-01 — Project Architecture Standards

**Phase:** Phase 0 — Foundation & Architecture
**Team:** Overseer — Head Office
**Status:** `[x] Complete`
**Depends on:** None
**Blocks:** MON-01, MON-02, MON-06

---

## Scope
Define the canonical project folder structure, naming conventions, autoload registrations, and component standards for the AeroMedica Godot project. All teams reference this document when creating files.

## Decisions

### Folder Structure
As defined in Main TechStack Logic.md — `Architecture Overview` section. Canonical path: `Projects/game/`

### Autoload Singletons
| Name | Script Path | Purpose |
|------|------------|---------|
| `GameManager` | `scripts/core/game_manager.gd` | Global state, scene transitions, session lifecycle |
| `ScenarioManager` | `scripts/core/scenario_manager.gd` | Scenario loading, patient/equipment spawning, clock |
| `TelemetryCollector` | `scripts/telemetry/telemetry_collector.gd` | Receives action signals, stores session data |

### Naming Conventions
- **Scenes:** `PascalCase.tscn` (e.g., `Player.tscn`, `PatientBase.tscn`)
- **Scripts:** `snake_case.gd` (e.g., `game_manager.gd`, `interactable_component.gd`)
- **Resources:** `snake_case.tres` (e.g., `scenario_rta.tres`, `default_theme.tres`)
- **Folders:** `snake_case/` (e.g., `scripts/core/`, `scenes/entities/player/`)
- **Signals:** `snake_case` verbs (e.g., `action_performed`, `patient_state_changed`)
- **Constants/Enums:** `UPPER_SNAKE_CASE` (e.g., `TRIAGE_GREEN`, `STATE_CONSCIOUS`)

### Base Components (F12-Ready)
- `InteractableComponent` must include `dialogue_capable: bool` export
- `TelemetryEmitter` must emit `dialogue_event` signal alongside `action_performed`
- `PatientPersona` resource class must exist even if unpopulated in Phase 0

## Acceptance Criteria
- [x] Folder structure defined and documented
- [x] Autoload list finalised
- [x] Naming conventions established
- [x] F12 architecture hooks specified

## Boundaries — Do NOT Touch
This ticket defines standards only — no code is written by Overseer.

## Notes
This ticket is auto-complete — it documents decisions already made in Main TechStack Logic.md and this planning session.
