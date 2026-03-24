## ECGRhythmManager — Manages ECG rhythm database and image loading.
## Loaded as a singleton or accessed via ScenarioManager.
## Phase 5 (MON-13): Image-based ECG rhythm display system.
## ECG images are loaded from configurable paths in ecg_rhythms.json.
## Drop real PNG images at assets/textures/ecg/[rhythm_key].png — zero code changes needed.
extends Node

## Loaded rhythm database from JSON.
var _rhythms: Dictionary = {}

## Texture cache — rhythm_key → Texture2D (or null if not found).
var _texture_cache: Dictionary = {}

## Shockable rhythms — AED will recommend shock for these.
const SHOCKABLE_RHYTHMS: Array[String] = ["VENTRICULAR_FIBRILLATION", "VENTRICULAR_TACHYCARDIA"]


func _ready() -> void:
	_load_rhythm_database()


## Load rhythm definitions from JSON file.
func _load_rhythm_database() -> void:
	var file := FileAccess.open("res://data/ecg_rhythms.json", FileAccess.READ)
	if not file:
		push_error("ECGRhythmManager: Cannot open ecg_rhythms.json")
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		_rhythms = json.data
	file.close()


## Get rhythm data dictionary for a given rhythm key.
func get_rhythm_data(rhythm_key: String) -> Dictionary:
	return _rhythms.get(rhythm_key, {})


## Get display name for a rhythm key.
func get_display_name(rhythm_key: String) -> String:
	return _rhythms.get(rhythm_key, {}).get("display_name", rhythm_key)


## Get all rhythm keys for identification quiz.
func get_all_rhythm_keys() -> Array:
	return _rhythms.keys()


## Returns true if the rhythm is shockable (AED auto-analysis positive).
func is_shockable(rhythm_key: String) -> bool:
	return rhythm_key in SHOCKABLE_RHYTHMS


## Load the ECG texture for a rhythm key.
## Returns null if the image file is not found — UI should show placeholder.
func get_rhythm_texture(rhythm_key: String) -> Texture2D:
	if _texture_cache.has(rhythm_key):
		return _texture_cache[rhythm_key]
	var rhythm_data: Dictionary = _rhythms.get(rhythm_key, {})
	var image_path: String = rhythm_data.get("image_path", "")
	if image_path == "":
		return null
	if ResourceLoader.exists(image_path):
		var tex := load(image_path) as Texture2D
		_texture_cache[rhythm_key] = tex
		return tex
	# Image not found — cache null so we don't retry repeatedly
	_texture_cache[rhythm_key] = null
	return null


## Determine ECG mode based on what is attached to patient.
## AED mode: patient has AED attached — auto-analysis, shock advisory.
## Monitor mode: patient has cardiac monitor attached — manual identification.
## Returns "AED", "MONITOR", or "NONE".
func get_ecg_mode(patient: Node) -> String:
	if not patient:
		return "NONE"
	var deployed: Array = patient.get_meta("deployed_equipment", [])
	if "AED" in deployed:
		return "AED"
	if "CARDIAC_MONITOR" in deployed:
		return "MONITOR"
	return "NONE"
