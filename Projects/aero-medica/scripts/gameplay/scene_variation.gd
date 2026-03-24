## SceneVariation — Randomises scenario elements for replayability.
## Pre-processes scenario data before spawning: varies patient positions, conditions,
## equipment locations, and hazard placements. Seed-based for reproducible runs.
extends Node

## Difficulty scaling presets.
const DIFFICULTY_EASY := "easy"
const DIFFICULTY_NORMAL := "normal"
const DIFFICULTY_HARD := "hard"

## Difficulty modifiers: patient_count_multiplier, deterioration_multiplier, equipment_multiplier.
const DIFFICULTY_MODIFIERS := {
	DIFFICULTY_EASY: {
		"extra_patients": 0,
		"deterioration_multiplier": 0.7,
		"equipment_bonus": 1,
		"time_multiplier": 1.3,
	},
	DIFFICULTY_NORMAL: {
		"extra_patients": 0,
		"deterioration_multiplier": 1.0,
		"equipment_bonus": 0,
		"time_multiplier": 1.0,
	},
	DIFFICULTY_HARD: {
		"extra_patients": 1,
		"deterioration_multiplier": 1.5,
		"equipment_bonus": -1,
		"time_multiplier": 0.7,
	},
}

## Default spawn zone radius when not specified per-patient.
const DEFAULT_ZONE_RADIUS := 3.0

## Default condition variation ranges.
const BLEEDING_RANGE := Vector2i(0, 3)
const BREATHING_RATE_RANGE := Vector2(6.0, 35.0)
const PAIN_LEVEL_RANGE := Vector2i(0, 10)
const PANIC_LEVEL_RANGE := Vector2(0.0, 1.0)

## Internal RNG — seeded for reproducibility.
var _rng := RandomNumberGenerator.new()


## Randomise a scenario data dictionary in-place and return the modified copy.
## Same seed = same layout every time.
func randomise_scenario(scenario_data: Dictionary, seed_value: int = -1) -> Dictionary:
	var data: Dictionary = scenario_data.duplicate(true)

	# Seed the RNG
	if seed_value >= 0:
		_rng.seed = seed_value
	else:
		_rng.randomize()

	# Store the seed used for reproducibility
	data["variation_seed"] = _rng.seed

	# Randomise patient positions and conditions
	_randomise_patients(data)

	# Randomise equipment positions
	_randomise_equipment(data)

	# Randomise hazard placements
	_randomise_hazards(data)

	# Randomise random event trigger times (re-roll within their defined ranges)
	_randomise_event_times(data)

	return data


## Apply difficulty scaling to scenario data (call after randomise_scenario or independently).
func apply_difficulty(scenario_data: Dictionary, difficulty: String) -> Dictionary:
	var data: Dictionary = scenario_data.duplicate(true)
	var mods: Dictionary = DIFFICULTY_MODIFIERS.get(difficulty, DIFFICULTY_MODIFIERS[DIFFICULTY_NORMAL])

	# Adjust time limit
	var time_limit: float = data.get("time_limit_seconds", 600.0)
	data["time_limit_seconds"] = time_limit * mods["time_multiplier"]

	# Adjust deterioration rates on all patients
	var patients: Array = data.get("patients", [])
	for patient: Dictionary in patients:
		var det: Dictionary = patient.get("deterioration", {})
		if det.has("rate"):
			det["rate"] = det["rate"] * mods["deterioration_multiplier"]
		patient["deterioration"] = det

	# Adjust equipment count
	var equipment: Array = data.get("equipment", [])
	var bonus: int = mods["equipment_bonus"]
	if bonus < 0 and equipment.size() > 1:
		# Remove random equipment items (never remove all)
		var to_remove := mini(absi(bonus), equipment.size() - 1)
		for _i in to_remove:
			var idx := _rng.randi_range(0, equipment.size() - 1)
			equipment.remove_at(idx)

	# Add extra patients on hard difficulty
	var extra: int = mods["extra_patients"]
	if extra > 0 and patients.size() > 0:
		for _i in extra:
			# Clone a random existing patient with varied position
			var template: Dictionary = patients[_rng.randi_range(0, patients.size() - 1)].duplicate(true)
			_vary_patient_position(template)
			_vary_patient_condition(template)
			patients.append(template)

	return data


## Randomise patient positions within their spawn zones.
func _randomise_patients(data: Dictionary) -> void:
	var patients: Array = data.get("patients", [])

	for patient: Dictionary in patients:
		_vary_patient_position(patient)
		_vary_patient_condition(patient)


