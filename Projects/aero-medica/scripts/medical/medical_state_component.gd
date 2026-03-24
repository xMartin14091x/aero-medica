## MedicalStateComponent — Full patient medical state machine.
## Tracks state, modifiers, treatment response, and triage priority.
## Phase 2: state transitions + treatment mapping. Deterioration is in deterioration_system.gd.
## Phase 4 (MON-11): Expanded with comprehensive vital signs, GCS, ECG, skin fields and VITAL_RANGES.
extends Node

## Patient medical state machine.
enum PatientState { CONSCIOUS, UNCONSCIOUS, CARDIAC_ARREST, DEAD }

## Emitted when the patient's medical state changes.
signal state_changed(old_state: PatientState, new_state: PatientState)

## Emitted when any medical modifier changes value.
signal modifier_changed(modifier_name: String, old_value: Variant, new_value: Variant)

## Current medical state.
@export var current_state: PatientState = PatientState.CONSCIOUS

## Medical modifiers — set per-scenario via ScenarioManager or editor.
@export_range(0, 3) var bleeding_severity: int = 0
@export_enum("CLEAR", "OBSTRUCTED") var airway_status: String = "CLEAR"
@export_range(0.0, 40.0) var breathing_rate: float = 16.0
@export var pulse_present: bool = true

## ── Vital Signs (MON-11) ──────────────────────────────────────────────────────

@export_range(0, 250) var heart_rate: int = 80
@export var blood_pressure_systolic: int = 120
@export var blood_pressure_diastolic: int = 80
@export_range(0.0, 100.0) var spo2: float = 98.0
@export_range(25.0, 45.0) var temperature: float = 37.0
@export_range(0, 600) var blood_glucose: int = 100
@export_range(0.0, 10.0) var capillary_refill: float = 1.5

## Pupil Assessment
@export_range(1, 9) var pupil_left_size: int = 4
@export_range(1, 9) var pupil_right_size: int = 4
@export var pupil_left_reactive: bool = true
@export var pupil_right_reactive: bool = true

## GCS Components — used by GCSAssessmentManager (MON-14)
@export_range(1, 4) var gcs_eye: int = 4
@export_range(1, 5) var gcs_verbal: int = 5
@export_range(1, 6) var gcs_motor: int = 6

## ECG Rhythm — used by ECGRhythmManager (MON-13)
@export var ecg_rhythm: String = "NORMAL_SINUS"

## Skin Assessment
@export_enum("NORMAL", "PALE", "FLUSHED", "CYANOTIC", "MOTTLED", "JAUNDICED") var skin_color: String = "NORMAL"
@export_enum("WARM", "COOL", "HOT", "COLD") var skin_temperature: String = "WARM"
@export_enum("DRY", "MOIST", "DIAPHORETIC") var skin_moisture: String = "DRY"

## CO exposure flag — SpO2 is unreliable when true (Medica rule #4)
@export var co_exposure: bool = false

## Examination findings by body region — populated from scenario JSON (MON-12/MON-15)
@export var examination_findings: Dictionary = {}

## Whether the patient is currently being treated (pauses deterioration).
var is_being_treated: bool = false

## ── Normal Range Constants (for UI color-coding by ARC-13) ─────────────────────
const VITAL_RANGES := {
	"heart_rate": { "low": 60, "high": 100, "critical_low": 40, "critical_high": 150 },
	"blood_pressure_systolic": { "low": 90, "high": 140, "critical_low": 70, "critical_high": 180 },
	"blood_pressure_diastolic": { "low": 60, "high": 90, "critical_low": 40, "critical_high": 120 },
	"spo2": { "low": 94.0, "high": 100.0, "critical_low": 90.0 },
	"temperature": { "low": 36.0, "high": 37.5, "critical_low": 35.0, "critical_high": 40.0 },
	"blood_glucose": { "low": 60, "high": 140, "critical_low": 40, "critical_high": 300 },
	"capillary_refill": { "high": 2.0, "critical_high": 4.0 },
}

const TREATMENT_MAP := {
	"apply_bandage": "bleeding",
	"apply_tourniquet": "bleeding",
	"apply_pressure": "bleeding",
	"head_tilt_chin_lift": "airway",
	"jaw_thrust": "airway",
	"suction": "airway",
	"insert_opa": "airway",
	"bag_valve_mask": "breathing",
	"oxygen_mask": "breathing",
	"cpr": "cardiac",
	"aed": "cardiac",
}

