## ProtocolValidator — Validates player action sequences against gold-standard protocols.
## Loads BCLS/ALS protocol definitions from JSON and scores player adherence.
extends Node

## Loaded protocol definitions. Key = protocol_id, Value = parsed JSON dict.
var _protocols: Dictionary = {}

## Protocol data file paths.
const PROTOCOL_PATHS := {
	"BCLS": "res://data/protocols/bcls_protocol.json",
	"ALS": "res://data/protocols/als_protocol.json",
	"START": "res://data/protocols/start_triage.json",
}


func _ready() -> void:
	_load_all_protocols()


## Load all protocol JSON files into memory.
func _load_all_protocols() -> void:
	for protocol_id: String in PROTOCOL_PATHS:
		var path: String = PROTOCOL_PATHS[protocol_id]
		var file := FileAccess.open(path, FileAccess.READ)
		if not file:
			push_warning("ProtocolValidator: Cannot open %s" % path)
			continue
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			_protocols[protocol_id] = json.data
		else:
			push_warning("ProtocolValidator: Parse error in %s: %s" % [path, json.get_error_message()])


## Get the appropriate protocol for a patient's current medical state.
## Cardiac arrest → BCLS (or ALS if advanced equipment available).
## Other states → general assessment sequence.
func get_protocol_for_state(medical_state: Node) -> String:
	if medical_state.current_state == medical_state.PatientState.CARDIAC_ARREST:
		return "BCLS"
	if not medical_state.pulse_present:
		return "BCLS"
	return "BCLS"  # Default to BLS for all cases


## Validate a sequence of player actions against the gold-standard protocol.
## Returns a results dictionary with adherence scoring.
##
## player_actions: Array of action strings in order performed (e.g., ["assess_consciousness", "assess_breathing", "cpr"])
## protocol_id: Which protocol to validate against ("BCLS" or "ALS")
func validate_sequence(patient_state: Node, player_actions: Array, protocol_id: String = "") -> Dictionary:
	if protocol_id == "":
		protocol_id = get_protocol_for_state(patient_state)

	if protocol_id not in _protocols:
		return _empty_result(protocol_id)

	var protocol: Dictionary = _protocols[protocol_id]
	var steps: Array = protocol.get("steps", [])
	var critical_actions: Array = protocol.get("critical_actions", [])

	# Build the expected action sequence for this patient's state
	var expected_actions: Array[String] = []
	for step: Dictionary in steps:
		var action: String = step.get("action", "")
		if _step_applies_to_state(step, patient_state):
			expected_actions.append(action)

	# Compare player actions against expected sequence (order-sensitive)
	var correct_steps: Array[String] = []
	var missed_steps: Array[String] = []
	var wrong_order_steps: Array[String] = []
	var extra_steps: Array[String] = []

	var expected_index := 0
	var matched_expected: Array[String] = []

	for player_action: String in player_actions:
		var found_in_expected := false
		for i in range(expected_actions.size()):
			if expected_actions[i] == player_action and player_action not in matched_expected:
				matched_expected.append(player_action)
				found_in_expected = true
				if i >= expected_index:
					correct_steps.append(player_action)
					expected_index = i + 1
				else:
					wrong_order_steps.append(player_action)
				break

		if not found_in_expected:
			if player_action not in matched_expected:
				extra_steps.append(player_action)

	# Find missed steps (in expected but not performed)
	for action: String in expected_actions:
		if action not in matched_expected:
			missed_steps.append(action)

	# Calculate missed critical actions
	var missed_critical: Array[String] = []
	for critical: String in critical_actions:
		if critical in expected_actions and critical not in matched_expected:
			missed_critical.append(critical)

	# Calculate adherence percentage
	var total_expected := expected_actions.size()
	var adherence := 0.0
	if total_expected > 0:
		# Correct steps in right order = full credit
		# Wrong order = half credit
		var score := correct_steps.size() + (wrong_order_steps.size() * 0.5)
		adherence = (score / total_expected) * 100.0

	return {
		"protocol_id": protocol_id,
		"correct_steps": correct_steps,
		"missed_steps": missed_steps,
		"wrong_order_steps": wrong_order_steps,
		"extra_steps": extra_steps,
		"missed_critical": missed_critical,
		"adherence_percentage": adherence,
		"total_expected": total_expected,
		"total_performed": player_actions.size(),
	}


## Check if a protocol step applies to the given patient state.
func _step_applies_to_state(step: Dictionary, medical_state: Node) -> bool:
	var condition: String = step.get("condition", "always")

	match condition:
		"always":
			return true
		"patient_unresponsive":
			return medical_state.current_state != medical_state.PatientState.CONSCIOUS
		"no_normal_breathing":
			return medical_state.breathing_rate < 8.0 or medical_state.breathing_rate > 30.0
		"no_pulse":
			return not medical_state.pulse_present
		"airway_obstructed":
			return medical_state.airway_status == "OBSTRUCTED"
		"shockable_rhythm":
			return not medical_state.pulse_present
		"breathing_inadequate":
			return medical_state.breathing_rate < 12.0
		"after_treatment":
			return true  # Reassessment always applies

	return true


## Get protocol step data for a specific action in a protocol.
func get_step_data(protocol_id: String, action: String) -> Dictionary:
	if protocol_id not in _protocols:
		return {}
	var steps: Array = _protocols[protocol_id].get("steps", [])
	for step: Dictionary in steps:
		if step.get("action", "") == action:
			return step
	return {}


## Get the full protocol definition dictionary.
func get_protocol(protocol_id: String) -> Dictionary:
	return _protocols.get(protocol_id, {})


## Get the START triage decision tree.
func get_start_triage_tree() -> Dictionary:
	if "START" in _protocols:
		return _protocols["START"].get("decision_tree", {})
	return {}


## Empty result for missing protocols.
func _empty_result(protocol_id: String) -> Dictionary:
	return {
		"protocol_id": protocol_id,
		"correct_steps": [],
		"missed_steps": [],
		"wrong_order_steps": [],
		"extra_steps": [],
		"missed_critical": [],
		"adherence_percentage": 0.0,
		"total_expected": 0,
		"total_performed": 0,
	}
