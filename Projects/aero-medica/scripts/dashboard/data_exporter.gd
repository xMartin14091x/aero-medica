## DataExporter — Exports performance data as CSV or JSON files.
## Supports full session history export, per-patient breakdown, and AI review summaries.
## Triggered from dashboard UI via export methods.
extends Node

## Emitted when export completes successfully.
signal export_complete(path: String)

## Emitted when export fails.
signal export_failed(error: String)

## Reference to HistoryManager for retrieving session data.
var _history_manager: Node = null

## CSV column headers.
const CSV_HEADERS := [
	"Date",
	"Scenario ID",
	"Triage Speed",
	"Protocol Accuracy",
	"Decision Quality",
	"Equipment Handling",
	"Patient Outcome",
	"Overall Score",
	"Pass/Fail",
	"AI Review Summary",
]


func _ready() -> void:
	_history_manager = get_node_or_null("/root/HistoryManager")


## Export all session history as CSV to a file path.
func export_csv(path: String, scenario_id: String = "") -> void:
	if not _history_manager:
		export_failed.emit("HistoryManager not available")
		return

	var history: Array
	if scenario_id != "":
		history = _history_manager.get_history(scenario_id)
	else:
		history = _history_manager.get_all_history()

	if history.is_empty():
		export_failed.emit("No session data to export")
		return

	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		export_failed.emit("Cannot write to file: %s" % path)
		return

	# Write header row
	file.store_csv_line(PackedStringArray(CSV_HEADERS))

	# Write data rows
	for entry: Dictionary in history:
		var pass_fail: Dictionary = entry.get("pass_fail", {})
		var overall_pass: String = "PASS" if pass_fail.get("overall", false) else "FAIL"

		var row := PackedStringArray([
			entry.get("date", ""),
			entry.get("scenario_id", ""),
			"%.1f" % entry.get("triage_speed", 0.0),
			"%.1f" % entry.get("protocol_accuracy", 0.0),
			"%.1f" % entry.get("decision_quality", 0.0),
			"%.1f" % entry.get("equipment_handling", 0.0),
			"%.1f" % entry.get("patient_outcome", 0.0),
			"%.1f" % entry.get("overall", 0.0),
			overall_pass,
			entry.get("ai_review_summary", ""),
		])
		file.store_csv_line(row)

	file.close()
	export_complete.emit(path)


## Export full session data as JSON to a file path.
## Includes all score axes, history, and AI review text.
func export_json(path: String, scenario_id: String = "") -> void:
	if not _history_manager:
		export_failed.emit("HistoryManager not available")
		return

	var history: Array
	if scenario_id != "":
		history = _history_manager.get_history(scenario_id)
	else:
		history = _history_manager.get_all_history()

	if history.is_empty():
		export_failed.emit("No session data to export")
		return

	var export_data := {
		"export_date": Time.get_datetime_string_from_system(),
		"total_sessions": history.size(),
		"scenario_filter": scenario_id if scenario_id != "" else "all",
		"sessions": history,
	}

	# Add per-scenario summary statistics
	var scenario_ids: Array[String] = _history_manager.get_scenario_ids()
	var summaries: Array[Dictionary] = []
	for sid: String in scenario_ids:
		if scenario_id != "" and sid != scenario_id:
			continue
		var best: Dictionary = _history_manager.get_best_score(sid)
		var count: int = _history_manager.get_session_count(sid)
		var improvements: Dictionary = _history_manager.get_all_improvements(sid)
		summaries.append({
			"scenario_id": sid,
			"total_sessions": count,
			"best_score": best,
			"trends": improvements,
		})
	export_data["scenario_summaries"] = summaries

	var file := FileAccess.open(path, FileAccess.WRITE)
	if not file:
		export_failed.emit("Cannot write to file: %s" % path)
		return

	file.store_string(JSON.stringify(export_data, "\t"))
	file.close()
	export_complete.emit(path)


## Export with file dialog — opens Godot's FileDialog for user to choose location.
## format: "csv" or "json"
func export_with_dialog(format: String = "csv", scenario_id: String = "") -> void:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE

	match format:
		"csv":
			dialog.add_filter("*.csv", "CSV Files")
			dialog.current_file = "aeromedica_scores.csv"
		"json":
			dialog.add_filter("*.json", "JSON Files")
			dialog.current_file = "aeromedica_export.json"

	# Connect the file_selected signal
	dialog.file_selected.connect(func(path: String):
		match format:
			"csv":
				export_csv(path, scenario_id)
			"json":
				export_json(path, scenario_id)
		dialog.queue_free()
	)
	dialog.canceled.connect(func():
		dialog.queue_free()
	)

	# Add to scene tree and show
	var scene_root := get_tree().current_scene
	if scene_root:
		scene_root.add_child(dialog)
		dialog.popup_centered(Vector2i(800, 600))
	else:
		export_failed.emit("No scene root available for FileDialog")
		dialog.queue_free()


## Quick export to user_data directory (no dialog).
func quick_export_csv(scenario_id: String = "") -> String:
	var timestamp := int(Time.get_unix_time_from_system())
	var filename := "export_%d.csv" % timestamp
	var path := "user://exports/" + filename

	DirAccess.make_dir_recursive_absolute("user://exports/")
	export_csv(path, scenario_id)
	return path


## Quick export to user_data directory (no dialog).
func quick_export_json(scenario_id: String = "") -> String:
	var timestamp := int(Time.get_unix_time_from_system())
	var filename := "export_%d.json" % timestamp
	var path := "user://exports/" + filename

	DirAccess.make_dir_recursive_absolute("user://exports/")
	export_json(path, scenario_id)
	return path