const TRIAGE_COLOURS := {
	"RED": "Immediate",
	"YELLOW": "Delayed",
	"GREEN": "Minor",
	"BLACK": "Deceased",
}


func set_modifier(modifier_name: String, new_value: Variant) -> void:
	var old_value: Variant
	match modifier_name:
		"bleeding_severity":
			old_value = bleeding_severity
			bleeding_severity = clampi(new_value as int, 0, 3)
		"airway_status":
			old_value = airway_status
			airway_status = new_value
		"breathing_rate":
			old_value = breathing_rate
			breathing_rate = clampf(new_value as float, 0.0, 40.0)
		"pulse_present":
			old_value = pulse_present
			pulse_present = new_value
		"heart_rate":
			old_value = heart_rate
			heart_rate = clampi(new_value as int, 0, 250)
		"blood_pressure_systolic":
			old_value = blood_pressure_systolic
			blood_pressure_systolic = clampi(new_value as int, 0, 300)
		"blood_pressure_diastolic":
			old_value = blood_pressure_diastolic
			blood_pressure_diastolic = clampi(new_value as int, 0, 200)
		"spo2":
			old_value = spo2
			spo2 = clampf(new_value as float, 0.0, 100.0)
		"temperature":
			old_value = temperature
			temperature = clampf(new_value as float, 25.0, 45.0)
		"blood_glucose":
			old_value = blood_glucose
			blood_glucose = clampi(new_value as int, 0, 600)
		"capillary_refill":
			old_value = capillary_refill
			capillary_refill = clampf(new_value as float, 0.0, 10.0)
		"ecg_rhythm":
			old_value = ecg_rhythm
			ecg_rhythm = new_value
		"skin_color":
			old_value = skin_color
			skin_color = new_value
		"skin_temperature":
			old_value = skin_temperature
			skin_temperature = new_value
		"skin_moisture":
			old_value = skin_moisture
			skin_moisture = new_value
		_:
			push_warning("MedicalStateComponent: Unknown modifier '%s'" % modifier_name)
			return
	if old_value != new_value:
		modifier_changed.emit(modifier_name, old_value, new_value)
		_evaluate_state_from_modifiers()


func set_state(new_state: PatientState) -> void:
	if new_state == current_state:
		return
	if current_state == PatientState.DEAD:
		return
	var old_state := current_state
	current_state = new_state
	_sync_vitals_to_state(new_state)
	state_changed.emit(old_state, new_state)


func apply_treatment(treatment_type: String) -> bool:
	if current_state == PatientState.DEAD:
		return false
	var treatment_target: String = TREATMENT_MAP.get(treatment_type, "")
	if treatment_target == "":
		push_warning("MedicalStateComponent: Unknown treatment type '%s'" % treatment_type)
		return false
	is_being_treated = true
	var was_effective := false
	match treatment_target:
		"bleeding":
			if bleeding_severity > 0:
				set_modifier("bleeding_severity", bleeding_severity - 1)
				if bleeding_severity < 2:
					set_modifier("heart_rate", maxi(heart_rate - 15, 60))
					set_modifier("blood_pressure_systolic", mini(blood_pressure_systolic + 10, 120))
				was_effective = true
		"airway":
			if airway_status == "OBSTRUCTED":
				set_modifier("airway_status", "CLEAR")
				if breathing_rate < 8.0:
					set_modifier("breathing_rate", 12.0)
				set_modifier("spo2", minf(spo2 + 8.0, 98.0))
				was_effective = true
		"breathing":
			if breathing_rate < 12.0:
				set_modifier("breathing_rate", 16.0)
				set_modifier("spo2", minf(spo2 + 6.0, 98.0))
				was_effective = true
		"cardiac":
			if current_state == PatientState.CARDIAC_ARREST:
				set_modifier("pulse_present", true)
				set_modifier("breathing_rate", 10.0)
				set_modifier("heart_rate", 50)
				set_modifier("blood_pressure_systolic", 80)
				set_modifier("spo2", 88.0)
				set_modifier("ecg_rhythm", "SINUS_BRADYCARDIA")
				set_state(PatientState.UNCONSCIOUS)
				was_effective = true
				# Slow deterioration after ROSC — patient is stabilised but fragile
				var det: Node = get_parent().get_node_or_null("DeteriorationSystem")
				if det:
					det.deterioration_rate *= 0.3
	is_being_treated = false
	return was_effective


