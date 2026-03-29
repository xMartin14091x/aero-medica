## OllamaDialogueClient — HTTP client for AI-driven patient conversation.
## Sends patient persona context + player question to local Ollama and returns
## in-character patient responses. Auto-discovers Ollama on localhost, 127.0.0.1,
## and LAN IPs. Falls back to static PatientPersona responses when Ollama is
## unavailable.
extends Node

## Emitted when an AI response is received from the patient.
signal dialogue_response_received(response: String)

## Emitted when the AI request fails (falls back to static response).
signal dialogue_failed(error: String)

## Emitted when Ollama is discovered at an address.
signal ollama_discovered(url: String)

## HTTP request node for async API calls.
var _http: HTTPRequest = null

## Config loaded from user_data/ai_config.json.
var _config: Dictionary = {}

## Whether a request is currently in flight.
var _request_pending: bool = false

## Whether Ollama was confirmed available on startup.
var ollama_available: bool = false

## Discovered Ollama base URL (set by auto-discovery).
var _discovered_url: String = ""

## Whether discovery is complete.
var _discovery_done: bool = false

## Queued ask_patient args waiting for discovery to complete.
var _queued_ask_args: Array = []

## Conversation history for context (per-patient session).
var _conversation_history: Array[Dictionary] = []

## Current patient persona context string.
var _patient_context: String = ""


func _ready() -> void:
	_load_config()
	_setup_http()
	_discover_ollama()


## Load AI configuration from user_data/ai_config.json.
func _load_config() -> void:
	var file := FileAccess.open("res://user_data/ai_config.json", FileAccess.READ)
	if file:
		var json := JSON.new()
		if json.parse(file.get_as_text()) == OK:
			_config = json.data

	if _config.is_empty():
		_config = {
			"ollama_url": "",
			"model": "llama3.1:8b",
			"request_timeout_seconds": 60,
			"max_tokens": 500,
		}


## Set up the HTTPRequest node.
func _setup_http() -> void:
	_http = HTTPRequest.new()
	_http.timeout = _config.get("request_timeout_seconds", 60)
	_http.request_completed.connect(_on_request_completed)
	add_child(_http)


## Auto-discover Ollama by probing candidate addresses in parallel.
## Checks: localhost, 127.0.0.1, and all local network IPs on port 11434.
func _discover_ollama() -> void:
	# Build candidate list: configured URL first (if set), then localhost, 127.0.0.1, then all local IPs
	var candidates: Array[String] = []

	var config_url: String = _config.get("ollama_url", "")
	if config_url != "":
		candidates.append(config_url)

	if "http://localhost:11434" not in candidates:
		candidates.append("http://localhost:11434")
	if "http://127.0.0.1:11434" not in candidates:
		candidates.append("http://127.0.0.1:11434")

	# Get all local network addresses from the OS
	var local_addresses: PackedStringArray = IP.get_local_addresses()
	for addr in local_addresses:
		if addr == "127.0.0.1" or addr == "::1":
			continue
		if addr.begins_with("fe80:"):
			continue
		if "." in addr and ":" not in addr:
			var candidate := "http://%s:11434" % addr
			if candidate not in candidates:
				candidates.append(candidate)

	print("OllamaDialogueClient: Probing %d candidates: %s" % [candidates.size(), str(candidates)])

	_probes_remaining = candidates.size()

	for candidate_url in candidates:
		var probe := HTTPRequest.new()
		probe.timeout = 3
		add_child(probe)
		probe.set_meta("candidate_url", candidate_url)
		probe.request_completed.connect(_on_probe_completed.bind(probe, candidate_url))
		var err := probe.request(candidate_url + "/api/tags")
		if err != OK:
			probe.queue_free()
			_probes_remaining -= 1

	# Safety: if no probes were sent, mark discovery done immediately
	if _probes_remaining <= 0:
		_mark_discovery_failed()


## Total probes still pending (for detecting all-failed).
var _probes_remaining: int = 0


