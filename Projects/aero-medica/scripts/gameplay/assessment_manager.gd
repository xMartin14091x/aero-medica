## AssessmentManager — Handles patient assessment action flow.
## When the player interacts with a patient (empty hands), enters assessment mode.
## Reads patient state from MedicalStateComponent and logs findings in telemetry.
extends Node

## Assessment action types the player can perform.
enum AssessmentAction {
	CHECK_AIRWAY,
	CHECK_BREATHING,
	CHECK_PULSE,
	CHECK_CONSCIOUSNESS,
	CHECK_BLEEDING,
	CHECK_HEART_RATE,
	CHECK_BLOOD_PRESSURE,
	CHECK_SPO2,
	CHECK_PUPILS,
	CHECK_TEMPERATURE,
	CHECK_BLOOD_GLUCOSE,
	CHECK_CAPILLARY_REFILL,
	CHECK_SKIN,
}

## Human-readable labels for each assessment action.
const ACTION_LABELS := {
	AssessmentAction.CHECK_AIRWAY: "Check Airway",
	AssessmentAction.CHECK_BREATHING: "Check Breathing",
	AssessmentAction.CHECK_PULSE: "Check Pulse",
	AssessmentAction.CHECK_CONSCIOUSNESS: "Check Consciousness",
	AssessmentAction.CHECK_BLEEDING: "Check Bleeding",
	AssessmentAction.CHECK_HEART_RATE: "Check Heart Rate",
	AssessmentAction.CHECK_BLOOD_PRESSURE: "Check Blood Pressure",
	AssessmentAction.CHECK_SPO2: "Check SpO2",
	AssessmentAction.CHECK_PUPILS: "Check Pupils",
	AssessmentAction.CHECK_TEMPERATURE: "Check Temperature",
	AssessmentAction.CHECK_BLOOD_GLUCOSE: "Check Blood Glucose",
	AssessmentAction.CHECK_CAPILLARY_REFILL: "Check Capillary Refill",
	AssessmentAction.CHECK_SKIN: "Check Skin",
}

## Telemetry event names for each assessment action.
const ACTION_TELEMETRY := {
	AssessmentAction.CHECK_AIRWAY: "assess_airway",
	AssessmentAction.CHECK_BREATHING: "assess_breathing",
	AssessmentAction.CHECK_PULSE: "assess_pulse",
	AssessmentAction.CHECK_CONSCIOUSNESS: "assess_consciousness",
	AssessmentAction.CHECK_BLEEDING: "assess_bleeding",
	AssessmentAction.CHECK_HEART_RATE: "assess_heart_rate",
	AssessmentAction.CHECK_BLOOD_PRESSURE: "assess_blood_pressure",
	AssessmentAction.CHECK_SPO2: "assess_spo2",
	AssessmentAction.CHECK_PUPILS: "assess_pupils",
	AssessmentAction.CHECK_TEMPERATURE: "assess_temperature",
	AssessmentAction.CHECK_BLOOD_GLUCOSE: "assess_blood_glucose",
	AssessmentAction.CHECK_CAPILLARY_REFILL: "assess_capillary_refill",
	AssessmentAction.CHECK_SKIN: "assess_skin",
}

## Equipment requirements for gated assessments.
## Key = AssessmentAction enum value, Value = { "key": equipment_key, "display": display_name }
const EQUIPMENT_REQUIREMENTS := {
	AssessmentAction.CHECK_BLOOD_PRESSURE: { "key": "BP_CUFF", "display": "Blood Pressure Cuff" },
	AssessmentAction.CHECK_SPO2: { "key": "PULSE_OXIMETER", "display": "Pulse Oximeter" },
	AssessmentAction.CHECK_PUPILS: { "key": "PENLIGHT", "display": "Penlight" },
	AssessmentAction.CHECK_TEMPERATURE: { "key": "THERMOMETER", "display": "Thermometer" },
	AssessmentAction.CHECK_BLOOD_GLUCOSE: { "key": "GLUCOMETER", "display": "Glucometer" },
}

## Emitted when an assessment action is performed on a patient.
signal assessment_performed(patient: Node, action_type: String, result: Dictionary)

## Emitted when assessment mode begins on a patient.
signal assessment_started(patient: Node)

## Emitted when assessment mode ends.
signal assessment_ended(patient: Node)

## Emitted when a gated assessment is attempted without the required equipment.
signal assessment_equipment_required(action_name: String, equipment_name: String)

## Whether the player is currently in assessment mode.
var in_assessment: bool = false

## The patient currently being assessed.
var _current_patient: Node = null

