# MON-06 — Base Component Library

**Phase:** Phase 0 — Foundation & Architecture
**Team:** Monolith — Stability/Core
**Status:** `[x] Complete`
**Depends on:** MON-01
**Blocks:** None (consumed by Phase 1+)

---

## Scope
Create the foundational component scripts that all entities will use. These are skeletons — minimal implementations that define the interface and signal contracts. Phase 1 will flesh them out with actual logic.

## Acceptance Criteria

### InteractableComponent (`scripts/gameplay/interactable_component.gd`)
- [ ] Extends `Node` (attached as child to any interactable entity)
- [ ] Export: `interaction_label: String` — what the UI prompt will say (e.g., "Check Pulse", "Pick Up AED")
- [ ] Export: `dialogue_capable: bool = false` — F12 architecture hook
- [ ] Signal: `interacted(interactor: Node)` — emitted when player triggers interaction
- [ ] Method: `can_interact() -> bool` — returns true if interaction is available (default: true)

### TelemetryEmitter (`scripts/telemetry/telemetry_emitter.gd`)
- [ ] Extends `Node` (attached as child to player)
- [ ] Signal: `action_performed(action_data: Dictionary)` — emitted on every tracked action
- [ ] Signal: `dialogue_event(question: String, response: String, duration: float)` — F12 hook
- [ ] Method: `emit_action(action_type: String, target: String, details: Dictionary)` — helper to build and emit action_data
- [ ] `action_data` format: `{type: String, target: String, timestamp: float, details: Dictionary}`

### TelemetryCollector (`scripts/telemetry/telemetry_collector.gd`)
- [ ] Extends `Node` — registered as autoload singleton
- [ ] Connects to `TelemetryEmitter.action_performed` signals (auto-discovery or manual registration)
- [ ] Stores events in `session_events: Array[Dictionary]`
- [ ] Method: `start_session(scenario_id: String)` — clears data, starts timer
- [ ] Method: `end_session() -> Dictionary` — returns full session data package
- [ ] Method: `export_session_json(path: String)` — writes session data to JSON file
- [ ] Registered as autoload in `project.godot`

### PatientPersona (`scripts/medical/patient_persona.gd`)
- [ ] Extends `Resource` (so it can be saved as `.tres` and attached to patient scenes)
- [ ] Export: `patient_name: String`
- [ ] Export: `age: int`
- [ ] Export: `pain_level: int` (0–10)
- [ ] Export: `consciousness_level: String` — enum: "ALERT", "VERBAL", "PAIN", "UNRESPONSIVE" (AVPU scale)
- [ ] Export: `panic_level: float` (0.0–1.0)
- [ ] Export: `language_clarity: float` (0.0–1.0) — how coherent the patient's speech is
- [ ] Method: `get_persona_prompt() -> String` — returns a formatted string for F12 LLM prompt injection (skeleton — returns placeholder)

## Boundaries — Do NOT Touch
- Do NOT implement actual interaction logic (press E to interact) — Phase 1
- Do NOT implement actual telemetry analysis or scoring — Phase 3/5
- Do NOT connect Ollama or Claude API — Phase 3/F12
- These are SKELETONS — define interfaces and signals, not behaviour

## Notes
- The goal is to establish the signal contracts and data formats that all future systems depend on
- `PatientPersona` as a `Resource` allows per-patient customisation in the Godot editor
- The AVPU scale (Alert, Verbal, Pain, Unresponsive) is the standard rapid consciousness assessment used in emergency medicine
