## OllamaReviewClient — HTTP client for local Ollama AI performance review.
## Sends structured telemetry + answer sheet to Ollama and receives narrative review.
## Auto-discovers Ollama on localhost, 127.0.0.1, and LAN IPs.
## Fully offline, zero cost. Handles timeouts and Ollama-not-running gracefully.
extends Node

## Emitted when the AI review response is received.
signal review_received(review_text: String)

## Emitted when the review request fails (timeout, Ollama not running, etc.).
signal review_failed(error: String)

## Emitted when Ollama is discovered at an address.
signal ollama_discovered(url: String)

## HTTP request node for async API calls.
var _http: HTTPRequest = null

## Config loaded from user_data/ai_config.json.
var _config: Dictionary = {}

## System prompt loaded from data/prompts/triage_reviewer_system.txt.
var _system_prompt: String = ""

## Whether a request is currently in flight.
var _request_pending: bool = false

## Retry flag — retries once on failure.
var _retry_attempted: bool = false

## Stored request data for retry.
var _last_request_body: String = ""

## Discovered Ollama base URL (set by auto-discovery).
var _discovered_url: String = ""

## Whether discovery is complete.
var _discovery_done: bool = false

## Queued review request args waiting for discovery to complete.
var _queued_review_args: Array = []


func _ready() -> void:
	_load_config()
	_load_system_prompt()
	_setup_http()
	_discover_ollama()


## Load AI configuration from user_data/ai_config.json.
func _load_config() -> void:
	var path := "user://ai_config.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		# Try res:// path as fallback
		file = FileAccess.open("res://user_data/ai_config.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			_config = json.data
		else:
			push_warning("OllamaReviewClient: Failed to parse ai_config.json")

	# Defaults
	if _config.is_empty():
		_config = {
			"ollama_url": "",
			"model": "llama3.1:8b",
			"request_timeout_seconds": 60,
			"max_tokens": 1500,
			"retry_on_failure": true,
		}


## Load the system prompt from data/prompts/.
func _load_system_prompt() -> void:
	var file := FileAccess.open("res://data/prompts/triage_reviewer_system.txt", FileAccess.READ)
	if file:
		_system_prompt = file.get_as_text()
	else:
		push_warning("OllamaReviewClient: Cannot load system prompt")
		_system_prompt = "You are a clinical instructor reviewing student EMT performance."


## Set up the HTTPRequest node.
func _setup_http() -> void:
	_http = HTTPRequest.new()
	_http.timeout = _config.get("request_timeout_seconds", 60)
	_http.request_completed.connect(_on_request_completed)
	add_child(_http)


## Auto-discover Ollama by probing candidate addresses in parallel.
## Checks: localhost, 127.0.0.1, and all local network IPs on port 11434.
func _discover_ollama() -> void:
	# If config explicitly sets a URL, use it directly
	var config_url: String = _config.get("ollama_url", "")
	if config_url != "":
		_discovered_url = config_url
		_discovery_done = true
		print("OllamaReviewClient: Using configured URL: %s" % config_url)
		ollama_discovered.emit(config_url)
		_flush_queued_reviews()
		return

	# Build candidate list: localhost, 127.0.0.1, then all local IPs
	var candidates: Array[String] = []
	candidates.append("http://localhost:11434")
	candidates.append("http://127.0.0.1:11434")

	# Get all local network addresses from the OS
	var local_addresses: PackedStringArray = IP.get_local_addresses()
	for addr in local_addresses:
		# Skip loopback and IPv6 link-local
		if addr == "127.0.0.1" or addr == "::1":
			continue
		if addr.begins_with("fe80:"):
			continue
		# Only use IPv4 addresses (contain dots, no colons)
		if "." in addr and ":" not in addr:
			var candidate := "http://%s:11434" % addr
			if candidate not in candidates:
				candidates.append(candidate)

	print("OllamaReviewClient: Probing %d candidates: %s" % [candidates.size(), str(candidates)])

	# Probe each candidate in parallel with a lightweight GET /api/tags
	for candidate_url in candidates:
		var probe := HTTPRequest.new()
		probe.timeout = 3  # Short timeout for discovery probes
		add_child(probe)
		probe.set_meta("candidate_url", candidate_url)
		probe.request_completed.connect(_on_probe_completed.bind(probe, candidate_url))
		var err := probe.request(candidate_url + "/api/tags")
		if err != OK:
			probe.queue_free()
		else:
			# Track the probe node (typed as Node to avoid Godot append issues)
			_queued_review_args.size()  # no-op; probes tracked via tree


## Handle a discovery probe response.
func _on_probe_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray, probe: HTTPRequest, candidate_url: String) -> void:
	probe.queue_free()

	# If already discovered, ignore late probes
	if _discovery_done:
		return

	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		_discovered_url = candidate_url
		_discovery_done = true
		print("OllamaReviewClient: Discovered Ollama at %s" % candidate_url)
		ollama_discovered.emit(candidate_url)
		_flush_queued_reviews()


