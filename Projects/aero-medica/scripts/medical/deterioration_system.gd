## DeteriorationSystem — Time-based patient condition worsening.
## Attached to each Patient entity. Untreated conditions worsen over time.
## Deterioration pauses while the patient is being actively treated.
## MON-17: Optimised — permanently disables process on DEAD state.
##
## Two-phase budget deterioration gate:
##   Phase 1 (pre-cardiac): 300s budget, drains 1x unfocused / 3.33x focused (~5min / ~1.5min).
##   Phase 2 (cardiac arrest→dead): budget resets to 120s, drains 1x / 2x (~2min / ~1min).
##   Critical transitions BLOCKED until budget reaches 0. Budget resets on cardiac arrest entry.
##   Non-critical deterioration (bleeding, vitals) always runs normally.
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

## Two-phase budget deterioration gate.
## Phase 1 (pre-cardiac arrest): 300s budget, drains at 1x unfocused / 3.33x focused.
##   → ~5 min unfocused or ~1.5 min focused before cardiac arrest can trigger.
## Phase 2 (cardiac arrest → dead): budget resets to 120s, drains at 1x unfocused / 2x focused.
##   → ~2 min unfocused or ~1 min focused before death can trigger.
## Non-critical deterioration (bleeding, vitals) always runs regardless of budget.
@export var phase1_budget: float = 300.0             # 5 min pre-cardiac budget
@export var phase1_focused_rate: float = 3.33        # ~90s focused to drain
@export var phase2_budget: float = 120.0             # 2 min cardiac arrest budget
@export var phase2_focused_rate: float = 2.0         # ~60s focused to drain

## Internal timers tracking time since last worsening per condition.
var _bleeding_timer: float = 0.0
var _airway_timer: float = 0.0
var _unconscious_timer: float = 0.0
var _cardiac_timer: float = 0.0
var _vitals_timer: float = 0.0

## Budget state.
var _budget_remaining: float = 300.0   # Initialized to phase1_budget in _ready
var _is_player_focused: bool = false   # True while PatientInteractionUI is open for THIS patient
var _in_phase2: bool = false           # True after cardiac arrest entry (budget reset)

## Reference to sibling MedicalStateComponent.
var _medical: Node = null


func _ready() -> void:
	_medical = get_parent().get_node_or_null("MedicalStateComponent")
	if _medical == null:
		push_error("DeteriorationSystem: No sibling MedicalStateComponent found.")
		set_process(false)
		return
	# Patients starting in cardiac arrest begin in phase 2 directly
	if _medical.current_state == _medical.PatientState.CARDIAC_ARREST:
		_budget_remaining = phase2_budget
		_in_phase2 = true
	else:
		_budget_remaining = phase1_budget


## Called by PatientInteractionUI when the player opens/closes interaction with this patient.
func set_player_focused(focused: bool) -> void:
	_is_player_focused = focused


## Whether critical transitions are currently allowed.
## Budget must be fully drained (0) before lethal state jumps can fire.
func _can_critical_transition() -> bool:
	return _budget_remaining <= 0.0


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

	# Drain critical budget: faster when player is focused on this patient, normal otherwise.
	# Phase 1 (pre-cardiac) uses phase1_focused_rate, Phase 2 (cardiac) uses phase2_focused_rate.
	if _budget_remaining > 0.0:
		var rate: float = (phase2_focused_rate if _in_phase2 else phase1_focused_rate) if _is_player_focused else 1.0
		_budget_remaining = maxf(0.0, _budget_remaining - delta * rate)

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
## Gated by budget — blocked until budget depleted. On transition, resets budget to phase2.
func _process_unconscious(scaled_delta: float) -> void:
	if _medical.current_state != _medical.PatientState.UNCONSCIOUS:
		_unconscious_timer = 0.0
		return

	_unconscious_timer += scaled_delta
	if _unconscious_timer >= unconscious_to_cardiac:
		if not _can_critical_transition():
			return  # Hold at threshold — don't reset timer, just wait
		_unconscious_timer = 0.0
		_medical.set_modifier("pulse_present", false)
		_medical.set_modifier("breathing_rate", 0.0)
		_medical.set_modifier("heart_rate", 0)
		# Set arrest rhythm: VFib (shockable) — AED can defibrillate
		_medical.ecg_rhythm = "VENTRICULAR_FIBRILLATION"
		_medical.set_state(_medical.PatientState.CARDIAC_ARREST)
		condition_worsened.emit(get_parent(), "state", "UNCONSCIOUS", "CARDIAC_ARREST")
		# Reset budget to phase 2 — gives player 2 min unfocused / 1 min focused before death
		_budget_remaining = phase2_budget
		_in_phase2 = true


## CARDIAC_ARREST: if no CPR/AED within time window → DEAD.
## Gated by interaction-aware timing — blocked until both thresholds met.
func _process_cardiac(scaled_delta: float) -> void:
	if _medical.current_state != _medical.PatientState.CARDIAC_ARREST:
		_cardiac_timer = 0.0
		return

	_cardiac_timer += scaled_delta
	if _cardiac_timer >= cardiac_to_dead:
		if not _can_critical_transition():
			return  # Hold at threshold — don't reset timer, just wait
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
