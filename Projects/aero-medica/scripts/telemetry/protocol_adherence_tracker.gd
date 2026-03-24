## ProtocolAdherenceTracker — Post-scenario analysis of player protocol adherence.
## Compares player action sequences against gold-standard BCLS/ALS protocols.
## Generates per-patient adherence reports for AI reviewer consumption.
extends Node

## Reference to ProtocolValidator for sequence validation.
var _validator: Node = null


func _ready() -> void:
	# ProtocolValidator may be an autoload or sibling — find it
	_validator = get_node_or_null("/root/ProtocolValidator")
	if not _validator:
		# Create one if not registered as autoload
		_validator = load("res://scripts/medical/protocol_validator.gd").new()
		add_child(_validator)


## Analyse a complete session's telemetry data.
## Returns a full adherence report dictionary.
func analyse_session(session_data: Dictionary) -> Dictionary:
	var events: Array = session_data.get("events", [])
	var duration: float = session_data.get("duration_seconds", 0.0)

	# Group events by patient
	var patient_events := _group_events_by_patient(events)

	# Analyse each patient's treatment sequence
	var patient_reports: Array[Dictionary] = []
	for patient_id: String in patient_events:
		var report := _analyse_patient(patient_id, patient_events[patient_id], events)
		patient_reports.append(report)

	# Prioritisation analysis — did the player treat critical patients first?
	var prioritisation := _analyse_prioritisation(events, patient_reports)

	# Overall timing metrics
	var timing := _analyse_timing(events, duration)

	return {
		"scenario_id": session_data.get("scenario_id", ""),
		"duration_seconds": duration,
		"patient_reports": patient_reports,
		"prioritisation": prioritisation,
		"timing": timing,
		"overall_adherence": _calculate_overall_adherence(patient_reports),
	}


## Group telemetry events by patient target.
func _group_events_by_patient(events: Array) -> Dictionary:
	var grouped: Dictionary = {}

	for event: Dictionary in events:
		var target: String = event.get("target", "")
		var event_type: String = event.get("type", "")

		# Skip non-patient events
		if event_type in ["scenario_started", "scenario_ended", "scenario_time_expired"]:
			continue

		if target == "" or target == "timer":
			continue

		if target not in grouped:
			grouped[target] = []
		grouped[target].append(event)

	return grouped


## Analyse a single patient's action sequence against protocol.
func _analyse_patient(patient_id: String, events: Array, all_events: Array) -> Dictionary:
	# Extract player action sequence in order
	var player_actions: Array[String] = []
	var action_timestamps: Dictionary = {}

	for event: Dictionary in events:
		var action: String = event.get("type", "")
		var timestamp: float = event.get("timestamp", 0.0)

		# Map telemetry event types to protocol action names
		var mapped := _map_event_to_protocol_action(action, event)
		if mapped != "":
			player_actions.append(mapped)
			if mapped not in action_timestamps:
				action_timestamps[mapped] = timestamp

	# Get patient's final medical state from events
	var patient_state_info := _get_patient_state_from_events(patient_id, all_events)

	# Determine which protocol applies
	var protocol_id := "BCLS"
	if patient_state_info.get("had_cardiac_arrest", false):
		protocol_id = "BCLS"

	# Validate sequence using ProtocolValidator logic
	var validation := _validate_actions(player_actions, protocol_id, patient_state_info)

	# Timing analysis per patient
	var first_interaction := _get_first_interaction_time(patient_id, all_events)
	var first_assessment := _get_first_assessment_time(events)
	var first_treatment := _get_first_treatment_time(events)
	var triage_time := _get_triage_time(events)

	return {
		"patient_id": patient_id,
		"protocol_id": protocol_id,
		"player_actions": player_actions,
		"correct_steps": validation.get("correct_steps", []),
		"missed_steps": validation.get("missed_steps", []),
		"wrong_order_steps": validation.get("wrong_order_steps", []),
		"unnecessary_steps": validation.get("extra_steps", []),
		"adherence_percentage": validation.get("adherence_percentage", 0.0),
		"missed_critical": validation.get("missed_critical", []),
		"timing": {
			"time_to_first_interaction": first_interaction,
			"time_to_first_assessment": first_assessment,
			"time_to_first_treatment": first_treatment,
			"time_to_triage": triage_time,
		},
	}


