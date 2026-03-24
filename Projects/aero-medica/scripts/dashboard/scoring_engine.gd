## ScoringEngine — Calculates 5-axis clinical skill scores from session telemetry.
## Axes: Triage Speed, Protocol Accuracy, Decision Quality, Equipment Handling, Patient Outcome.
## Each axis 0-100 scale. Overall score is weighted average.
extends Node

## Configurable axis weights for overall score calculation.
@export var weight_triage_speed: float = 0.20
@export var weight_protocol_accuracy: float = 0.25
@export var weight_decision_quality: float = 0.20
@export var weight_equipment_handling: float = 0.15
@export var weight_patient_outcome: float = 0.20

## Pass/fail threshold per axis (default 60%).
@export var pass_threshold: float = 60.0

## Benchmark times (seconds) for triage speed scoring.
const BENCHMARK_FIRST_ASSESSMENT := 15.0  # Excellent if under 15s
const BENCHMARK_FIRST_TRIAGE := 30.0      # Excellent if under 30s
const BENCHMARK_MAX_ASSESSMENT := 60.0    # Zero score if over 60s
const BENCHMARK_MAX_TRIAGE := 120.0       # Zero score if over 120s


## Calculate all 5 axis scores from session data.
## session_data: raw telemetry from TelemetryCollector.end_session()
## protocol_analysis: output from ProtocolAdherenceTracker.analyse_session()
## errors: output from ErrorDetector.detect_errors()
func calculate_scores(session_data: Dictionary, protocol_analysis: Dictionary = {}, errors: Array = []) -> Dictionary:
	# If protocol_analysis not provided, use empty structure
	if protocol_analysis.is_empty():
		protocol_analysis = _empty_protocol_analysis()

	var triage_speed := _score_triage_speed(protocol_analysis)
	var protocol_accuracy := _score_protocol_accuracy(protocol_analysis)
	var decision_quality := _score_decision_quality(protocol_analysis, errors)
	var equipment_handling := _score_equipment_handling(session_data, errors)
	var patient_outcome := _score_patient_outcome(session_data, protocol_analysis)

	var overall := (
		triage_speed * weight_triage_speed +
		protocol_accuracy * weight_protocol_accuracy +
		decision_quality * weight_decision_quality +
		equipment_handling * weight_equipment_handling +
		patient_outcome * weight_patient_outcome
	)

	var scores := {
		"triage_speed": snappedf(triage_speed, 0.1),
		"protocol_accuracy": snappedf(protocol_accuracy, 0.1),
		"decision_quality": snappedf(decision_quality, 0.1),
		"equipment_handling": snappedf(equipment_handling, 0.1),
		"patient_outcome": snappedf(patient_outcome, 0.1),
		"overall": snappedf(overall, 0.1),
		"pass_fail": {},
	}

	# Per-axis pass/fail
	for axis: String in ["triage_speed", "protocol_accuracy", "decision_quality", "equipment_handling", "patient_outcome"]:
		scores["pass_fail"][axis] = scores[axis] >= pass_threshold

	scores["pass_fail"]["overall"] = scores["overall"] >= pass_threshold

	return scores


## Triage Speed (0-100): Based on time-to-first-assessment and time-to-triage.
func _score_triage_speed(protocol_analysis: Dictionary) -> float:
	var timing: Dictionary = protocol_analysis.get("timing", {})
	var first_assessment: float = timing.get("time_to_first_assessment", -1.0)
	var first_triage: float = timing.get("time_to_first_triage", -1.0)

	var assessment_score := 0.0
	var triage_score := 0.0

	# Assessment speed (50% of axis)
	if first_assessment < 0:
		assessment_score = 0.0  # Never assessed
	elif first_assessment <= BENCHMARK_FIRST_ASSESSMENT:
		assessment_score = 100.0
	elif first_assessment >= BENCHMARK_MAX_ASSESSMENT:
		assessment_score = 0.0
	else:
		# Linear interpolation between benchmark and max
		var range_total := BENCHMARK_MAX_ASSESSMENT - BENCHMARK_FIRST_ASSESSMENT
		var elapsed_past := first_assessment - BENCHMARK_FIRST_ASSESSMENT
		assessment_score = (1.0 - elapsed_past / range_total) * 100.0

	# Triage speed (50% of axis)
	if first_triage < 0:
		triage_score = 0.0  # Never triaged
	elif first_triage <= BENCHMARK_FIRST_TRIAGE:
		triage_score = 100.0
	elif first_triage >= BENCHMARK_MAX_TRIAGE:
		triage_score = 0.0
	else:
		var range_total := BENCHMARK_MAX_TRIAGE - BENCHMARK_FIRST_TRIAGE
		var elapsed_past := first_triage - BENCHMARK_FIRST_TRIAGE
		triage_score = (1.0 - elapsed_past / range_total) * 100.0

	return clampf(assessment_score * 0.5 + triage_score * 0.5, 0.0, 100.0)


## Protocol Accuracy (0-100): Based on protocol adherence percentage, penalised by wrong-order.
func _score_protocol_accuracy(protocol_analysis: Dictionary) -> float:
	var adherence: float = protocol_analysis.get("overall_adherence", 0.0)

	# Penalise for wrong-order steps across all patients
	var patient_reports: Array = protocol_analysis.get("patient_reports", [])
	var total_wrong_order := 0
	var total_expected := 0
	for report: Dictionary in patient_reports:
		total_wrong_order += report.get("wrong_order_steps", []).size()
		total_expected += report.get("correct_steps", []).size() + report.get("missed_steps", []).size() + report.get("wrong_order_steps", []).size()

	# Wrong-order penalty: each wrong-order step reduces score by 5 points
	var penalty := total_wrong_order * 5.0

	return clampf(adherence - penalty, 0.0, 100.0)


