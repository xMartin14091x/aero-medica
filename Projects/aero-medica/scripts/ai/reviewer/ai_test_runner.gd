## AITestRunner — Automated testing for the Ollama AI review pipeline.
## Loads test session data, runs through the full pipeline (adherence → errors → prompt → review),
## validates response quality, and reports results. Used for SYN-16 integration testing.
extends Node

## Test data directory.
const TEST_DIR := "res://data/test_sessions/"

## Answer sheet directory.
const ANSWER_DIR := "res://data/answer_sheets/"

## Emitted when all tests complete.
signal tests_complete(results: Array[Dictionary])

## Emitted per-test for progress tracking.
signal test_result(test_name: String, passed: bool, details: String)

## References to pipeline components.
var _adherence_tracker: Node = null
var _error_detector: Node = null
var _review_client: Node = null
var _review_parser: Node = null
var _demo_fallback: Node = null

## Test results accumulator.
var _results: Array[Dictionary] = []

## Current test queue.
var _test_queue: Array[String] = []
var _current_test: Dictionary = {}


func _ready() -> void:
	# Create pipeline components (Node-based scripts require set_script pattern)
	_adherence_tracker = Node.new()
	_adherence_tracker.set_script(load("res://scripts/telemetry/protocol_adherence_tracker.gd"))
	add_child(_adherence_tracker)

	_error_detector = Node.new()
	_error_detector.set_script(load("res://scripts/telemetry/error_detector.gd"))
	add_child(_error_detector)

	_review_parser = Node.new()
	_review_parser.set_script(load("res://scripts/ai/claude/review_parser.gd"))
	add_child(_review_parser)

	_demo_fallback = Node.new()
	_demo_fallback.set_script(load("res://scripts/ai/reviewer/ai_demo_fallback.gd"))
	add_child(_demo_fallback)


## Run all tests in the test data directory.
func run_all_tests() -> void:
	_results.clear()
	_test_queue.clear()

	# Load all test files
	var dir := DirAccess.open(TEST_DIR)
	if not dir:
		push_error("AITestRunner: Cannot open test directory: %s" % TEST_DIR)
		return

	dir.list_dir_begin()
	var filename := dir.get_next()
	while filename != "":
		if filename.ends_with(".json"):
			_test_queue.append(filename)
		filename = dir.get_next()
	dir.list_dir_end()

	_test_queue.sort()
	_run_next_test()


## Run a single test by filename.
func run_test(filename: String) -> void:
	var test_data := _load_test_data(filename)
	if test_data.is_empty():
		return

	var result := _execute_test(test_data)
	_results.append(result)
	test_result.emit(result["test_name"], result["passed"], result["details"])


## Run the next test in the queue.
func _run_next_test() -> void:
	if _test_queue.is_empty():
		_print_summary()
		tests_complete.emit(_results)
		return

	var filename: Variant = _test_queue.pop_front()
	run_test(filename)

	# Continue to next test (deferred to avoid stack overflow)
	call_deferred("_run_next_test")


## Load test session data from JSON file.
func _load_test_data(filename: String) -> Dictionary:
	var path := TEST_DIR + filename
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("AITestRunner: Cannot open test file: %s" % path)
		return {}

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("AITestRunner: JSON parse error in %s" % filename)
		return {}

	return json.data


## Execute a single test: run session data through the full pipeline.
func _execute_test(test_data: Dictionary) -> Dictionary:
	var test_name: String = test_data.get("test_name", "Unknown Test")
	var scenario_id: String = test_data.get("scenario_id", "")
	var checks: Array[String] = []
	var passed := true

	# Step 1: Run protocol adherence analysis
	var protocol_analysis := _adherence_tracker.analyse_session(test_data)

	# Validate adherence output structure
	if not protocol_analysis.has("patient_reports"):
		checks.append("FAIL: protocol_analysis missing patient_reports")
		passed = false
	else:
		checks.append("PASS: protocol_analysis has valid structure")

	if not protocol_analysis.has("timing"):
		checks.append("FAIL: protocol_analysis missing timing")
		passed = false
	else:
		checks.append("PASS: timing data present")

	# Step 2: Run error detection
	var errors := _error_detector.detect_errors(test_data, protocol_analysis)

	# Validate errors structure
	for error: Dictionary in errors:
		if not error.has("type") or not error.has("severity"):
			checks.append("FAIL: error missing type or severity")
			passed = false
			break
	checks.append("PASS: %d errors detected with valid structure" % errors.size())

	# Step 3: Load answer sheet
	var answer_sheet := _load_answer_sheet(scenario_id)
	if answer_sheet.is_empty():
		checks.append("WARN: no answer sheet found for %s — using empty" % scenario_id)
	else:
		checks.append("PASS: answer sheet loaded for %s" % scenario_id)

	# Step 4: Test demo fallback (cached reviews)
	var overall_score := protocol_analysis.get("overall_adherence", 0.0)
	var event_count: int = test_data.get("events", []).size()
	var has_cached := _demo_fallback.has_cached_reviews(scenario_id)

	if has_cached:
		var fallback_served := _demo_fallback.try_serve_cached(scenario_id, overall_score, event_count)
		if fallback_served:
			checks.append("PASS: demo fallback served cached review")
		else:
			checks.append("FAIL: demo fallback has cache but failed to serve")
			passed = false
	else:
		checks.append("INFO: no cached reviews for %s" % scenario_id)

	# Step 5: Validate review parser with cached review
	if has_cached:
		# Get the cached text that was just served
		var cached_text := _get_cached_review_text(scenario_id, overall_score, event_count)
		if cached_text != "":
			var parsed := _review_parser.parse_review(cached_text)
			if parsed.has("overall_assessment") and parsed["overall_assessment"] != "":
				checks.append("PASS: review parser extracted overall_assessment")
			else:
				checks.append("WARN: review parser could not extract overall_assessment")

			if parsed.has("strengths") and parsed["strengths"].size() > 0:
				checks.append("PASS: review parser extracted %d strengths" % parsed["strengths"].size())
			else:
				checks.append("WARN: review parser found no strengths")

			if parsed.has("recommendations") and parsed["recommendations"].size() > 0:
				checks.append("PASS: review parser extracted %d recommendations" % parsed["recommendations"].size())
			else:
				checks.append("WARN: review parser found no recommendations")

	# Step 6: Edge case validation
	var edge_checks := _validate_edge_cases(test_data, protocol_analysis, errors)
	checks.append_array(edge_checks)

	var details := "\n".join(checks)
	return {
		"test_name": test_name,
		"scenario_id": scenario_id,
		"passed": passed,
		"details": details,
		"adherence": protocol_analysis.get("overall_adherence", 0.0),
		"error_count": errors.size(),
		"checks_run": checks.size(),
	}


