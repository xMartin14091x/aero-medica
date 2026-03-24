## HistoryManager — Persists session scores to local storage for progress tracking.
## Saves one JSON file per session in user_data/history/. Provides query methods
## for retrieving history, best scores, and improvement trends.
extends Node

## Storage directory for session history files.
const HISTORY_DIR := "user://history/"

## Maximum sessions to retain per scenario (oldest pruned beyond this).
const MAX_HISTORY_PER_SCENARIO := 100

## Trend calculation window (how many recent sessions to compare).
const TREND_WINDOW := 5

## Trend thresholds (delta percentage for IMPROVING/DECLINING vs STABLE).
const TREND_THRESHOLD := 3.0

## Trend direction constants.
const TREND_IMPROVING := "IMPROVING"
const TREND_DECLINING := "DECLINING"
const TREND_STABLE := "STABLE"


func _ready() -> void:
	# Ensure history directory exists
	DirAccess.make_dir_recursive_absolute(HISTORY_DIR)


## Save session scores after a scenario completes.
## Returns the saved file path.
func save_session_scores(scenario_id: String, scores: Dictionary, timestamp: float = 0.0, ai_review_summary: String = "") -> String:
	if timestamp <= 0.0:
		timestamp = Time.get_unix_time_from_system()

	var entry := {
		"scenario_id": scenario_id,
		"timestamp": timestamp,
		"date": Time.get_datetime_string_from_unix_time(int(timestamp)),
		"triage_speed": scores.get("triage_speed", 0.0),
		"protocol_accuracy": scores.get("protocol_accuracy", 0.0),
		"decision_quality": scores.get("decision_quality", 0.0),
		"equipment_handling": scores.get("equipment_handling", 0.0),
		"patient_outcome": scores.get("patient_outcome", 0.0),
		"overall": scores.get("overall", 0.0),
		"pass_fail": scores.get("pass_fail", {}),
		"ai_review_summary": ai_review_summary,
	}

	# Generate unique filename: scenario_timestamp.json
	var filename := "%s_%d.json" % [scenario_id, int(timestamp)]
	var path := HISTORY_DIR + filename

	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		push_error("HistoryManager: Cannot write to %s" % path)
		return ""

	file.store_string(JSON.stringify(entry, "\t"))
	file.close()

	# Prune old entries if over limit
	_prune_history(scenario_id)

	return path


## Get history for a specific scenario, ordered by most recent first.
## limit <= 0 returns all.
func get_history(scenario_id: String, limit: int = 0) -> Array[Dictionary]:
	var all_entries := _load_all_entries()
	var filtered: Array[Dictionary] = []

	for entry: Dictionary in all_entries:
		if entry.get("scenario_id", "") == scenario_id:
			filtered.append(entry)

	# Sort by timestamp descending (most recent first)
	filtered.sort_custom(func(a, b): return a.get("timestamp", 0) > b.get("timestamp", 0))

	if limit > 0 and filtered.size() > limit:
		filtered.resize(limit)

	return filtered


## Get history across all scenarios, ordered by most recent first.
func get_all_history(limit: int = 0) -> Array[Dictionary]:
	var all_entries := _load_all_entries()

	# Sort by timestamp descending
	all_entries.sort_custom(func(a, b): return a.get("timestamp", 0) > b.get("timestamp", 0))

	if limit > 0 and all_entries.size() > limit:
		all_entries.resize(limit)

	return all_entries


## Get best score for a specific scenario (highest overall).
func get_best_score(scenario_id: String) -> Dictionary:
	var history := get_history(scenario_id)
	if history.is_empty():
		return {}

	var best: Dictionary = history[0]
	for entry: Dictionary in history:
		if entry.get("overall", 0.0) > best.get("overall", 0.0):
			best = entry

	return best