## Decision Quality (0-100): Patient prioritisation correctness.
func _score_decision_quality(protocol_analysis: Dictionary, errors: Array) -> float:
	var score := 100.0

	# Prioritisation check
	var prioritisation: Dictionary = protocol_analysis.get("prioritisation", {})
	if not prioritisation.get("correct_order", true):
		var details: Array = prioritisation.get("details", [])
		# Each priority mistake costs 20 points
		score -= details.size() * 20.0

	# Error-based deductions
	for error: Dictionary in errors:
		var error_type: String = error.get("type", "")
		var severity: String = error.get("severity", "")

		match error_type:
			"WRONG_PRIORITY":
				score -= 25.0 if severity == "CRITICAL" else 15.0
			"WRONG_TRIAGE":
				score -= 20.0 if severity == "CRITICAL" else 10.0
			"SKIPPED_ASSESSMENT":
				score -= 10.0

	return clampf(score, 0.0, 100.0)


## Equipment Handling (0-100): Correct equipment selection and usage.
func _score_equipment_handling(session_data: Dictionary, errors: Array) -> float:
	var events: Array = session_data.get("events", [])
	var total_uses := 0
	var correct_uses := 0

	for event: Dictionary in events:
		if event.get("type", "") == "treatment_applied":
			total_uses += 1
			var details: Dictionary = event.get("details", {})
			if details.get("was_correct", true):
				correct_uses += 1

	# Base score from correct usage ratio
	var score := 100.0
	if total_uses > 0:
		score = (float(correct_uses) / float(total_uses)) * 100.0
	elif events.size() > 0:
		# Had events but never used equipment — partial penalty
		score = 50.0

	# Additional penalty for WRONG_EQUIPMENT errors
	for error: Dictionary in errors:
		if error.get("type", "") == "WRONG_EQUIPMENT":
			score -= 15.0

	return clampf(score, 0.0, 100.0)


## Patient Outcome (0-100): Final patient states vs. best achievable.
func _score_patient_outcome(session_data: Dictionary, protocol_analysis: Dictionary) -> float:
	var events: Array = session_data.get("events", [])

	# Count patient final states from events
	var patient_states: Dictionary = {}  # patient_id → last known state
	for event: Dictionary in events:
		var event_type: String = event.get("type", "")
		var target: String = event.get("target", "")
		if event_type == "patient_state_changed":
			patient_states[target] = event.get("details", {}).get("new_state", "CONSCIOUS")

	if patient_states.is_empty():
		# No patient state changes recorded — check if any patients were assessed
		var patient_reports: Array = protocol_analysis.get("patient_reports", [])
		if patient_reports.is_empty():
			return 0.0  # No patients interacted with
		return 50.0  # Interacted but no state change data

	var total_patients := patient_states.size()
	var outcome_score := 0.0

	for patient_id: String in patient_states:
		var final_state: String = patient_states[patient_id]
		match final_state:
			"CONSCIOUS":
				outcome_score += 100.0  # Best outcome
			"UNCONSCIOUS":
				outcome_score += 60.0   # Stabilised but unconscious
			"CARDIAC_ARREST":
				outcome_score += 20.0   # Critical — not stabilised
			"DEAD":
				outcome_score += 0.0    # Worst outcome

	return clampf(outcome_score / total_patients, 0.0, 100.0)


## Generate a summary string for the scores.
func get_score_summary(scores: Dictionary) -> String:
	var lines: Array[String] = []
	lines.append("=== Performance Score ===")
	lines.append("Triage Speed:      %.1f/100 %s" % [scores.get("triage_speed", 0), "PASS" if scores.get("pass_fail", {}).get("triage_speed", false) else "FAIL"])
	lines.append("Protocol Accuracy: %.1f/100 %s" % [scores.get("protocol_accuracy", 0), "PASS" if scores.get("pass_fail", {}).get("protocol_accuracy", false) else "FAIL"])
	lines.append("Decision Quality:  %.1f/100 %s" % [scores.get("decision_quality", 0), "PASS" if scores.get("pass_fail", {}).get("decision_quality", false) else "FAIL"])
	lines.append("Equipment Handling:%.1f/100 %s" % [scores.get("equipment_handling", 0), "PASS" if scores.get("pass_fail", {}).get("equipment_handling", false) else "FAIL"])
	lines.append("Patient Outcome:   %.1f/100 %s" % [scores.get("patient_outcome", 0), "PASS" if scores.get("pass_fail", {}).get("patient_outcome", false) else "FAIL"])
	lines.append("---")
	lines.append("OVERALL:           %.1f/100 %s" % [scores.get("overall", 0), "PASS" if scores.get("pass_fail", {}).get("overall", false) else "FAIL"])
	return "\n".join(lines)


## Empty protocol analysis structure for when none is provided.
func _empty_protocol_analysis() -> Dictionary:
	return {
		"patient_reports": [],
		"prioritisation": {"correct_order": true, "details": []},
		"timing": {"time_to_first_assessment": -1.0, "time_to_first_triage": -1.0, "time_to_first_treatment": -1.0},
		"overall_adherence": 0.0,
	}