## Process any review requests that were queued during discovery.
func _flush_queued_reviews() -> void:
	if _queued_review_args.is_empty():
		return
	var args: Array = _queued_review_args.pop_front()
	request_review(args[0], args[1], args[2], args[3])


## Get the active Ollama URL (discovered or fallback).
func _get_ollama_url() -> String:
	if _discovered_url != "":
		return _discovered_url
	return "http://localhost:11434"


## Request an AI review for a completed scenario session.
## session_data: Full telemetry session data from TelemetryCollector.
## protocol_analysis: Output from ProtocolAdherenceTracker.analyse_session().
## errors: Output from ErrorDetector.detect_errors().
## answer_sheet: Scenario-specific correct answers (from scenario JSON or protocol data).
func request_review(session_data: Dictionary, protocol_analysis: Dictionary, errors: Array, answer_sheet: Dictionary) -> void:
	# If discovery hasn't completed yet, queue the request
	if not _discovery_done:
		print("OllamaReviewClient: Discovery in progress, queuing review request...")
		_queued_review_args.append([session_data, protocol_analysis, errors, answer_sheet])
		return

	if _discovered_url == "":
		review_failed.emit("Ollama not found on any local address (localhost, 127.0.0.1, LAN IPs)")
		return

	if _request_pending:
		review_failed.emit("A review request is already in progress.")
		return

	# Compose the user prompt with all analysis data
	var user_prompt := _compose_user_prompt(session_data, protocol_analysis, errors, answer_sheet)

	# Build Ollama API request body
	var request_body := {
		"model": _config.get("model", "llama3.1:8b"),
		"prompt": user_prompt,
		"system": _system_prompt,
		"stream": false,
		"options": {
			"num_predict": _config.get("max_tokens", 1500),
		},
	}

	var body_json := JSON.stringify(request_body)
	_last_request_body = body_json
	_request_pending = true
	_retry_attempted = false

	var url: String = _get_ollama_url() + "/api/generate"
	var headers := ["Content-Type: application/json"]

	print("OllamaReviewClient: Sending review request to %s" % url)
	var err := _http.request(url, headers, HTTPClient.METHOD_POST, body_json)
	if err != OK:
		_request_pending = false
		review_failed.emit("Failed to send request to Ollama (error code: %d)" % err)