## Get improvement trend for a specific axis on a scenario.
## Returns {current, previous, delta, trend} comparing recent vs earlier sessions.
func get_improvement(scenario_id: String, axis: String) -> Dictionary:
	var history := get_history(scenario_id)

	if history.size() < 2:
		return {
			"current": history[0].get(axis, 0.0) if history.size() > 0 else 0.0,
			"previous": 0.0,
			"delta": 0.0,
			"trend": TREND_STABLE,
			"sessions_analysed": history.size(),
		}

	# Current = average of most recent half of window
	var window := mini(TREND_WINDOW, history.size())
	var recent_count := maxi(1, window / 2)
	var earlier_count := window - recent_count

	var recent_avg := 0.0
	for i in recent_count:
		recent_avg += history[i].get(axis, 0.0)
	recent_avg /= recent_count

	var earlier_avg := 0.0
	for i in range(recent_count, recent_count + earlier_count):
		earlier_avg += history[i].get(axis, 0.0)
	earlier_avg /= earlier_count if earlier_count > 0 else 1

	var delta := recent_avg - earlier_avg
	var trend := TREND_STABLE
	if delta > TREND_THRESHOLD:
		trend = TREND_IMPROVING
	elif delta < -TREND_THRESHOLD:
		trend = TREND_DECLINING

	return {
		"current": snappedf(recent_avg, 0.1),
		"previous": snappedf(earlier_avg, 0.1),
		"delta": snappedf(delta, 0.1),
		"trend": trend,
		"sessions_analysed": window,
	}


## Get improvement trends for all 5 axes at once.
func get_all_improvements(scenario_id: String) -> Dictionary:
	var axes := ["triage_speed", "protocol_accuracy", "decision_quality", "equipment_handling", "patient_outcome", "overall"]
	var result := {}
	for axis: String in axes:
		result[axis] = get_improvement(scenario_id, axis)
	return result


## Get total session count for a scenario.
func get_session_count(scenario_id: String) -> int:
	return get_history(scenario_id).size()


## Get all unique scenario IDs that have history.
func get_scenario_ids() -> Array[String]:
	var all_entries := _load_all_entries()
	var ids: Array[String] = []
	for entry: Dictionary in all_entries:
		var sid: String = entry.get("scenario_id", "")
		if sid != "" and sid not in ids:
			ids.append(sid)
	return ids


## Load all history entries from disk.
func _load_all_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	var dir := DirAccess.open(HISTORY_DIR)
	if not dir:
		return entries

	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		if not dir.current_is_dir() and filename.ends_with(".json"):
			var entry := _load_entry(HISTORY_DIR + filename)
			if not entry.is_empty():
				entries.append(entry)
		filename = dir.get_next()
	dir.list_dir_end()

	return entries


## Load a single history entry from a JSON file.
func _load_entry(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json := JSON.new()
	var result := json.parse(file.get_as_text())
	file.close()

	if result != OK:
		push_warning("HistoryManager: Failed to parse %s" % path)
		return {}

	return json.data if json.data is Dictionary else {}


## Prune old history entries for a scenario beyond MAX_HISTORY_PER_SCENARIO.
func _prune_history(scenario_id: String) -> void:
	var history := get_history(scenario_id)
	if history.size() <= MAX_HISTORY_PER_SCENARIO:
		return

	# Remove oldest entries beyond the limit
	var to_remove: Array = history.slice(MAX_HISTORY_PER_SCENARIO)
	for entry: Dictionary in to_remove:
		var filename := "%s_%d.json" % [scenario_id, int(entry.get("timestamp", 0))]
		var path := HISTORY_DIR + filename
		DirAccess.remove_absolute(path)


## Clear all history for a specific scenario.
func clear_history(scenario_id: String) -> void:
	var history := get_history(scenario_id)
	for entry: Dictionary in history:
		var filename := "%s_%d.json" % [scenario_id, int(entry.get("timestamp", 0))]
		var path := HISTORY_DIR + filename
		DirAccess.remove_absolute(path)


## Clear all history.
func clear_all_history() -> void:
	var dir := DirAccess.open(HISTORY_DIR)
	if not dir:
		return

	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		if not dir.current_is_dir() and filename.ends_with(".json"):
			DirAccess.remove_absolute(HISTORY_DIR + filename)
		filename = dir.get_next()
	dir.list_dir_end()
