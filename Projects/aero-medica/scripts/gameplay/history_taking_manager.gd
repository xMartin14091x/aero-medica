## HistoryTakingManager — Manages patient history-taking dialogue flow.
## Tracks which patient is being interviewed, which questions have been asked,
## and routes question/response pairs between UI and PatientPersona data.
extends Node

## Emitted when history taking begins on a patient.
signal history_started(patient: Node)

## Emitted when history taking ends.
signal history_ended

## Emitted when a question is asked and response received.
signal response_received(category: String, question_key: String, question_label: String, response: String)

## Currently interviewed patient.
var _current_patient: Node = null

## Track asked questions per patient { patient_name: { category: [question_keys] } }.
var _asked_questions: Dictionary = {}

## Whether history mode is active.
var is_active: bool = false

## Available question definitions loaded from JSON.
var _question_defs: Dictionary = {}


func _ready() -> void:
	_load_question_definitions()


## Load question definitions from the data file.
func _load_question_definitions() -> void:
	var file := FileAccess.open("res://data/history_questions.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		var err := json.parse(file.get_as_text())
		if err == OK:
			_question_defs = json.data
		file.close()


## Begin history taking with the given patient.
func begin_history(patient: Node) -> void:
	if is_active:
		return
	_current_patient = patient
	is_active = true
	# Initialize tracking for this patient
	if not _asked_questions.has(patient.name):
		_asked_questions[patient.name] = {}
	history_started.emit(patient)


## End history taking and clean up.
func end_history() -> void:
	_current_patient = null
	is_active = false
	history_ended.emit()


## Get available SAMPLE category keys.
func get_categories() -> Array:
	return _question_defs.keys()


## Get question definitions for a specific category.
func get_questions_for_category(category: String) -> Array:
	return _question_defs.get(category, [])


## Get all question definitions (for UI to build from).
func get_all_question_data() -> Dictionary:
	return _question_defs


## Ask a question to the current patient. Returns the response text.
func ask_question(category: String, question_key: String) -> String:
	if not _current_patient:
		return ""

	# Find persona on the patient
	var persona: PatientPersona = null
	if "persona" in _current_patient:
		persona = _current_patient.persona
	if not persona:
		var persona_node: Node = _current_patient.get_node_or_null("PatientPersona")
		if persona_node and persona_node.has_method("get_history_response"):
			persona = persona_node.get("persona") as PatientPersona

	# Check if patient can respond
	if not persona or not persona.can_respond():
		var response := "Patient is unresponsive."
		_record_asked(category, question_key)
		var label := _get_label(category, question_key)
		response_received.emit(category, question_key, label, response)
		return response

	var response := persona.get_history_response(category, question_key)
	if response.is_empty():
		response = "..."
	_record_asked(category, question_key)
	var label := _get_label(category, question_key)
	response_received.emit(category, question_key, label, response)
	return response


## Check if a specific question has already been asked for the current patient.
func is_question_asked(category: String, question_key: String) -> bool:
	if not _current_patient:
		return false
	var patient_record: Dictionary = _asked_questions.get(_current_patient.name, {})
	var cat_record: Array = patient_record.get(category, [])
	return question_key in cat_record


## Record that a question was asked.
func _record_asked(category: String, question_key: String) -> void:
	if not _current_patient:
		return
	if not _asked_questions[_current_patient.name].has(category):
		_asked_questions[_current_patient.name][category] = []
	if question_key not in _asked_questions[_current_patient.name][category]:
		_asked_questions[_current_patient.name][category].append(question_key)


## Get the human-readable label for a question key.
func _get_label(category: String, question_key: String) -> String:
	for q: Dictionary in _question_defs.get(category, []):
		if q.get("key", "") == question_key:
			return q.get("label", question_key)
	return question_key