func get_triage_priority() -> String:
	if current_state == PatientState.DEAD:
		return "BLACK"
	if current_state == PatientState.CARDIAC_ARREST:
		return "RED"
	if not pulse_present:
		return "RED"
	if breathing_rate < 8.0:
		return "RED"
	if airway_status == "OBSTRUCTED":
		return "RED"
	if bleeding_severity >= 2:
		return "RED"
	if current_state == PatientState.UNCONSCIOUS:
		return "RED"
	if blood_pressure_systolic < 70 or heart_rate > 150 or spo2 < 90.0:
		return "RED"
	# Mild bleeding (severity 1) alone = GREEN. Only escalate to YELLOW if combined with other abnormality.
	var mild_bleeding := bleeding_severity == 1
	var abnormal_breathing := breathing_rate < 12.0 or breathing_rate > 30.0
	if abnormal_breathing:
		return "YELLOW"
	if mild_bleeding and (blood_pressure_systolic < 100 or heart_rate > 110 or spo2 < 95.0):
		return "YELLOW"
	if blood_pressure_systolic < 90 or heart_rate < 60 or heart_rate > 100 or spo2 < 94.0:
		return "YELLOW"
	return "GREEN"


func _evaluate_state_from_modifiers() -> void:
	if current_state == PatientState.DEAD:
		return
	if not pulse_present and current_state != PatientState.CARDIAC_ARREST:
		set_state(PatientState.CARDIAC_ARREST)
		return
	if breathing_rate <= 0.0 and current_state != PatientState.CARDIAC_ARREST:
		set_modifier("pulse_present", false)
		set_state(PatientState.CARDIAC_ARREST)
		return
	if breathing_rate < 6.0 and current_state == PatientState.CONSCIOUS:
		set_state(PatientState.UNCONSCIOUS)
		return
	if blood_pressure_systolic < 60 and current_state == PatientState.CONSCIOUS:
		set_state(PatientState.UNCONSCIOUS)
		return


func _sync_vitals_to_state(new_state: PatientState) -> void:
	match new_state:
		PatientState.CARDIAC_ARREST:
			pulse_present = false
			breathing_rate = 0.0
			heart_rate = 0
			ecg_rhythm = "VENTRICULAR_FIBRILLATION"
			gcs_eye = 1
			gcs_verbal = 1
			gcs_motor = 1
		PatientState.DEAD:
			pulse_present = false
			breathing_rate = 0.0
			heart_rate = 0
			blood_pressure_systolic = 0
			blood_pressure_diastolic = 0
			spo2 = 0.0
			ecg_rhythm = "ASYSTOLE"
			gcs_eye = 1
			gcs_verbal = 1
			gcs_motor = 1
		PatientState.UNCONSCIOUS:
			gcs_eye = 1
			gcs_verbal = 1
			gcs_motor = 2


func get_gcs_total() -> int:
	return gcs_eye + gcs_verbal + gcs_motor


func get_state_summary() -> Dictionary:
	return {
		"state": PatientState.keys()[current_state],
		"bleeding_severity": bleeding_severity,
		"airway_status": airway_status,
		"breathing_rate": breathing_rate,
		"pulse_present": pulse_present,
		"triage_priority": get_triage_priority(),
		"heart_rate": heart_rate,
		"blood_pressure": "%d/%d mmHg" % [blood_pressure_systolic, blood_pressure_diastolic],
		"spo2": spo2,
		"temperature": temperature,
		"blood_glucose": blood_glucose,
		"capillary_refill": capillary_refill,
		"pupil_left": "%dmm %s" % [pupil_left_size, "reactive" if pupil_left_reactive else "fixed"],
		"pupil_right": "%dmm %s" % [pupil_right_size, "reactive" if pupil_right_reactive else "fixed"],
		"gcs": get_gcs_total(),
		"gcs_breakdown": "E%dV%dM%d" % [gcs_eye, gcs_verbal, gcs_motor],
		"ecg_rhythm": ecg_rhythm,
		"skin": "%s, %s, %s" % [skin_color, skin_temperature, skin_moisture],
		"co_exposure": co_exposure,
	}
