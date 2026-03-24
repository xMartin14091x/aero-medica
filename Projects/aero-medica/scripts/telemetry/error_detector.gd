## ErrorDetector — Post-scenario error detection and categorisation.
## Detects player mistakes: wrong triage, skipped assessment, wrong priority, wrong equipment.
## Severity levels: CRITICAL, MAJOR, MINOR. Feeds error log into AI reviewer.
extends Node

## Error severity levels.
const SEVERITY_CRITICAL := "CRITICAL"
const SEVERITY_MAJOR := "MAJOR"
const SEVERITY_MINOR := "MINOR"

## Error type constants.
const ERROR_WRONG_TRIAGE := "WRONG_TRIAGE"
const ERROR_SKIPPED_ASSESSMENT := "SKIPPED_ASSESSMENT"
const ERROR_WRONG_PRIORITY := "WRONG_PRIORITY"
const ERROR_WRONG_EQUIPMENT := "WRONG_EQUIPMENT"
const ERROR_PROTOCOL_VIOLATION := "PROTOCOL_VIOLATION"
const ERROR_DELAYED_ACTION := "DELAYED_ACTION"

## Timing thresholds (seconds) for delay detection.
const DELAY_THRESHOLD_ASSESSMENT := 30.0
const DELAY_THRESHOLD_TREATMENT := 60.0
const DELAY_THRESHOLD_TRIAGE := 45.0


## Detect all errors from session telemetry and protocol analysis.
## Returns an array of error dictionaries.
func detect_errors(session_data: Dictionary, protocol_analysis: Dictionary) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	var events: Array = session_data.get("events", [])

	# Check triage errors
	errors.append_array(_detect_triage_errors(events))

	# Check skipped assessments from protocol analysis
	errors.append_array(_detect_skipped_assessments(protocol_analysis))

	# Check wrong priority (treated GREEN before RED)
	errors.append_array(_detect_priority_errors(protocol_analysis))

	# Check protocol violations (wrong order steps)
	errors.append_array(_detect_protocol_violations(protocol_analysis))

	# Check wrong equipment usage
	errors.append_array(_detect_equipment_errors(events))

	# Check delayed actions
	errors.append_array(_detect_delayed_actions(protocol_analysis))

	# Check missed critical actions (no CPR on cardiac arrest, etc.)
	errors.append_array(_detect_missed_critical(protocol_analysis))

	# Sort by severity: CRITICAL first, then MAJOR, then MINOR
	errors.sort_custom(_sort_by_severity)

	return errors


## Detect wrong triage tag assignments.
func _detect_triage_errors(events: Array) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []

	for event: Dictionary in events:
		if event.get("type", "") != "triage_assign":
			continue

		var details: Dictionary = event.get("details", {})
		var assigned: String = details.get("assigned_tag", "")
		var correct: String = details.get("correct_tag", "")
		var was_correct: bool = details.get("was_correct", true)

		if not was_correct:
			# CRITICAL: wrong tag on RED or BLACK patient
			var severity := SEVERITY_MAJOR
			if correct in ["RED", "BLACK"]:
				severity = SEVERITY_CRITICAL

			errors.append({
				"type": ERROR_WRONG_TRIAGE,
				"severity": severity,
				"patient_id": event.get("target", ""),
				"description": "Assigned %s tag to patient requiring %s" % [assigned, correct],
				"timestamp": event.get("timestamp", 0.0),
				"details": {
					"assigned_tag": assigned,
					"correct_tag": correct,
				},
			})

	return errors


## Detect skipped assessment steps from protocol analysis.
func _detect_skipped_assessments(protocol_analysis: Dictionary) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	var patient_reports: Array = protocol_analysis.get("patient_reports", [])

	for report: Dictionary in patient_reports:
		var missed: Array = report.get("missed_steps", [])
		var patient_id: String = report.get("patient_id", "")

		for step: String in missed:
			if step.begins_with("assess_") or step == "assess_consciousness":
				errors.append({
					"type": ERROR_SKIPPED_ASSESSMENT,
					"severity": SEVERITY_MAJOR,
					"patient_id": patient_id,
					"description": "Skipped assessment step: %s" % step,
					"timestamp": 0.0,
					"details": {"missed_step": step},
				})

	return errors


## Detect wrong patient prioritisation.
func _detect_priority_errors(protocol_analysis: Dictionary) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	var prioritisation: Dictionary = protocol_analysis.get("prioritisation", {})
	var details: Array = prioritisation.get("details", [])

	for detail: String in details:
		errors.append({
			"type": ERROR_WRONG_PRIORITY,
			"severity": SEVERITY_CRITICAL,
			"patient_id": "",
			"description": detail,
			"timestamp": 0.0,
			"details": {},
		})

	return errors