## Compose the user prompt from session data, analysis, and answer sheet.
func _compose_user_prompt(session_data: Dictionary, _protocol_analysis: Dictionary, _errors: Array, answer_sheet: Dictionary) -> String:
	var events: Array = session_data.get("events", [])
	var duration: float = session_data.get("duration_seconds", 0.0)

	var prompt := "You are reviewing a student EMT performance in a simulation. Be specific, constructive, and reference what they actually did.\n\n"

	# Scenario overview
	prompt += "## Scenario Overview\n"
	prompt += "- Scenario: %s\n" % session_data.get("scenario_id", "unknown")
	prompt += "- Duration: %.0f seconds (%.1f minutes)\n" % [duration, duration / 60.0]
	prompt += "- Patient count: %d\n" % answer_sheet.get("patient_count", 0)
	var correct_dx: Array = answer_sheet.get("correct_diagnosis", [])
	if not correct_dx.is_empty():
		prompt += "- Correct diagnoses: %s\n" % ", ".join(PackedStringArray(correct_dx))
	prompt += "\n"

	# Per-patient summaries (equipment deployed, diagnoses, triage, outcome)
	var patient_summaries: Array = answer_sheet.get("patient_summaries", session_data.get("patient_summaries", []))
	if not patient_summaries.is_empty():
		prompt += "## Per-Patient Summary\n"
		for ps: Dictionary in patient_summaries:
			prompt += "\n### %s\n" % ps.get("name", "Unknown Patient")
			prompt += "- Final state: %s\n" % ps.get("final_state", "Unknown")

			var triage_tag: String = ps.get("triage_tag", "")
			if triage_tag != "":
				var triage_correct: bool = ps.get("triage_correct", false)
				prompt += "- Triage tag assigned: %s (%s)\n" % [triage_tag, "CORRECT" if triage_correct else "INCORRECT"]
			else:
				prompt += "- Triage tag: NOT ASSIGNED\n"
			prompt += "- Correct triage: %s\n" % ps.get("correct_triage", "Unknown")

			var deployed: Array = ps.get("deployed_equipment", [])
			if not deployed.is_empty():
				var names: PackedStringArray = PackedStringArray()
				for eq in deployed:
					names.append(str(eq).replace("_", " "))
				prompt += "- Equipment deployed: %s\n" % ", ".join(names)
			else:
				prompt += "- Equipment deployed: none\n"

			var diagnoses: Array = ps.get("diagnoses", [])
			var diag_matches: int = ps.get("diagnosis_matches", 0)
			if not diagnoses.is_empty():
				prompt += "- Student diagnoses: %s (%d matching correct)\n" % [", ".join(PackedStringArray(diagnoses)), diag_matches]
			else:
				prompt += "- Student diagnoses: none submitted\n"

			# Timing data — how much budget remained (lower = more time spent on patient)
			var budget_left: float = ps.get("budget_remaining", -1.0)
			var budget_phase: String = ps.get("budget_phase", "")
			if budget_left >= 0.0:
				var budget_max: float = 120.0 if budget_phase == "phase2" else 300.0
				var time_spent: float = budget_max - budget_left
				prompt += "- Time attention: %.0fs of %.0fs budget used (%.0f%% attention given)\n" % [time_spent, budget_max, (time_spent / budget_max) * 100.0 if budget_max > 0 else 0.0]

	# Treatment events timeline
	var treatments: Array[String] = []
	var triage_events: Array[String] = []
	var state_changes: Array[String] = []
	for event: Dictionary in events:
		var etype: String = event.get("type", "")
		var t: float = event.get("timestamp", 0.0)
		var target: String = event.get("target", "?")
		var details: Dictionary = event.get("details", {})
		match etype:
			"treatment_applied":
				var equip: String = details.get("equipment_name", "unknown")
				var correct: bool = details.get("was_correct", false)
				treatments.append("  %.0fs — %s on %s [%s]" % [t, equip, target, "CORRECT" if correct else "INCORRECT"])
			"triage_assign":
				var atag: String = details.get("assigned_tag", "?")
				var ctag: String = details.get("correct_tag", "?")
				var ok: bool = details.get("was_correct", false)
				triage_events.append("  %.0fs — %s tagged %s (correct: %s) [%s]" % [t, target, atag, ctag, "✓" if ok else "✗"])
			"patient_state_changed":
				state_changes.append("  %.0fs — %s: %s → %s" % [t, target, details.get("old_state", "?"), details.get("new_state", "?")])

	if not treatments.is_empty():
		prompt += "\n## Treatments Applied\n"
		prompt += "\n".join(treatments) + "\n"
	else:
		prompt += "\n## Treatments Applied\nNone recorded.\n"

	if not triage_events.is_empty():
		prompt += "\n## Triage Assignments\n"
		prompt += "\n".join(triage_events) + "\n"

	if not state_changes.is_empty():
		prompt += "\n## Patient State Changes\n"
		prompt += "\n".join(state_changes) + "\n"

	# Triage summary — computed from per-patient correct_triage (ground truth).
	# Do NOT use triage_summary.accuracy — it may be stale from old algorithm runs.
	var ps_list: Array = answer_sheet.get("patient_summaries", [])
	var tagged_count: int = 0
	var correct_count: int = 0
	for ps_entry: Dictionary in ps_list:
		if ps_entry.get("triage_tag", "") != "":
			tagged_count += 1
			if ps_entry.get("triage_correct", false):
				correct_count += 1
	if tagged_count > 0:
		prompt += "\n## Triage Summary\n"
		prompt += "- Tagged: %d patients, %d correct, accuracy: %.0f%%\n" % [
			tagged_count, correct_count,
			float(correct_count) / float(tagged_count) * 100.0,
		]

	# Diagnosis summary
	var diag_summary: Dictionary = answer_sheet.get("diagnosis_summary", {})
	if not diag_summary.is_empty() and diag_summary.get("patients_diagnosed", 0) > 0:
		prompt += "\n## Diagnosis Summary\n"
		prompt += "- Patients with at least one correct diagnosis: %d / %d\n" % [
			diag_summary.get("patients_with_correct", 0),
			diag_summary.get("patients_diagnosed", 0),
		]

	# Hazard exposure data — scene safety penalty feedback
	var hazard_time: float = answer_sheet.get("player_hazard_time", 0.0)
	if hazard_time > 0.0:
		prompt += "\n## Hazard Exposure\n"
		prompt += "- The student spent %.0f seconds standing in hazard zones.\n" % hazard_time
		if hazard_time > 10.0:
			prompt += "- This is dangerously reckless behavior for an EMT. Scene safety is the FIRST priority in EMS protocol.\n"
		elif hazard_time > 5.0:
			prompt += "- This shows poor scene safety awareness. EMTs should avoid prolonged hazard exposure.\n"

	prompt += "\n## Your Task\n"
	prompt += "Write a concise 3-5 paragraph performance review covering:\n"
	prompt += "1. What the student did well\n"
	prompt += "2. Specific errors or missed steps (reference patient names and equipment)\n"
	prompt += "3. Priority areas for improvement\n"
	prompt += "Keep it professional, specific to the data above, and under 400 words.\n"
	prompt += "\n## CRITICAL RULES — DO NOT VIOLATE\n"
	prompt += "- If a student's triage tag MATCHES the 'Correct triage' listed above, it is CORRECT. Praise it. Do NOT suggest a different tag.\n"
	prompt += "- Only criticize a triage assignment if it does NOT match the correct triage listed.\n"
	prompt += "- Base ALL feedback on the data provided above. Do NOT invent errors or suggest actions not supported by the data.\n"
	prompt += "- If diagnoses are listed as correct (matches > 0), acknowledge that as a strength.\n"

	return prompt