## Map a telemetry event type to a protocol action name.
func _map_event_to_protocol_action(event_type: String, event: Dictionary) -> String:
	var details: Dictionary = event.get("details", {})

	match event_type:
		"assess_consciousness":
			return "assess_consciousness"
		"assess_breathing":
			return "assess_breathing"
		"assess_pulse":
			return "assess_pulse"
		"assess_airway":
			return "head_tilt_chin_lift"  # Airway assessment implies checking airway
		"assess_bleeding":
			return "assess_bleeding"
		"treatment_applied":
			var equip_name: String = details.get("equipment_name", "")
			if "AED" in equip_name.to_upper():
				return "aed"
			if "BANDAGE" in equip_name.to_upper():
				return "apply_bandage"
			if "OXYGEN" in equip_name.to_upper() or "MASK" in equip_name.to_upper():
				return "oxygen_mask"
			return "treatment"
		"triage_assign":
			return "triage"
		"interact":
			return ""  # Generic interaction, not a protocol step

	return ""


## Validate player actions against a protocol using embedded logic.
## Uses the same algorithm as ProtocolValidator but works with event-derived data.
func _validate_actions(player_actions: Array, protocol_id: String, patient_state: Dictionary) -> Dictionary:
	# Define expected sequences based on protocol and patient state
	var expected: Array[String] = _get_expected_sequence(protocol_id, patient_state)

	var correct: Array[String] = []
	var wrong_order: Array[String] = []
	var extra: Array[String] = []
	var matched: Array[String] = []

	var expected_index := 0
	for action: String in player_actions:
		var found := false
		for i in range(expected.size()):
			if expected[i] == action and action not in matched:
				matched.append(action)
				found = true
				if i >= expected_index:
					correct.append(action)
					expected_index = i + 1
				else:
					wrong_order.append(action)
				break
		if not found and action not in matched:
			extra.append(action)

	var missed: Array[String] = []
	for step: String in expected:
		if step not in matched:
			missed.append(step)

	# Critical actions for BLS
	var critical := ["assess_breathing", "assess_pulse", "cpr", "aed"]
	var missed_critical: Array[String] = []
	for c: String in critical:
		if c in expected and c not in matched:
			missed_critical.append(c)

	var total := expected.size()
	var adherence := 0.0
	if total > 0:
		adherence = ((correct.size() + wrong_order.size() * 0.5) / total) * 100.0

	return {
		"correct_steps": correct,
		"missed_steps": missed,
		"wrong_order_steps": wrong_order,
		"extra_steps": extra,
		"missed_critical": missed_critical,
		"adherence_percentage": adherence,
	}


## Get expected protocol sequence based on patient state.
func _get_expected_sequence(protocol_id: String, patient_state: Dictionary) -> Array[String]:
	var seq: Array[String] = []

	if protocol_id == "BCLS":
		seq.append("assess_consciousness")
		seq.append("assess_breathing")
		seq.append("assess_pulse")

		if patient_state.get("airway_obstructed", false):
			seq.append("head_tilt_chin_lift")
		if patient_state.get("no_pulse", false) or patient_state.get("had_cardiac_arrest", false):
			seq.append("cpr")
			seq.append("aed")
		if patient_state.get("bleeding", false):
			seq.append("apply_bandage")

		seq.append("reassess")

	return seq


## Extract patient state info from telemetry events.
func _get_patient_state_from_events(patient_id: String, events: Array) -> Dictionary:
	var info := {
		"had_cardiac_arrest": false,
		"no_pulse": false,
		"airway_obstructed": false,
		"bleeding": false,
	}

	for event: Dictionary in events:
		if event.get("target", "") != patient_id:
			continue
		var event_type: String = event.get("type", "")
		var details: Dictionary = event.get("details", {})

		if event_type == "patient_state_changed":
			if details.get("new_state", "") == "CARDIAC_ARREST":
				info["had_cardiac_arrest"] = true
		if event_type == "assess_pulse":
			if details.get("pulse_present", true) == false:
				info["no_pulse"] = true
		if event_type == "assess_airway":
			if details.get("airway_status", "CLEAR") == "OBSTRUCTED":
				info["airway_obstructed"] = true
		if event_type == "assess_bleeding":
			if details.get("bleeding_present", false) == true:
				info["bleeding"] = true

	return info