## Reference to TelemetryEmitter for logging.
@onready var _telemetry: Node = _find_sibling("TelemetryEmitter")

## All available assessment actions (exposed for UI/ARC-01 to read).
var available_actions: Array[int] = [
	AssessmentAction.CHECK_AIRWAY,
	AssessmentAction.CHECK_BREATHING,
	AssessmentAction.CHECK_PULSE,
	AssessmentAction.CHECK_CONSCIOUSNESS,
	AssessmentAction.CHECK_BLEEDING,
	AssessmentAction.CHECK_HEART_RATE,
	AssessmentAction.CHECK_BLOOD_PRESSURE,
	AssessmentAction.CHECK_SPO2,
	AssessmentAction.CHECK_PUPILS,
	AssessmentAction.CHECK_TEMPERATURE,
	AssessmentAction.CHECK_BLOOD_GLUCOSE,
	AssessmentAction.CHECK_CAPILLARY_REFILL,
	AssessmentAction.CHECK_SKIN,
]


## Enter assessment mode for the given patient.
## Called by InteractionManager when player interacts with a patient (empty hands).
func begin_assessment(patient: Node) -> void:
	if in_assessment:
		end_assessment()

	_current_patient = patient
	in_assessment = true
	assessment_started.emit(patient)


## Exit assessment mode.
func end_assessment() -> void:
	if not in_assessment:
		return
	var patient := _current_patient
	in_assessment = false
	_current_patient = null
	assessment_ended.emit(patient)


## Perform a specific assessment action on the current patient.
## Returns the assessment result dictionary.
func perform_assessment(action: AssessmentAction) -> Dictionary:
	if not in_assessment or not _current_patient:
		return {}

	var medical_state := _get_medical_state(_current_patient)
	if not medical_state:
		return {}

	# Check equipment gating before reading data
	var equipment_check := _check_equipment_requirement(action, _current_patient)
	if not equipment_check.is_empty():
		return equipment_check

	var result := _read_assessment(action, medical_state)
	var action_name: String = ACTION_TELEMETRY[action]

	# Store what the player has assessed on the patient
	_store_assessed_condition(_current_patient, action, result)

	# Emit signal for UI and other systems
	assessment_performed.emit(_current_patient, action_name, result)

	# Log to telemetry
	if _telemetry and _telemetry.has_method("emit_action"):
		_telemetry.emit_action(action_name, _current_patient.name, result)

	return result


## Check if the required equipment is deployed on the patient for a gated action.
## Returns an error dict if equipment is missing, or empty dict if OK to proceed.
func _check_equipment_requirement(action: AssessmentAction, patient: Node) -> Dictionary:
	if not EQUIPMENT_REQUIREMENTS.has(action):
		return {}
	var req: Dictionary = EQUIPMENT_REQUIREMENTS[action]
	var deployed: Array = patient.get_meta("deployed_equipment", [])
	if req["key"] not in deployed:
		var action_name: String = ACTION_TELEMETRY[action]
		assessment_equipment_required.emit(action_name, req["display"])
		return {
			"error": "Requires: %s — check your medical bag" % req["display"]
		}
	return {}


