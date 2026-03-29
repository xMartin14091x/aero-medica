## AIDemoFallback — Serves cached AI reviews when Ollama is unavailable.
## Reviews stored in a single JSON file (res://data/cached_reviews.json) to ensure
## they are always included in exported builds. No dependency on .txt file export filters.
extends Node

## Cached review JSON path — JSON files are always exported by Godot.
const CACHE_JSON_PATH := "res://data/cached_reviews.json"

## Emitted when a cached review is served.
signal cached_review_served(review_text: String, is_cached: bool)

## Performance tier thresholds for matching cached reviews.
const TIER_PERFECT := 90.0
const TIER_GOOD := 60.0
const TIER_POOR := 30.0

## Mapping: scenario_id -> {tier -> key_in_json}
var _cache_map: Dictionary = {
	"rta_intersection_01": {
		"perfect": "rta_perfect_run",
		"good": "rta_good_performance",
		"poor": "rta_wrong_priority",
		"catastrophic": "rta_catastrophic_failure",
		"empty": "rta_empty_session",
	},
	"tutorial_01": {
		"perfect": "tutorial_perfect_run",
		"good": "tutorial_good_performance",
		"poor": "tutorial_wrong_priority",
		"catastrophic": "tutorial_catastrophic_failure",
		"empty": "tutorial_empty_session",
	},
	"building_fire_01": {
		"perfect": "building_fire_perfect_run",
		"good": "building_fire_good_performance",
		"poor": "building_fire_wrong_priority",
		"catastrophic": "building_fire_catastrophic_failure",
		"empty": "building_fire_empty_session",
	},
	"cardiac_arrest_01": {
		"perfect": "cardiac_arrest_perfect_run",
		"good": "cardiac_arrest_good_performance",
		"poor": "cardiac_arrest_wrong_priority",
		"catastrophic": "cardiac_arrest_catastrophic_failure",
		"empty": "cardiac_arrest_empty_session",
	},
	"building_fire_multi": {
		"perfect": "building_fire_multi_perfect_run",
		"good": "building_fire_multi_good_performance",
		"poor": "building_fire_multi_wrong_priority",
		"catastrophic": "building_fire_multi_catastrophic_failure",
		"empty": "building_fire_multi_empty_session",
	},
	"mci_market_01": {
		"perfect": "mci_market_perfect_run",
		"good": "mci_market_good_performance",
		"poor": "mci_market_wrong_priority",
		"catastrophic": "mci_market_catastrophic_failure",
		"empty": "mci_market_empty_session",
	},
}

## All cached review texts loaded from JSON at startup.
var _review_data: Dictionary = {}


func _ready() -> void:
	_load_review_json()


## Load all cached reviews from the single JSON file.
func _load_review_json() -> void:
	var file := FileAccess.open(CACHE_JSON_PATH, FileAccess.READ)
	if not file:
		push_warning("AIDemoFallback: Cannot open %s — cached reviews unavailable" % CACHE_JSON_PATH)
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_warning("AIDemoFallback: JSON parse error in %s" % CACHE_JSON_PATH)
		return

	if json.data is Dictionary:
		_review_data = json.data
		print("AIDemoFallback: Loaded %d cached reviews from JSON" % _review_data.size())


## Try to serve a cached review based on scenario ID and overall score.
## Returns true if a cached review was found and emitted, false otherwise.
## When the active locale begins with "th", attempts Thai variant first.
func try_serve_cached(scenario_id: String, overall_score: float, event_count: int) -> bool:
	var tier := _determine_tier(overall_score, event_count)
	var use_thai := TranslationServer.get_locale().begins_with("th")

	# Attempt locale-specific cached review first, then fall back to default.
	var review_text := ""
	if use_thai:
		review_text = _get_review(scenario_id, tier, true)
	if review_text == "":
		review_text = _get_review(scenario_id, tier, false)

	if review_text != "":
		cached_review_served.emit(review_text, true)
		return true

	# Fallback: try any tier for this scenario
	var any_review := ""
	if use_thai:
		any_review = _get_any_review(scenario_id, true)
	if any_review == "":
		any_review = _get_any_review(scenario_id, false)

	if any_review != "":
		cached_review_served.emit(any_review, true)
		return true

	return false


## Determine performance tier from score and event count.
func _determine_tier(overall_score: float, event_count: int) -> String:
	if event_count <= 3:
		return "empty"
	if overall_score >= TIER_PERFECT:
		return "perfect"
	if overall_score >= TIER_GOOD:
		return "good"
	if overall_score >= TIER_POOR:
		return "poor"
	return "catastrophic"


## Get a specific cached review from the loaded JSON data.
func _get_review(scenario_id: String, tier: String, use_thai: bool = false) -> String:
	var scenario_map: Dictionary = _cache_map.get(scenario_id, {})
	var key: String = scenario_map.get(tier, "")
	if key == "":
		return ""

	if use_thai:
		key = key + "_th"

	return _review_data.get(key, "")


## Get any cached review for a scenario (first found).
func _get_any_review(scenario_id: String, use_thai: bool = false) -> String:
	var scenario_map: Dictionary = _cache_map.get(scenario_id, {})
	for tier: String in scenario_map:
		var text := _get_review(scenario_id, tier, use_thai)
		if text != "":
			return text
	return ""


## Register a new cached review for a scenario/tier combination.
func register_cached_review(scenario_id: String, tier: String, key: String) -> void:
	if scenario_id not in _cache_map:
		_cache_map[scenario_id] = {}
	_cache_map[scenario_id][tier] = key


## Get list of all scenario IDs that have cached reviews.
func get_cached_scenarios() -> Array[String]:
	var ids: Array[String] = []
	for key: String in _cache_map:
		ids.append(key)
	return ids


## Check if a scenario has any cached reviews available.
func has_cached_reviews(scenario_id: String) -> bool:
	if scenario_id not in _cache_map:
		return false
	if _cache_map[scenario_id].is_empty():
		return false
	# Verify at least one review actually exists in loaded data
	var scenario_map: Dictionary = _cache_map[scenario_id]
	for tier: String in scenario_map:
		if scenario_map[tier] in _review_data:
			return true
	return false