## Analyse patient prioritisation — did the player treat critical patients first?
func _analyse_prioritisation(events: Array, patient_reports: Array) -> Dictionary:
	# Build a priority order from triage events
	var first_interaction_times: Dictionary = {}
	for event: Dictionary in events:
		var target: String = event.get("target", "")
		if target == "" or target in ["timer", ""]:
			continue
		if target not in first_interaction_times:
			first_interaction_times[target] = event.get("timestamp", 0.0)

	# Check triage tags to determine who should have been first
	var triage_order: Array[Dictionary] = []
	for event: Dictionary in events:
		if event.get("type", "") == "triage_assign":
			triage_order.append({
				"patient": event.get("target", ""),
				"correct_tag": event.get("details", {}).get("correct_tag", "GREEN"),
				"timestamp": event.get("timestamp", 0.0),
			})

	var priority_map := {"RED": 1, "YELLOW": 2, "GREEN": 3, "BLACK": 4}
	var correct_order := true
	var details: Array[String] = []

	for i in range(triage_order.size() - 1):
		var current_priority: int = priority_map.get(triage_order[i].get("correct_tag", "GREEN"), 3)
		var next_priority: int = priority_map.get(triage_order[i + 1].get("correct_tag", "GREEN"), 3)
		if current_priority > next_priority:
			correct_order = false
			details.append("Treated %s (priority %s) before %s (priority %s)" % [
				triage_order[i + 1].get("patient", "?"),
				triage_order[i + 1].get("correct_tag", "?"),
				triage_order[i].get("patient", "?"),
				triage_order[i].get("correct_tag", "?"),
			])

	return {
		"correct_order": correct_order,
		"details": details,
		"first_interaction_times": first_interaction_times,
	}


## Analyse overall timing metrics.
func _analyse_timing(events: Array, duration: float) -> Dictionary:
	var first_assessment_time := -1.0
	var first_triage_time := -1.0
	var first_treatment_time := -1.0

	for event: Dictionary in events:
		var event_type: String = event.get("type", "")
		var ts: float = event.get("timestamp", 0.0)

		if event_type.begins_with("assess_") and first_assessment_time < 0:
			first_assessment_time = ts
		if event_type == "triage_assign" and first_triage_time < 0:
			first_triage_time = ts
		if event_type == "treatment_applied" and first_treatment_time < 0:
			first_treatment_time = ts

	return {
		"scenario_duration": duration,
		"time_to_first_assessment": first_assessment_time,
		"time_to_first_triage": first_triage_time,
		"time_to_first_treatment": first_treatment_time,
	}


## Calculate overall adherence across all patients.
func _calculate_overall_adherence(patient_reports: Array) -> float:
	if patient_reports.size() == 0:
		return 0.0
	var total := 0.0
	for report: Dictionary in patient_reports:
		total += report.get("adherence_percentage", 0.0)
	return total / patient_reports.size()


## Get first interaction time for a specific patient.
func _get_first_interaction_time(patient_id: String, events: Array) -> float:
	for event: Dictionary in events:
		if event.get("target", "") == patient_id:
			return event.get("timestamp", -1.0)
	return -1.0


## Get first assessment time from patient events.
func _get_first_assessment_time(events: Array) -> float:
	for event: Dictionary in events:
		if event.get("type", "").begins_with("assess_"):
			return event.get("timestamp", -1.0)
	return -1.0


## Get first treatment time from patient events.
func _get_first_treatment_time(events: Array) -> float:
	for event: Dictionary in events:
		if event.get("type", "") == "treatment_applied":
			return event.get("timestamp", -1.0)
	return -1.0


## Get triage assignment time from patient events.
func _get_triage_time(events: Array) -> float:
	for event: Dictionary in events:
		if event.get("type", "") == "triage_assign":
			return event.get("timestamp", -1.0)
	return -1.0