## Read the relevant medical data for the given assessment action.
func _read_assessment(action: AssessmentAction, medical_state: Node) -> Dictionary:
	match action:
		AssessmentAction.CHECK_AIRWAY:
			return {
				"airway_status": medical_state.airway_status,
			}
		AssessmentAction.CHECK_BREATHING:
			return {
				"breathing_rate": medical_state.breathing_rate,
				"breathing_normal": medical_state.breathing_rate >= 12.0 and medical_state.breathing_rate <= 20.0,
			}
		AssessmentAction.CHECK_PULSE:
			return {
				"pulse_present": medical_state.pulse_present,
			}
		AssessmentAction.CHECK_CONSCIOUSNESS:
			# AVPU scale from PatientPersona or MedicalStateComponent
			var state_name: String = medical_state.PatientState.keys()[medical_state.current_state]
			var avpu := "ALERT"
			match medical_state.current_state:
				medical_state.PatientState.CONSCIOUS:
					avpu = "ALERT"
				medical_state.PatientState.UNCONSCIOUS:
					avpu = "UNRESPONSIVE"
				medical_state.PatientState.CARDIAC_ARREST:
					avpu = "UNRESPONSIVE"
				medical_state.PatientState.DEAD:
					avpu = "UNRESPONSIVE"
			return {
				"consciousness": avpu,
				"state": state_name,
			}
		AssessmentAction.CHECK_BLEEDING:
			return {
				"bleeding_severity": medical_state.bleeding_severity,
				"bleeding_present": medical_state.bleeding_severity > 0,
			}
		AssessmentAction.CHECK_HEART_RATE:
			# No equipment needed — manual radial/carotid pulse count
			var regular: bool = medical_state.ecg_rhythm in ["NORMAL_SINUS", "SINUS_TACHYCARDIA", "SINUS_BRADYCARDIA"]
			return {
				"heart_rate": medical_state.heart_rate,
				"regular": regular,
			}
		AssessmentAction.CHECK_BLOOD_PRESSURE:
			# Requires BP_CUFF — gated above
			var map_val: int = int((medical_state.blood_pressure_systolic + 2 * medical_state.blood_pressure_diastolic) / 3.0)
			return {
				"systolic": medical_state.blood_pressure_systolic,
				"diastolic": medical_state.blood_pressure_diastolic,
				"map": map_val,
			}
		AssessmentAction.CHECK_SPO2:
			# Requires PULSE_OXIMETER — gated above
			var co_warn: bool = medical_state.co_exposure
			return {
				"spo2": medical_state.spo2,
				"co_warning": co_warn,
			}
		AssessmentAction.CHECK_PUPILS:
			# Requires PENLIGHT — gated above
			return {
				"left_size": medical_state.pupil_left_size,
				"left_reactive": medical_state.pupil_left_reactive,
				"right_size": medical_state.pupil_right_size,
				"right_reactive": medical_state.pupil_right_reactive,
				"equal": medical_state.pupil_left_size == medical_state.pupil_right_size,
			}
		AssessmentAction.CHECK_TEMPERATURE:
			# Requires THERMOMETER — gated above
			return {
				"temperature": medical_state.temperature,
				"unit": "C",
			}
		AssessmentAction.CHECK_BLOOD_GLUCOSE:
			# Requires GLUCOMETER — gated above
			return {
				"glucose": medical_state.blood_glucose,
			}
		AssessmentAction.CHECK_CAPILLARY_REFILL:
			# No equipment needed — manual press and release
			var normal: bool = medical_state.capillary_refill <= 2.0
			return {
				"refill_seconds": medical_state.capillary_refill,
				"normal": normal,
			}
		AssessmentAction.CHECK_SKIN:
			# No equipment needed — visual and tactile inspection
			var shock_signs: bool = (
				medical_state.skin_color in ["PALE", "CYANOTIC", "MOTTLED"] or
				medical_state.skin_temperature in ["COOL", "COLD"] or
				medical_state.skin_moisture == "DIAPHORETIC"
			)
			return {
				"color": medical_state.skin_color,
				"temperature": medical_state.skin_temperature,
				"moisture": medical_state.skin_moisture,
				"shock_signs": shock_signs,
			}

	return {}


## Store an assessed condition on the patient entity for tracking what has been checked.
func _store_assessed_condition(patient: Node, action: AssessmentAction, result: Dictionary) -> void:
	# Initialize tracking dictionary if not present
	if not patient.has_meta("assessed_conditions"):
		patient.set_meta("assessed_conditions", {})

	var conditions: Dictionary = patient.get_meta("assessed_conditions")
	conditions[ACTION_TELEMETRY[action]] = result
	patient.set_meta("assessed_conditions", conditions)


## Get the assessed conditions dictionary from a patient (for external systems to query).
static func get_assessed_conditions(patient: Node) -> Dictionary:
	if patient.has_meta("assessed_conditions"):
		return patient.get_meta("assessed_conditions")
	return {}


## Find the MedicalStateComponent child node on a patient entity.
func _get_medical_state(patient: Node) -> Node:
	var state_node: Node = patient.get_node_or_null("MedicalStateComponent")
	if state_node:
		return state_node
	# Fallback: search children
	for child in patient.get_children():
		if child.name == "MedicalStateComponent" or child.has_method("get_state_summary"):
			return child
	return null


## Convenience: perform assessment by label string (matches ActionMenu's action names).
## E.g., "Check Airway" → CHECK_AIRWAY. Returns result dictionary.
func perform_assessment_by_name(action_name: String) -> Dictionary:
	for action_enum in ACTION_LABELS:
		if ACTION_LABELS[action_enum] == action_name:
			return perform_assessment(action_enum)
	return {}


## Get a human-readable label for an assessment action.
func get_action_label(action: AssessmentAction) -> String:
	return ACTION_LABELS.get(action, "Unknown")


## Find a sibling node by name.
func _find_sibling(node_name: String) -> Node:
	var parent: Node = get_parent()
	if parent:
		return parent.get_node_or_null(node_name)
	return null
