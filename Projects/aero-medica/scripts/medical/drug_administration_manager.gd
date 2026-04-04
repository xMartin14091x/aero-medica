## DrugAdministrationManager — Pharmacological treatment system.
## Phase 6 (MON-16): Dose/route selection, medication error tracking, IV access requirement.
## Clinical accuracy: Medica Consultation Log #01, Part 4.
extends Node

## Loaded drug database from JSON.
var _drugs: Dictionary = {}

## Administration log per patient: { patient_name: [ {drug, dose, route, time, error} ] }
var _admin_log: Dictionary = {}

## Tracks last admin time per patient per drug: { patient_name: { drug_key: timestamp } }
var _last_admin: Dictionary = {}

## Medication error categories (Medica-defined, non-negotiable).
enum MedError {
	NONE,
	WRONG_DRUG,
	WRONG_DOSE,
	WRONG_ROUTE,
	WRONG_CONCENTRATION,
	CONTRAINDICATED,
	EXCEEDED_MAX_DOSE,
	TOO_SOON,
}

const MED_ERROR_LABELS := {
	MedError.NONE: "No Error",
	MedError.WRONG_DRUG: "Wrong Drug",
	MedError.WRONG_DOSE: "Wrong Dose",
	MedError.WRONG_ROUTE: "Wrong Route",
	MedError.WRONG_CONCENTRATION: "Wrong Concentration",
	MedError.CONTRAINDICATED: "Contraindicated",
	MedError.EXCEEDED_MAX_DOSE: "Exceeded Maximum Dose",
	MedError.TOO_SOON: "Administered Too Soon",
}

## Emitted when a drug is administered (with or without error).
signal drug_administered(patient: Node, drug_key: String, dose: String, route: String, error: MedError)


func _ready() -> void:
	_load_drug_database()


func _load_drug_database() -> void:
	var file := FileAccess.open("res://data/drugs.json", FileAccess.READ)
	if not file:
		push_error("DrugAdministrationManager: Cannot open drugs.json")
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		_drugs = json.data
	file.close()


## Get drug data for display in UI.
func get_drug_data(drug_key: String) -> Dictionary:
	return _drugs.get(drug_key, {})


## Get all available drug keys.
func get_all_drug_keys() -> Array:
	return _drugs.keys()


## Get drugs filtered by category (BLS or ALS).
func get_drugs_by_category(category: String) -> Array:
	var result: Array = []
	for key in _drugs:
		if _drugs[key].get("category", "") == category:
			result.append(key)
	return result


## Attempt to administer a drug. Returns a result dict with error classification.
func administer(patient: Node, drug_key: String, dose: String, route: String) -> Dictionary:
	var drug: Dictionary = _drugs.get(drug_key, {})
	if drug.is_empty():
		return {"success": false, "error": MedError.WRONG_DRUG, "message": "Unknown drug."}

	var medical: Node = patient.get_node_or_null("MedicalStateComponent")
	var patient_name: String = patient.name
	var current_time: float = Time.get_ticks_msec() / 1000.0

	# Check route validity
	var valid_routes: Array = drug.get("valid_routes", [])
	if route not in valid_routes:
		return _log_error(patient, drug_key, dose, route, MedError.WRONG_ROUTE,
			"Invalid route '%s' for this drug. Valid: %s" % [route, ", ".join(valid_routes)])

	# Check IV access for IV/IO routes
	if route in ["IV", "IO"]:
		var deployed: Array = patient.get_meta("deployed_equipment", [])
		if "IV_ACCESS" not in deployed:
			return {"success": false, "error": MedError.WRONG_ROUTE,
				"message": "IV/IO route requires IV access first."}

	# Check contraindications (basic: check patient state)
	var contraindications: Array = drug.get("contraindications", [])
	if medical:
		for contra in contraindications:
			if _check_contraindication(medical, contra):
				return _log_error(patient, drug_key, dose, route, MedError.CONTRAINDICATED,
					"Contraindicated: %s" % contra)

	# Check max dose
	var max_mg: float = drug.get("max_dose_mg", 9999.0)
	var total_given: float = _get_total_given(patient_name, drug_key)
	var dose_mg: float = _parse_dose_mg(dose)
	if total_given + dose_mg > max_mg:
		return _log_error(patient, drug_key, dose, route, MedError.EXCEEDED_MAX_DOSE,
			"Maximum dose exceeded (%.1f mg limit)." % max_mg)

	# Repeat interval check REMOVED — player takes full responsibility.
	# AI reviewer will flag inappropriate re-dosing in the debrief.

	# Administer successfully — apply effects
	_record_administration(patient_name, drug_key, dose, route, current_time)
	if medical:
		_apply_drug_effects(medical, drug.get("effects", {}))

	# Log to telemetry
	drug_administered.emit(patient, drug_key, dose, route, MedError.NONE)

	return {
		"success": true,
		"error": MedError.NONE,
		"message": "%s %s administered via %s." % [drug.get("display_name", drug_key), dose, route],
		"drug_name": drug.get("display_name", drug_key),
	}


