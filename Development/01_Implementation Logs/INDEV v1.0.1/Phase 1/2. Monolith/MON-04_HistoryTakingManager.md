# MON-04 — History Taking Manager (Backend Logic)

**Phase:** Phase 1 — Patient History Taking
**Team:** Monolith — Stability/Infrastructure
**Status:** `[x] Complete`
**Depends on:** MON-03
**Blocks:** None (Arcade scaffolds with mocks)

---

## Scope

Create the `HistoryTakingManager` component that manages the history-taking dialogue flow — tracking which patient is being interviewed, which questions have been asked, and routing question/response pairs between UI and patient data.

## Implementation

### Create HistoryTakingManager Script

New file: `scripts/gameplay/history_taking_manager.gd`

```gdscript
extends Node

## Emitted when history taking begins on a patient
signal history_started(patient: Node)

## Emitted when history taking ends
signal history_ended

## Emitted when a question is asked and response received
signal response_received(category: String, question_key: String, question_label: String, response: String)

## Currently interviewed patient
var _current_patient: Node = null

## Track asked questions per patient (patient_name -> { category -> [question_keys] })
var _asked_questions: Dictionary = {}

## Whether history mode is active
var is_active: bool = false

## Available question definitions (loaded from JSON)
var _question_defs: Dictionary = {}


func _ready() -> void:
    _load_question_definitions()


func _load_question_definitions() -> void:
    var file := FileAccess.open("res://data/history_questions.json", FileAccess.READ)
    if file:
        var json := JSON.new()
        json.parse(file.get_as_text())
        _question_defs = json.data
        file.close()


func begin_history(patient: Node) -> void:
    if is_active:
        return
    _current_patient = patient
    is_active = true
    # Initialize tracking for this patient
    if not _asked_questions.has(patient.name):
        _asked_questions[patient.name] = {}
    history_started.emit(patient)


func end_history() -> void:
    _current_patient = null
    is_active = false
    history_ended.emit()


func get_categories() -> Array:
    return _question_defs.keys()


func get_questions_for_category(category: String) -> Array:
    return _question_defs.get(category, [])


func ask_question(category: String, question_key: String) -> String:
    if not _current_patient:
        return ""

    var persona = _current_patient.get_node_or_null("PatientPersona")
    if not persona:
        # Try getting persona from patient entity
        if "persona" in _current_patient:
            persona = _current_patient.persona

    if not persona or not persona.can_respond():
        var response := "Patient is unresponsive."
        _record_asked(category, question_key)
        response_received.emit(category, question_key, _get_label(category, question_key), response)
        return response

    var response := persona.get_history_response(category, question_key)
    if response.is_empty():
        response = "..."  # Patient has no specific answer
    _record_asked(category, question_key)
    response_received.emit(category, question_key, _get_label(category, question_key), response)
    return response


func is_question_asked(category: String, question_key: String) -> bool:
    if not _current_patient:
        return false
    var patient_record = _asked_questions.get(_current_patient.name, {})
    var cat_record = patient_record.get(category, [])
    return question_key in cat_record


func _record_asked(category: String, question_key: String) -> void:
    if not _current_patient:
        return
    if not _asked_questions[_current_patient.name].has(category):
        _asked_questions[_current_patient.name][category] = []
    if question_key not in _asked_questions[_current_patient.name][category]:
        _asked_questions[_current_patient.name][category].append(question_key)


func _get_label(category: String, question_key: String) -> String:
    for q in _question_defs.get(category, []):
        if q.get("key", "") == question_key:
            return q.get("label", question_key)
    return question_key
```

### Wire into Player Entity

Add `HistoryTakingManager` as a child node of `Player.tscn` (alongside InteractionManager, AssessmentManager, etc.)

### Update InteractionManager Routing

Modify `interaction_manager.gd` to route to history taking when:
- Player interacts with patient (empty hands)
- Patient has not been fully history-taken yet
- Patient is conscious enough to respond

Flow: E on patient → HistoryTakingManager.begin_history() → HUD shows dialogue

## Files to Create

- `scripts/gameplay/history_taking_manager.gd`

## Files to Modify

- `scenes/entities/player/Player.tscn` — Add HistoryTakingManager node
- `scripts/gameplay/interaction_manager.gd` — Route patient interactions to history mode

## Acceptance Criteria

- [x] HistoryTakingManager loads question definitions from JSON
- [x] `begin_history(patient)` emits `history_started` signal
- [x] `ask_question(category, key)` returns correct response from PatientPersona
- [x] Unconscious patients return "Patient is unresponsive."
- [x] Asked questions are tracked (no duplicate counting)
- [x] `is_question_asked()` correctly reports question state
- [x] `end_history()` cleans up and emits `history_ended`
- [x] InteractionManager routes to history taking for patient interactions

## Boundaries — Do NOT Touch

- Do NOT modify AssessmentManager — it remains a separate interaction mode
- Do NOT create any UI elements (Arcade tickets handle UI)
- Do NOT modify MedicalStateComponent or DeteriorationSystem