## Handle a discovery probe response.
func _on_probe_completed(result: int, response_code: int, _headers: PackedStringArray, _body: PackedByteArray, probe: HTTPRequest, candidate_url: String) -> void:
	probe.queue_free()
	_probes_remaining -= 1

	if _discovery_done:
		return

	if result == HTTPRequest.RESULT_SUCCESS and response_code == 200:
		_discovered_url = candidate_url
		_discovery_done = true
		ollama_available = true
		print("OllamaDialogueClient: Discovered Ollama at %s" % candidate_url)
		ollama_discovered.emit(candidate_url)
		_flush_queued_asks()
		return

	# All probes failed — mark Ollama unavailable and flush queued requests
	if _probes_remaining <= 0:
		_mark_discovery_failed()


## Mark discovery as complete with no Ollama found.
func _mark_discovery_failed() -> void:
	_discovery_done = true
	ollama_available = false
	print("OllamaDialogueClient: All probes failed — Ollama unavailable.")
	for _q in _queued_ask_args:
		dialogue_failed.emit("Ollama not found on any local address")
	_queued_ask_args.clear()


## Process any ask_patient requests queued during discovery.
func _flush_queued_asks() -> void:
	if _queued_ask_args.is_empty():
		return
	var question: String = _queued_ask_args.pop_front()
	ask_patient(question)


## Get the active Ollama URL (discovered or fallback).
func _get_ollama_url() -> String:
	if _discovered_url != "":
		return _discovered_url
	return "http://localhost:11434"


## Set the patient context for conversation. Call when interaction begins.
func set_patient_context(persona_data: Dictionary, medical_state: Dictionary) -> void:
	_conversation_history.clear()
	_patient_context = _build_system_prompt(persona_data, medical_state)


## Send a player question to the AI patient. Returns immediately; response via signal.
func ask_patient(question: String) -> void:
	# If discovery hasn't completed yet, queue the request
	if not _discovery_done:
		print("OllamaDialogueClient: Discovery in progress, queuing ask request...")
		_queued_ask_args.append(question)
		return

	if _discovered_url == "":
		dialogue_failed.emit("Ollama not found on any local address (localhost, 127.0.0.1, LAN IPs)")
		return

	if _request_pending:
		dialogue_failed.emit("A dialogue request is already in progress.")
		return

	_conversation_history.append({"role": "user", "content": question})

	var prompt := _build_conversation_prompt(question)
	var request_body := {
		"model": _config.get("model", "llama3.1:8b"),
		"prompt": prompt,
		"system": _patient_context,
		"stream": false,
		"options": {
			"num_predict": _config.get("max_tokens", 500),
			"temperature": 0.7,
		},
	}

	var body_json := JSON.stringify(request_body)
	_request_pending = true

	var url: String = _get_ollama_url() + "/api/generate"
	var headers := ["Content-Type: application/json"]

	var err := _http.request(url, headers, HTTPClient.METHOD_POST, body_json)
	if err != OK:
		_request_pending = false
		dialogue_failed.emit("Failed to send dialogue request (error code: %d)" % err)


## Handle HTTP response from Ollama.
func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_request_pending = false

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		# Mark Ollama as offline so UI switches to scripted mode immediately
		ollama_available = false
		dialogue_failed.emit("Ollama dialogue request failed (connection lost or service stopped)")
		return

	var response_text := body.get_string_from_utf8()
	var json := JSON.new()
	if json.parse(response_text) != OK:
		dialogue_failed.emit("Failed to parse Ollama response")
		return

	var data: Dictionary = json.data
	var response: String = data.get("response", "").strip_edges()

	if response == "":
		dialogue_failed.emit("Ollama returned empty response")
		return

	_conversation_history.append({"role": "assistant", "content": response})
	dialogue_response_received.emit(response)


