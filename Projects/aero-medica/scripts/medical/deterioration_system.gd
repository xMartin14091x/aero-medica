## DeteriorationSystem — Time-based patient condition worsening.
## Attached to each Patient entity. Untreated conditions worsen over time.
## Deterioration pauses while the patient is being actively treated.
## MON-17: Optimised — permanently disables process on DEAD state.
extends Node

## Emitted when a condition worsens due to time.
signal condition_worsened(patient: Node, modifier: String, old_value: Variant, new_value: Variant)

## Global speed multiplier — higher = faster deterioration. Set per-scenario.
@export var deterioration_rate: float = 1.0

## Master toggle — can be disabled per-patient or globally.
@export var deterioration_enabled: bool = true

## Time intervals (seconds) before each condition worsens. Scaled by deterioration_rate.
## These are base values — actual time = base / deterioration_rate.
@export var bleeding_interval: float = 30.0
@export var airway_to_unconscious: float = 45.0
@export var unconscious_to_cardiac: float = 60.0
@export var cardiac_to_dead: float = 30.0

## Interval (seconds) for vital sign deterioration ticks.
@export var vitals_interval: float = 10.0

## Internal timers tracking time since last worsening per condition.
var _bleeding_timer: float = 0.0
var _airway_timer: float = 0.0
var _unconscious_timer: float = 0.0
var _cardiac_timer: float = 0.0
var _vitals_timer: float = 0.0

## Reference to sibling MedicalStateComponent.
var _medical: Node = null


func _ready() -> void:
	_medical = get_parent().get_node_or_null("MedicalStateComponent")
	if _medical == null:
		push_error("DeteriorationSystem: No sibling MedicalStateComponent found.")
		set_process(false)


func _process(delta: float) -> void:
	if not deterioration_enabled:
		return
	if _medical == null:
		return
	if _medical.current_state == _medical.PatientState.DEAD:
		set_process(false)  # Permanently stop — DEAD is terminal
		return
	# Pause deterioration during active treatment
	if _medical.is_being_treated:
		return

	# Apply idle time scale: when player is NOT interacting (mouse captured / walking),
	# deterioration runs slower (0.3x). When interacting (UI open), runs at normal speed.
	var idle_scale: float = 0.3 if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else 1.0
	var scaled_delta := delta * deterioration_rate * idle_scale

	_process_bleeding(scaled_delta)
	_process_airway(scaled_delta)
	_process_unconscious(scaled_delta)
	_process_cardiac(scaled_delta)
	_process_vital_signs(scaled_delta)


## Bleeding: severity increases by 1 every bleeding_interval seconds if untreated.
func _process_bleeding(scaled_delta: float) -> void:
	if _medical.bleeding_severity <= 0 or _medical.bleeding_severity >= 3:
		_bleeding_timer = 0.0
		return

	_bleeding_timer += scaled_delta
	if _bleeding_timer >= bleeding_interval:
		_bleeding_timer = 0.0
		var old_val: int = _medical.bleeding_severity
		_medical.set_modifier("bleeding_severity", old_val + 1)
		condition_worsened.emit(get_parent(), "bleeding_severity", old_val, _medical.bleeding_severity)

		# Severe bleeding (3) causes loss of consciousness
		if _medical.bleeding_severity >= 3 and _medical.current_state == _medical.PatientState.CONSCIOUS:
			_medical.set_state(_medical.PatientState.UNCONSCIOUS)


## Airway obstruction: breathing_rate drops → UNCONSCIOUS.
func _process_airway(scaled_delta: float) -> void:
	if _medical.airway_status != "OBSTRUCTED":
		_airway_timer = 0.0
		return
	if _medical.current_state != _medical.PatientState.CONSCIOUS:
		return

	_airway_timer += scaled_delta
	if _airway_timer >= airway_to_unconscious:
		_airway_timer = 0.0
		# Drop breathing rate as airway obstruction worsens
		var old_rate: float = _medical.breathing_rate
		var new_rate := maxf(old_rate - 4.0, 0.0)
		_medical.set_modifier("breathing_rate", new_rate)
		condition_worsened.emit(get_parent(), "breathing_rate", old_rate, new_rate)

		if new_rate < 6.0:
			_medical.set_state(_medical.PatientState.UNCONSCIOUS)


## UNCONSCIOUS: if airway not cleared within time → CARDIAC_ARREST.
func _process_unconscious(scaled_delta: float) -> void:
	if _medical.current_state != _medical.PatientState.UNCONSCIOUS:
		_unconscious_timer = 0.0
		return

	_unconscious_timer += scaled_delta
	if _unconscious_timer >= unconscious_to_cardiac:
		_unconscious_timer = 0.0
		_medical.set_modifier("pulse_present", false)
		_medical.set_modifier("breathing_rate", 0.0)
		_medical.set_state(_medical.PatientState.CARDIAC_ARREST)
		condition_worsened.emit(get_parent(), "state", "UNCONSCIOUS", "CARDIAC_ARREST")


## CARDIAC_ARREST: if no CPR/AED within time window → DEAD.
func _process_cardiac(scaled_delta: float) -> void:
	if _medical.current_state != _medical.PatientState.CARDIAC_ARREST:
		_cardiac_timer = 0.0
		return

	_cardiac_timer += scaled_delta
	if _cardiac_timer >= cardiac_to_dead:
		_cardiac_timer = 0.0
		_medical.set_state(_medical.PatientState.DEAD)
		condition_worsened.emit(get_parent(), "state", "CARDIAC_ARREST", "DEAD")


## Vital signs: periodic deterioration driven by ongoing injuries.
## Triggers every vitals_interval seconds (scaled by deterioration_rate).
func _process_vital_signs(scaled_delta: float) -> void:
	_vitals_timer += scaled_delta
	if _vitals_timer < vitals_interval:
		return
	_vitals_timer = 0.0

	# Haemorrhage drives tachycardia and hypotension
	if _medical.bleeding_severity >= 2:
		_medical.set_modifier("heart_rate", maxi(_medical.heart_rate + 5, 0))
		_medical.set_modifier("blood_pressure_systolic", maxi(_medical.blood_pressure_systolic - 5, 0))
		_medical.set_modifier("spo2", maxf(_medical.spo2 - 1.0, 0.0))

	# Airway obstruction drives hypoxia
	if _medical.airway_status == "OBSTRUCTED":
		_medical.set_modifier("spo2", maxf(_medical.spo2 - 2.0, 0.0))

	# Unconscious state drives slow cardiovascular decline
	if _medical.current_state == _medical.PatientState.UNCONSCIOUS:
		_medical.set_modifier("heart_rate", maxi(_medical.heart_rate + 3, 0))
		_medical.set_modifier("blood_pressure_systolic", maxi(_medical.blood_pressure_systolic - 3, 0))


## Reset all deterioration timers (call after successful treatment).
func reset_timers() -> void:
	_bleeding_timer = 0.0
	_airway_timer = 0.0
	_unconscious_timer = 0.0
	_cardiac_timer = 0.0
	_vitals_timer = 0.0