## Vary a single patient's position within a zone around the original position.
func _vary_patient_position(patient: Dictionary) -> void:
	# Use variation_zone if specified, otherwise use default radius
	var zone: Dictionary = patient.get("variation_zone", {})
	var radius: float = zone.get("radius", DEFAULT_ZONE_RADIUS)

	# Get base position (if position key exists in medical_state or at root)
	var pos: Dictionary = patient.get("position", {})

	if pos.is_empty():
		# No explicit position — spawn_marker-based scenarios use marker lookup at spawn time
		# Add a random offset that ScenarioManager can apply relative to the marker
		patient["position_offset"] = {
			"x": _rng.randf_range(-radius, radius),
			"z": _rng.randf_range(-radius, radius),
		}
	else:
		# Offset the explicit position within the zone
		pos["x"] = pos.get("x", 0.0) + _rng.randf_range(-radius, radius)
		pos["z"] = pos.get("z", 0.0) + _rng.randf_range(-radius, radius)
		patient["position"] = pos


## Vary a single patient's medical condition within defined ranges.
func _vary_patient_condition(patient: Dictionary) -> void:
	var medical: Dictionary = patient.get("medical_state", {})
	if medical.is_empty():
		# Check for modifiers key (random_events NEW_PATIENT format)
		medical = patient.get("modifiers", {})
		if medical.is_empty():
			return

	# Vary bleeding severity within range (keep within bounds of original ± 1)
	if medical.has("bleeding_severity"):
		var base: int = medical["bleeding_severity"]
		var varied := clampi(
			base + _rng.randi_range(-1, 1),
			BLEEDING_RANGE.x,
			BLEEDING_RANGE.y
		)
		medical["bleeding_severity"] = varied

	# Vary breathing rate slightly (±4 breaths/min)
	if medical.has("breathing_rate"):
		var base: float = medical["breathing_rate"]
		var varied := clampf(
			base + _rng.randf_range(-4.0, 4.0),
			BREATHING_RATE_RANGE.x,
			BREATHING_RATE_RANGE.y
		)
		medical["breathing_rate"] = varied

	# Vary persona pain and panic levels
	var persona: Dictionary = patient.get("persona", {})
	if persona.has("pain_level"):
		var base: int = persona["pain_level"]
		persona["pain_level"] = clampi(
			base + _rng.randi_range(-2, 2),
			PAIN_LEVEL_RANGE.x,
			PAIN_LEVEL_RANGE.y
		)
	if persona.has("panic_level"):
		var base: float = persona["panic_level"]
		persona["panic_level"] = clampf(
			base + _rng.randf_range(-0.2, 0.2),
			PANIC_LEVEL_RANGE.x,
			PANIC_LEVEL_RANGE.y
		)


## Randomise equipment positions within spawn zones.
func _randomise_equipment(data: Dictionary) -> void:
	var equipment: Array = data.get("equipment", [])

	for equip: Dictionary in equipment:
		var zone: Dictionary = equip.get("variation_zone", {})
		var radius: float = zone.get("radius", DEFAULT_ZONE_RADIUS)

		var pos: Dictionary = equip.get("position", {})
		if pos.is_empty():
			# Marker-based — add offset
			equip["position_offset"] = {
				"x": _rng.randf_range(-radius, radius),
				"z": _rng.randf_range(-radius, radius),
			}
		else:
			pos["x"] = pos.get("x", 0.0) + _rng.randf_range(-radius, radius)
			pos["z"] = pos.get("z", 0.0) + _rng.randf_range(-radius, radius)
			equip["position"] = pos


## Randomise hazard positions within defined bounds.
func _randomise_hazards(data: Dictionary) -> void:
	var hazards: Array = data.get("hazards", [])

	for hazard: Dictionary in hazards:
		var zone: Dictionary = hazard.get("variation_zone", {})
		var radius: float = zone.get("radius", 2.0)

		var pos: Dictionary = hazard.get("position", {})
		if not pos.is_empty():
			pos["x"] = pos.get("x", 0.0) + _rng.randf_range(-radius, radius)
			pos["z"] = pos.get("z", 0.0) + _rng.randf_range(-radius, radius)
			hazard["position"] = pos

		# Slightly vary the initial radius (±20%)
		if hazard.has("radius"):
			var base_r: float = hazard["radius"]
			hazard["radius"] = maxf(1.0, base_r * _rng.randf_range(0.8, 1.2))


## Re-roll random event trigger times within their defined ranges.
func _randomise_event_times(data: Dictionary) -> void:
	var events: Array = data.get("random_events", [])

	for event: Dictionary in events:
		var t_min: float = event.get("trigger_time_min", 30.0)
		var t_max: float = event.get("trigger_time_max", t_min)
		# Store the resolved trigger time (RandomEventSystem will use this if present)
		event["resolved_trigger_time"] = _rng.randf_range(t_min, t_max)


## Generate a random seed value.
static func generate_seed() -> int:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi()