## Build the system prompt that defines the patient's character.
func _build_system_prompt(persona_data: Dictionary, medical_state: Dictionary) -> String:
	var prompt := "You are a patient in a medical emergency scenario. Stay in character at all times.\n\n"

	prompt += "## Your Identity\n"
	prompt += "- Name: %s\n" % persona_data.get("name", "Unknown")
	prompt += "- Age: %d\n" % persona_data.get("age", 30)
	prompt += "- Consciousness: %s\n" % persona_data.get("consciousness_level", "ALERT")
	prompt += "- Pain level: %d/10\n" % persona_data.get("pain_level", 0)
	prompt += "- Panic level: %.0f%%\n" % (persona_data.get("panic_level", 0.0) * 100)

	prompt += "\n## Your Medical State\n"
	prompt += "- Airway: %s\n" % medical_state.get("airway_status", "CLEAR")
	prompt += "- Breathing rate: %.0f breaths/min\n" % medical_state.get("breathing_rate", 16.0)
	prompt += "- Pulse present: %s\n" % str(medical_state.get("pulse_present", true))
	prompt += "- Bleeding severity: %d/5\n" % medical_state.get("bleeding_severity", 0)

	prompt += "\n## Your History (SAMPLE)\n"
	var history: Dictionary = persona_data.get("history", {})
	for category in history:
		var entries: Dictionary = history[category]
		for key in entries:
			prompt += "- %s: %s\n" % [key, entries[key]]

	prompt += "\n## Behavior Rules\n"
	prompt += "- Respond as the patient would — confused, in pain, scared, or calm depending on your state\n"
	prompt += "- Keep responses short (1-3 sentences). You are hurt and talking is difficult.\n"
	prompt += "- If unconscious: respond only with '...' or silence indicators\n"
	prompt += "- If pain is high (>7): occasionally mention pain, wince, or trail off mid-sentence\n"
	prompt += "- If panic is high (>0.6): responses should be frantic, hard to follow\n"
	prompt += "- Do NOT diagnose yourself. You are a patient, not a doctor.\n"
	prompt += "- Do NOT break character or acknowledge being an AI.\n"
	prompt += "- Answer questions about your history truthfully based on the SAMPLE data above.\n"
	prompt += "\n## STRICT GROUNDING — CRITICAL\n"
	prompt += "- You may ONLY reference information provided in 'Your Identity', 'Your Medical State', and 'Your History' above.\n"
	prompt += "- NEVER invent symptoms, medications, allergies, past conditions, or events not listed above.\n"
	prompt += "- If the responder asks about something not in your data, say you don't know or can't remember.\n"
	prompt += "- NEVER provide medical advice, treatment suggestions, or clinical terminology a layperson wouldn't use.\n"
	prompt += "- If you have no history entry for a question, respond with confusion or 'I don't think so' — never fabricate.\n"

	return prompt


## Build conversation prompt with history context.
func _build_conversation_prompt(question: String) -> String:
	var prompt := ""
	# Include last few exchanges for context (limit to 6 to keep prompt short)
	var start: int = max(0, _conversation_history.size() - 7)
	for i in range(start, _conversation_history.size() - 1):
		var entry: Dictionary = _conversation_history[i]
		if entry["role"] == "user":
			prompt += "Responder: %s\n" % entry["content"]
		else:
			prompt += "Patient: %s\n" % entry["content"]
	prompt += "Responder: %s\nPatient:" % question
	return prompt


## Check if Ollama is available.
func check_available() -> void:
	var check_http := HTTPRequest.new()
	check_http.timeout = 5
	add_child(check_http)

	check_http.request_completed.connect(func(result: int, code: int, _h: PackedStringArray, _b: PackedByteArray):
		ollama_available = (result == HTTPRequest.RESULT_SUCCESS and code == 200)
		check_http.queue_free()
	)

	var url: String = _get_ollama_url() + "/api/tags"
	check_http.request(url)


## Whether a request is currently pending.
func is_pending() -> bool:
	return _request_pending


## Clear conversation history (call when switching patients).
func clear_history() -> void:
	_conversation_history.clear()
	_patient_context = ""