## Detect protocol order violations.
func _detect_protocol_violations(protocol_analysis: Dictionary) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	var patient_reports: Array = protocol_analysis.get("patient_reports", [])

	for report: Dictionary in patient_reports:
		var wrong_order: Array = report.get("wrong_order_steps", [])
		var patient_id: String = report.get("patient_id", "")

		for step: String in wrong_order:
			errors.append({
				"type": ERROR_PROTOCOL_VIOLATION,
				"severity": SEVERITY_MAJOR,
				"patient_id": patient_id,
				"description": "Step '%s' performed out of protocol order" % step,
				"timestamp": 0.0,
				"details": {"step": step},
			})

	return errors


## Detect wrong equipment usage from telemetry.
func _detect_equipment_errors(events: Array) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []

	for event: Dictionary in events:
		if event.get("type", "") != "treatment_applied":
			continue

		var details: Dictionary = event.get("details", {})
		var was_correct: bool = details.get("was_correct", true)

		if not was_correct:
			errors.append({
				"type": ERROR_WRONG_EQUIPMENT,
				"severity": SEVERITY_MAJOR,
				"patient_id": event.get("target", ""),
				"description": "Used '%s' — treatment was not effective for this condition" % details.get("equipment_name", "unknown"),
				"timestamp": event.get("timestamp", 0.0),
				"details": details,
			})

	return errors


## Detect delayed actions based on timing thresholds.
func _detect_delayed_actions(protocol_analysis: Dictionary) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	var timing: Dictionary = protocol_analysis.get("timing", {})

	var first_assessment: float = timing.get("time_to_first_assessment", -1.0)
	var first_treatment: float = timing.get("time_to_first_treatment", -1.0)
	var first_triage: float = timing.get("time_to_first_triage", -1.0)

	if first_assessment > DELAY_THRESHOLD_ASSESSMENT:
		errors.append({
			"type": ERROR_DELAYED_ACTION,
			"severity": SEVERITY_MINOR,
			"patient_id": "",
			"description": "First assessment took %.0f seconds (threshold: %.0f)" % [first_assessment, DELAY_THRESHOLD_ASSESSMENT],
			"timestamp": first_assessment,
			"details": {"action": "first_assessment", "time": first_assessment},
		})

	if first_treatment > DELAY_THRESHOLD_TREATMENT and first_treatment > 0:
		errors.append({
			"type": ERROR_DELAYED_ACTION,
			"severity": SEVERITY_MINOR,
			"patient_id": "",
			"description": "First treatment took %.0f seconds (threshold: %.0f)" % [first_treatment, DELAY_THRESHOLD_TREATMENT],
			"timestamp": first_treatment,
			"details": {"action": "first_treatment", "time": first_treatment},
		})

	if first_triage > DELAY_THRESHOLD_TRIAGE and first_triage > 0:
		errors.append({
			"type": ERROR_DELAYED_ACTION,
			"severity": SEVERITY_MINOR,
			"patient_id": "",
			"description": "First triage took %.0f seconds (threshold: %.0f)" % [first_triage, DELAY_THRESHOLD_TRIAGE],
			"timestamp": first_triage,
			"details": {"action": "first_triage", "time": first_triage},
		})

	return errors


## Detect missed critical actions (e.g., no CPR on cardiac arrest patient).
func _detect_missed_critical(protocol_analysis: Dictionary) -> Array[Dictionary]:
	var errors: Array[Dictionary] = []
	var patient_reports: Array = protocol_analysis.get("patient_reports", [])

	for report: Dictionary in patient_reports:
		var missed_critical: Array = report.get("missed_critical", [])
		var patient_id: String = report.get("patient_id", "")

		for action: String in missed_critical:
			var description := "Critical protocol step '%s' was not performed" % action
			if action == "cpr":
				description = "No CPR performed on patient requiring cardiac life support"
			elif action == "aed":
				description = "AED not applied to patient in cardiac arrest"
			elif action == "assess_breathing":
				description = "Breathing assessment not performed"
			elif action == "assess_pulse":
				description = "Pulse check not performed"

			errors.append({
				"type": ERROR_PROTOCOL_VIOLATION,
				"severity": SEVERITY_CRITICAL,
				"patient_id": patient_id,
				"description": description,
				"timestamp": 0.0,
				"details": {"missed_critical_action": action},
			})

	return errors


## Sort errors by severity (CRITICAL first).
func _sort_by_severity(a: Dictionary, b: Dictionary) -> bool:
	var priority := {SEVERITY_CRITICAL: 0, SEVERITY_MAJOR: 1, SEVERITY_MINOR: 2}
	var a_priority: int = priority.get(a.get("severity", SEVERITY_MINOR), 2)
	var b_priority: int = priority.get(b.get("severity", SEVERITY_MINOR), 2)
	return a_priority < b_priority


## Get a summary of errors by severity.
func get_error_summary(errors: Array) -> Dictionary:
	var critical := 0
	var major := 0
	var minor := 0

	for error: Dictionary in errors:
		match error.get("severity", ""):
			SEVERITY_CRITICAL:
				critical += 1
			SEVERITY_MAJOR:
				major += 1
			SEVERITY_MINOR:
				minor += 1

	return {
		"total": errors.size(),
		"critical": critical,
		"major": major,
		"minor": minor,
	}
