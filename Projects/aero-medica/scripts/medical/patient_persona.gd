## PatientPersona — Resource class defining a patient's identity and medical state.
## Saved as .tres and attached to patient entities for per-patient customisation.
## Supports F12 persona injection via get_persona_prompt().
extends Resource
class_name PatientPersona

## Patient identity
@export var patient_name: String = "Unknown Patient"
@export var age: int = 30

## Medical assessment fields (AVPU scale + modifiers)
@export_enum("ALERT", "VERBAL", "PAIN", "UNRESPONSIVE") var consciousness_level: String = "ALERT"
@export_range(0, 10) var pain_level: int = 0
@export_range(0.0, 1.0) var panic_level: float = 0.0
@export_range(0.0, 1.0) var language_clarity: float = 1.0

## SAMPLE History — pre-written responses per category.
## Each category maps { question_key: response_text }.
@export var history_symptoms: Dictionary = {}
@export var history_allergies: Dictionary = {}
@export var history_medications: Dictionary = {}
@export var history_past: Dictionary = {}
@export var history_last_meal: Dictionary = {}
@export var history_events: Dictionary = {}
@export var history_opqrst: Dictionary = {}


## Returns a formatted prompt string for F12 LLM persona injection.
## Skeleton — returns placeholder description. Full implementation in Phase 3.
func get_persona_prompt() -> String:
	return "Patient: %s, Age: %d, Consciousness: %s, Pain: %d/10, Panic: %.1f, Clarity: %.1f" % [
		patient_name, age, consciousness_level, pain_level, panic_level, language_clarity
	]


## Get history response for a SAMPLE category and question key.
func get_history_response(category: String, question_key: String) -> String:
	var data: Dictionary
	match category:
		"symptoms": data = history_symptoms
		"allergies": data = history_allergies
		"medications": data = history_medications
		"past_history": data = history_past
		"last_meal": data = history_last_meal
		"events": data = history_events
		"opqrst": data = history_opqrst
		_: return ""
	return data.get(question_key, "")


## Get all history data as a single dictionary (for Ollama context).
func get_all_history() -> Dictionary:
	return {
		"symptoms": history_symptoms,
		"allergies": history_allergies,
		"medications": history_medications,
		"past_history": history_past,
		"last_meal": history_last_meal,
		"events": history_events,
		"opqrst": history_opqrst,
	}


## Whether the patient can respond to questions (conscious enough to speak).
func can_respond() -> bool:
	return consciousness_level in ["ALERT", "VERBAL"]
