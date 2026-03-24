## GCSAssessmentManager — Glasgow Coma Scale 3-component assessment system.
## Phase 5 (MON-14): Guided assessment with severity classification.
## GCS ≤8 triggers airway protection warning (Medica rule #5).
extends Node

## GCS component descriptors.
const EYE_RESPONSES := {
	4: "Spontaneous — eyes open without stimulation",
	3: "To Voice — eyes open to verbal command",
	2: "To Pain — eyes open to pain stimulus",
	1: "None — no eye opening",
}

const VERBAL_RESPONSES := {
	5: "Oriented — knows person, place, time",
	4: "Confused — sentences but disoriented",
	3: "Words — single words only",
	2: "Sounds — moaning, incomprehensible",
	1: "None — no verbal response",
}

const MOTOR_RESPONSES := {
	6: "Obeys Commands — follows simple instructions",
	5: "Localises — purposeful movement to pain",
	4: "Withdraws — pulls away from pain",
	3: "Abnormal Flexion — decorticate posturing",
	2: "Extension — decerebrate posturing",
	1: "None — no motor response",
}

## GCS severity bands.
const SEVERITY := {
	"MILD": { "min": 13, "max": 15, "label": "Mild", "color_hex": "3de34a" },
	"MODERATE": { "min": 9, "max": 12, "label": "Moderate", "color_hex": "f0d060" },
	"SEVERE": { "min": 3, "max": 8, "label": "Severe — AIRWAY PROTECTION NEEDED", "color_hex": "e84040" },
}

## AVPU equivalent for reference.
const AVPU_EQUIVALENT := {
	"MILD": "ALERT",
	"MODERATE": "VERBAL",
	"SEVERE": "UNRESPONSIVE",
}


## Calculate total GCS from 3 components.
func calculate_total(eye: int, verbal: int, motor: int) -> int:
	return clampi(eye, 1, 4) + clampi(verbal, 1, 5) + clampi(motor, 1, 6)


## Get severity classification from total score.
func get_severity(total: int) -> String:
	if total >= 13:
		return "MILD"
	elif total >= 9:
		return "MODERATE"
	else:
		return "SEVERE"


## Get severity data dictionary.
func get_severity_data(total: int) -> Dictionary:
	var sev_key := get_severity(total)
	return SEVERITY.get(sev_key, {})


## Returns true if GCS indicates airway protection is needed (GCS ≤8).
func needs_airway_protection(total: int) -> bool:
	return total <= 8


## Get AVPU equivalent for cross-reference.
func get_avpu_equivalent(total: int) -> String:
	return AVPU_EQUIVALENT.get(get_severity(total), "UNRESPONSIVE")


## Read GCS from a patient's MedicalStateComponent.
func read_from_patient(patient: Node) -> Dictionary:
	var medical: Node = patient.get_node_or_null("MedicalStateComponent")
	if not medical:
		return {}
	var eye: int = medical.gcs_eye
	var verbal: int = medical.gcs_verbal
	var motor: int = medical.gcs_motor
	var total: int = calculate_total(eye, verbal, motor)
	var sev_key := get_severity(total)
	var sev_data: Dictionary = SEVERITY.get(sev_key, {})
	return {
		"eye": eye,
		"verbal": verbal,
		"motor": motor,
		"total": total,
		"severity": sev_data.get("label", "Unknown"),
		"severity_key": sev_key,
		"color_hex": sev_data.get("color_hex", "ffffff"),
		"airway_warning": needs_airway_protection(total),
		"avpu_equivalent": get_avpu_equivalent(total),
	}