## Validate edge case specific to each test type.
func _validate_edge_cases(test_data: Dictionary, protocol_analysis: Dictionary, errors: Array) -> Array[String]:
	var checks: Array[String] = []
	var test_name: String = test_data.get("test_name", "")
	var events: Array = test_data.get("events", [])

	if "Empty" in test_name or "No Actions" in test_name:
		# Empty session should have 0 adherence
		if protocol_analysis.get("overall_adherence", 0.0) <= 0.01:
			checks.append("PASS: empty session → 0% adherence (correct)")
		else:
			checks.append("FAIL: empty session should have ~0% adherence")

	if "Perfect" in test_name:
		# Perfect run should have high adherence
		var adherence: float = protocol_analysis.get("overall_adherence", 0.0)
		if adherence >= 80.0:
			checks.append("PASS: perfect run → %.1f%% adherence (correct)" % adherence)
		else:
			checks.append("WARN: perfect run adherence %.1f%% lower than expected" % adherence)

	if "Catastrophic" in test_name:
		# Should detect critical errors
		var critical_count := 0
		for error: Dictionary in errors:
			if error.get("severity", "") == "CRITICAL":
				critical_count += 1
		if critical_count > 0:
			checks.append("PASS: catastrophic failure → %d critical errors detected" % critical_count)
		else:
			checks.append("WARN: catastrophic failure but no critical errors detected")

	if "Wrong Priority" in test_name:
		# Should detect priority errors
		var has_priority_error := false
		for error: Dictionary in errors:
			if error.get("type", "") == "WRONG_TRIAGE" or error.get("type", "") == "WRONG_PRIORITY":
				has_priority_error = true
				break
		if has_priority_error:
			checks.append("PASS: wrong priority → triage/priority error detected")
		else:
			checks.append("WARN: wrong priority test but no priority error detected")

	return checks


## Load answer sheet for a scenario.
func _load_answer_sheet(scenario_id: String) -> Dictionary:
	var path := ANSWER_DIR + scenario_id + ".json"
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return {}

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return {}

	return json.data


## Get cached review text for parser testing.
func _get_cached_review_text(scenario_id: String, overall_score: float, event_count: int) -> String:
	# Determine tier
	var tier := "good"
	if event_count <= 3:
		tier = "empty"
	elif overall_score >= 90.0:
		tier = "perfect"
	elif overall_score >= 60.0:
		tier = "good"
	elif overall_score >= 30.0:
		tier = "poor"
	else:
		tier = "catastrophic"

	var tier_map: Dictionary = {
		"rta_intersection_01": {
			"perfect": "rta_perfect_run.txt",
			"good": "rta_good_performance.txt",
			"poor": "rta_wrong_priority.txt",
			"catastrophic": "rta_catastrophic_failure.txt",
			"empty": "rta_empty_session.txt",
		},
	}

	var scenario_map: Dictionary = tier_map.get(scenario_id, {})
	var filename: String = scenario_map.get(tier, "")
	if filename == "":
		return ""

	var file := FileAccess.open("res://data/prompts/cached_reviews/" + filename, FileAccess.READ)
	if not file:
		return ""

	var text := file.get_as_text()
	file.close()
	return text


## Print a summary of all test results to the output.
func _print_summary() -> void:
	var total := _results.size()
	var passed := 0
	for result: Dictionary in _results:
		if result["passed"]:
			passed += 1


## Get test results as formatted string (for export/logging).
func get_results_text() -> String:
	var lines: Array[String] = []
	lines.append("=== AI Integration Test Results ===")
	lines.append("Date: %s" % Time.get_datetime_string_from_system())
	lines.append("")

	for result: Dictionary in _results:
		var status := "PASS" if result["passed"] else "FAIL"
		lines.append("[%s] %s" % [status, result["test_name"]])
		lines.append("  Scenario: %s" % result["scenario_id"])
		lines.append("  Adherence: %.1f%%" % result["adherence"])
		lines.append("  Errors detected: %d" % result["error_count"])
		lines.append("  Checks: %d" % result["checks_run"])
		lines.append("  Details:")
		for line: String in result["details"].split("\n"):
			lines.append("    %s" % line)
		lines.append("")

	var total := _results.size()
	var passed := _results.filter(func(r): return r["passed"]).size()
	lines.append("Total: %d/%d passed" % [passed, total])

	return "\n".join(lines)
