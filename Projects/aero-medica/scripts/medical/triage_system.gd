## TriageSystem — Manages triage tag assignments using START protocol.
## Player assigns tags to patients; system validates against actual medical state.
## Incorrect tags are logged but NOT prevented (stealth assessment).
extends Node

## Triage tag colour enum.
enum TriageTag { GREEN, YELLOW, RED, BLACK }

## Human-readable labels for tags.
const TAG_LABELS := {
	TriageTag.GREEN: "GREEN",
	TriageTag.YELLOW: "YELLOW",
	TriageTag.RED: "RED",
	TriageTag.BLACK: "BLACK",
}

## Emitted when a triage tag is assigned to a patient.
signal triage_assigned(patient: Node, assigned_tag: int, correct_tag: int, is_correct: bool)

## Reference to TelemetryEmitter on the player.
var _telemetry: Node = null

## Track which patients have been tagged (patient node → assigned tag).
var _tagged_patients: Dictionary = {}


## Initialize with player reference to access TelemetryEmitter.
func setup(player: Node) -> void:
	_telemetry = player.get_node_or_null("TelemetryEmitter")


## Assign a triage tag to a patient.
## The tag is recorded regardless of correctness — stealth assessment.
func assign_tag(patient: Node, tag: TriageTag) -> Dictionary:
	# Prevent re-tagging — once tagged, it's final
	if patient in _tagged_patients:
		return {
			"already_tagged": true,
			"existing_tag": TAG_LABELS[_tagged_patients[patient]],
		}

	var correct_tag := get_correct_tag(patient)
	var is_correct := (tag == correct_tag)

	# Record the assignment
	_tagged_patients[patient] = tag

	# Store on patient via meta for other systems to read
	patient.set_meta("triage_tag", TAG_LABELS[tag])
	patient.set_meta("triage_correct", is_correct)
	patient.set_meta("triage_correct_at_assignment", TAG_LABELS[correct_tag])

	# Emit signal for UI and other systems
	triage_assigned.emit(patient, tag, correct_tag, is_correct)

	# Log to telemetry
	if _telemetry and _telemetry.has_method("emit_action"):
		var display_name: String = patient.persona.patient_name if ("persona" in patient and patient.persona) else patient.name
		_telemetry.emit_action("triage_assign", display_name, {
			"assigned_tag": TAG_LABELS[tag],
			"correct_tag": TAG_LABELS[correct_tag],
			"was_correct": is_correct,
			"time_elapsed": Time.get_ticks_msec() / 1000.0,
		})

	return {
		"assigned_tag": TAG_LABELS[tag],
		"correct_tag": TAG_LABELS[correct_tag],
		"is_correct": is_correct,
	}


## Calculate the correct triage tag for a patient.
## Uses the INITIAL triage priority stored at spawn time (before any deterioration).
## Falls back to current MedicalStateComponent if no initial priority stored.
func get_correct_tag(patient: Node) -> TriageTag:
	# Prefer the initial priority from spawn time — reflects presenting condition
	var priority: String = ""
	if patient.has_meta("initial_triage_priority"):
		priority = str(patient.get_meta("initial_triage_priority"))
	else:
		var medical_state: Node = patient.get_node_or_null("MedicalStateComponent")
		if not medical_state:
			return TriageTag.GREEN
		priority = medical_state.get_triage_priority()

	match priority:
		"GREEN":
			return TriageTag.GREEN
		"YELLOW":
			return TriageTag.YELLOW
		"RED":
			return TriageTag.RED
		"BLACK":
			return TriageTag.BLACK

	return TriageTag.GREEN


## Check if a patient has already been tagged.
func is_tagged(patient: Node) -> bool:
	return patient in _tagged_patients


## Get the tag assigned to a patient (returns -1 if not tagged).
func get_assigned_tag(patient: Node) -> int:
	if patient in _tagged_patients:
		return _tagged_patients[patient]
	return -1


## Get the tag label string for a tag enum value.
func get_tag_label(tag: TriageTag) -> String:
	return TAG_LABELS.get(tag, "UNKNOWN")


## Get summary of all triage assignments for telemetry/debrief.
func get_triage_summary() -> Dictionary:
	var total := _tagged_patients.size()
	var correct := 0
	var incorrect := 0
	var results: Array[Dictionary] = []

	for patient: Node in _tagged_patients:
		if not is_instance_valid(patient):
			continue
		var assigned: int = _tagged_patients[patient]
		var correct_tag := get_correct_tag(patient)
		var is_correct := (assigned == correct_tag)
		if is_correct:
			correct += 1
		else:
			incorrect += 1
		results.append({
			"patient": patient.name,
			"assigned": TAG_LABELS[assigned],
			"correct": TAG_LABELS[correct_tag],
			"is_correct": is_correct,
		})

	return {
		"total_tagged": total,
		"correct": correct,
		"incorrect": incorrect,
		"accuracy": (float(correct) / total * 100.0) if total > 0 else 0.0,
		"details": results,
	}


## Reset all triage data (call on new scenario).
func reset() -> void:
	_tagged_patients.clear()