## Get administration log for a patient (for debrief).
func get_admin_log(patient: Node) -> Array:
	return _admin_log.get(patient.name, [])


## Get medication errors for a patient.
func get_medication_errors(patient: Node) -> Array:
	var log: Array = get_admin_log(patient)
	var errors: Array = []
	for entry in log:
		if entry.get("error", MedError.NONE) != MedError.NONE:
			errors.append(entry)
	return errors


func _check_contraindication(medical: Node, contra: String) -> bool:
	var lower := contra.to_lower()
	if "hypotension" in lower and medical.blood_pressure_systolic < 90:
		return true
	if "tachycardia" in lower and medical.heart_rate > 100:
		return true
	if "respiratory depression" in lower and medical.breathing_rate < 10.0:
		return true
	return false


func _parse_dose_mg(dose: String) -> float:
	# Extract numeric part from dose string like "0.3 mg" or "300 mg"
	var parts := dose.split(" ")
	if parts.size() > 0:
		return parts[0].to_float()
	return 0.0


func _get_total_given(patient_name: String, drug_key: String) -> float:
	var log: Array = _admin_log.get(patient_name, [])
	var total: float = 0.0
	for entry in log:
		if entry.get("drug_key", "") == drug_key and entry.get("error", MedError.NONE) == MedError.NONE:
			total += _parse_dose_mg(entry.get("dose", "0"))
	return total


func _get_last_admin_time(patient_name: String, drug_key: String) -> float:
	var patient_times: Dictionary = _last_admin.get(patient_name, {})
	return patient_times.get(drug_key, 0.0)


func _record_administration(patient_name: String, drug_key: String, dose: String, route: String, time: float) -> void:
	if not _admin_log.has(patient_name):
		_admin_log[patient_name] = []
	_admin_log[patient_name].append({
		"drug_key": drug_key,
		"dose": dose,
		"route": route,
		"time": time,
		"error": MedError.NONE,
	})
	if not _last_admin.has(patient_name):
		_last_admin[patient_name] = {}
	_last_admin[patient_name][drug_key] = time


func _log_error(patient: Node, drug_key: String, dose: String, route: String, error: MedError, message: String) -> Dictionary:
	if not _admin_log.has(patient.name):
		_admin_log[patient.name] = []
	_admin_log[patient.name].append({
		"drug_key": drug_key,
		"dose": dose,
		"route": route,
		"time": Time.get_ticks_msec() / 1000.0,
		"error": error,
		"message": message,
	})
	drug_administered.emit(patient, drug_key, dose, route, error)
	return {"success": false, "error": error, "message": message}


func _apply_drug_effects(medical: Node, effects: Dictionary) -> void:
	for effect_key in effects:
		var delta: int = effects[effect_key]
		match effect_key:
			"heart_rate":
				medical.set_modifier("heart_rate", medical.heart_rate + delta)
			"blood_pressure_systolic":
				medical.set_modifier("blood_pressure_systolic", medical.blood_pressure_systolic + delta)
			"breathing_rate":
				medical.set_modifier("breathing_rate", medical.breathing_rate + delta)
			"blood_glucose":
				medical.set_modifier("blood_glucose", medical.blood_glucose + delta)
			"spo2":
				medical.set_modifier("spo2", medical.spo2 + float(delta))