## Handle HTTP response from Ollama.
func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_request_pending = false

	# Handle connection errors
	if result != HTTPRequest.RESULT_SUCCESS:
		var error_msg := _get_http_error_message(result)
		if _config.get("retry_on_failure", true) and not _retry_attempted:
			_retry_attempted = true
			_request_pending = true
			var url: String = _get_ollama_url() + "/api/generate"
			_http.request(url, ["Content-Type: application/json"], HTTPClient.METHOD_POST, _last_request_body)
			return
		review_failed.emit(error_msg)
		return

	# Handle non-200 responses
	if response_code != 200:
		review_failed.emit("Ollama returned HTTP %d" % response_code)
		return

	# Parse response JSON
	var response_text := body.get_string_from_utf8()
	var json := JSON.new()
	if json.parse(response_text) != OK:
		review_failed.emit("Failed to parse Ollama response: %s" % json.get_error_message())
		return

	var data: Dictionary = json.data
	var review: String = data.get("response", "")

	if review == "":
		review_failed.emit("Ollama returned empty response")
		return

	review_received.emit(review)


## Convert HTTP result code to human-readable error message.
func _get_http_error_message(result: int) -> String:
	match result:
		HTTPRequest.RESULT_CANT_CONNECT:
			return "Cannot connect to Ollama. Is it running? (ollama serve)"
		HTTPRequest.RESULT_CANT_RESOLVE:
			return "Cannot resolve Ollama host"
		HTTPRequest.RESULT_CONNECTION_ERROR:
			return "Connection error with Ollama"
		HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:
			return "TLS error connecting to Ollama"
		HTTPRequest.RESULT_NO_RESPONSE:
			return "No response from Ollama (timeout)"
		HTTPRequest.RESULT_REQUEST_FAILED:
			return "Ollama request failed"
		HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:
			return "Too many redirects"
		_:
			return "Unknown HTTP error (code: %d)" % result


## Check if Ollama is available by pinging the API.
func check_ollama_available(callback: Callable) -> void:
	var check_http := HTTPRequest.new()
	check_http.timeout = 5
	add_child(check_http)

	check_http.request_completed.connect(func(result: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		var available := (result == HTTPRequest.RESULT_SUCCESS and code == 200)
		callback.call(available)
		check_http.queue_free()
	)

	var url: String = _get_ollama_url() + "/api/tags"
	check_http.request(url)


## Get the currently configured model name.
func get_model_name() -> String:
	return _config.get("model", "llama3.1:8b")


## Check if a request is currently pending.
func is_pending() -> bool:
	return _request_pending


## Get the discovered Ollama URL (empty if not yet discovered).
func get_discovered_url() -> String:
	return _discovered_url


## Check if Ollama has been discovered.
func is_ollama_found() -> bool:
	return _discovery_done and _discovered_url != ""
