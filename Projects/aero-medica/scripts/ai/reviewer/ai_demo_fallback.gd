## AIDemoFallback — Serves cached AI reviews when Ollama is unavailable.
## Used for competition demo mode: judges see the AI review feature working
## without requiring a running Ollama instance or GPU.
## Falls back to cached reviews matched by scenario_id and performance tier.
extends Node

## Cached review directory path.
const CACHE_DIR := "res://data/prompts/cached_reviews/"

## Emitted when a cached review is served.
signal cached_review_served(review_text: String, is_cached: bool)

## Performance tier thresholds for matching cached reviews.
const TIER_PERFECT := 90.0
const TIER_GOOD := 60.0
const TIER_POOR := 30.0

## Mapping: scenario_id → {tier → filename} for cached review lookup.
var _cache_map: Dictionary = {
	"rta_intersection_01": {
		"perfect": "rta_perfect_run.txt",
		"good": "rta_good_performance.txt",
		"poor": "rta_wrong_priority.txt",
		"catastrophic": "rta_catastrophic_failure.txt",
		"empty": "rta_empty_session.txt",
	},
	"tutorial_01": {
		"perfect": "tutorial_perfect_run.txt",
		"good": "tutorial_good_performance.txt",
		"poor": "tutorial_wrong_priority.txt",
		"catastrophic": "tutorial_catastrophic_failure.txt",
		"empty": "tutorial_empty_session.txt",
	},
	"building_fire_01": {
		"perfect": "building_fire_perfect_run.txt",
		"good": "building_fire_good_performance.txt",
		"poor": "building_fire_wrong_priority.txt",
		"catastrophic": "building_fire_catastrophic_failure.txt",
		"empty": "building_fire_empty_session.txt",
	},
	"cardiac_arrest_01": {
		"perfect": "cardiac_arrest_perfect_run.txt",
		"good": "cardiac_arrest_good_performance.txt",
		"poor": "cardiac_arrest_wrong_priority.txt",
		"catastrophic": "cardiac_arrest_catastrophic_failure.txt",
		"empty": "cardiac_arrest_empty_session.txt",
	},
	"building_fire_multi": {
		"perfect": "building_fire_multi_perfect_run.txt",
		"good": "building_fire_multi_good_performance.txt",
		"poor": "building_fire_multi_wrong_priority.txt",
		"catastrophic": "building_fire_multi_catastrophic_failure.txt",
		"empty": "building_fire_multi_empty_session.txt",
	},
	"mci_market_01": {
		"perfect": "mci_market_perfect_run.txt",
		"good": "mci_market_good_performance.txt",
		"poor": "mci_market_wrong_priority.txt",
		"catastrophic": "mci_market_catastrophic_failure.txt",
		"empty": "mci_market_empty_session.txt",
	},
}


## Try to serve a cached review based on scenario ID and overall score.
## Returns true if a cached review was found and emitted, false otherwise.
## When the active locale begins with "th", attempts to load the Thai (_th) variant
## first, then falls back to the English version if the Thai file does not exist.
func try_serve_cached(scenario_id: String, overall_score: float, event_count: int) -> bool:
	var tier := _determine_tier(overall_score, event_count)
	var use_thai := TranslationServer.get_locale().begins_with("th")

	# Attempt locale-specific cached review first, then fall back to default.
	var review_text := ""
	if use_thai:
		review_text = _load_cached_review(scenario_id, tier, true)
	if review_text == "":
		review_text = _load_cached_review(scenario_id, tier, false)

	if review_text != "":
		cached_review_served.emit(review_text, true)
		return true

	# Fallback: try loading any review for this scenario (Thai first if applicable)
	var any_review := ""
	if use_thai:
		any_review = _load_any_cached_review(scenario_id, true)
	if any_review == "":
		any_review = _load_any_cached_review(scenario_id, false)

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


## Load a specific cached review file.
## When use_thai is true, appends "_th" before the file extension to load the
## Thai variant. Returns empty string if the file does not exist.
func _load_cached_review(scenario_id: String, tier: String, use_thai: bool = false) -> String:
	var scenario_map: Dictionary = _cache_map.get(scenario_id, {})
	var filename: String = scenario_map.get(tier, "")

	if filename == "":
		return ""

	if use_thai:
		filename = filename.replace(".txt", "_th.txt")

	var path := CACHE_DIR + filename
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return ""

	var text := file.get_as_text()
	file.close()
	return text


## Load any cached review for a scenario (first found).
## When use_thai is true, attempts to load Thai variants.
func _load_any_cached_review(scenario_id: String, use_thai: bool = false) -> String:
	var scenario_map: Dictionary = _cache_map.get(scenario_id, {})
	for tier: String in scenario_map:
		var text := _load_cached_review(scenario_id, tier, use_thai)
		if text != "":
			return text
	return ""


## Register a new cached review file for a scenario/tier combination.
func register_cached_review(scenario_id: String, tier: String, filename: String) -> void:
	if scenario_id not in _cache_map:
		_cache_map[scenario_id] = {}
	_cache_map[scenario_id][tier] = filename


## Get list of all scenario IDs that have cached reviews.
func get_cached_scenarios() -> Array[String]:
	var ids: Array[String] = []
	for key: String in _cache_map:
		ids.append(key)
	return ids


## Check if a scenario has any cached reviews available.
func has_cached_reviews(scenario_id: String) -> bool:
	return scenario_id in _cache_map and not _cache_map[scenario_id].is_empty()
