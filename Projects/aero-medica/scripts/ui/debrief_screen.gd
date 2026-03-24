## DebriefScreen — End-of-scenario debrief shown immediately when scenario ends.
## Quick stats + per-patient summary cards. Transitions to ReviewPanel when AI review arrives.
## Wired to ScenarioManager.scenario_ended, OllamaReviewClient, ReviewParser.
extends Control

## Emitted when the player wants to return to the menu.
signal return_to_menu()

## UI references — built in _ready.
var _background: ColorRect = null
var _title_label: Label = null
var _stats_vbox: VBoxContainer = null
var _patients_scroll: ScrollContainer = null
var _patients_vbox: VBoxContainer = null
var _review_status_label: Label = null
var _review_text_label: RichTextLabel = null
var _review_scroll: ScrollContainer = null
var _review_panel: Control = null

## Stored session data for metrics.
var _session_results: Dictionary = {}
var _review_requested: bool = false


func _ready() -> void:
	visible = false
	_build_ui()
	_wire_signals.call_deferred()


func _build_ui() -> void:
	# Dark overlay
	_background = ColorRect.new()
	_background.color = Color(0.06, 0.06, 0.1, 0.97)
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_background)

	# Main margin
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 50)
	margin.add_theme_constant_override("margin_right", 50)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	var outer_vbox := VBoxContainer.new()
	outer_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(outer_vbox)

	# Title
	_title_label = Label.new()
	_title_label.text = "Scenario Complete"
	_title_label.add_theme_font_size_override("font_size", 36)
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_vbox.add_child(_title_label)

	outer_vbox.add_child(HSeparator.new())

	# Top: quick stats
	var stats_header := Label.new()
	stats_header.text = "Quick Summary"
	stats_header.add_theme_font_size_override("font_size", 22)
	outer_vbox.add_child(stats_header)

	_stats_vbox = VBoxContainer.new()
	outer_vbox.add_child(_stats_vbox)

	outer_vbox.add_child(HSeparator.new())

	# Middle: per-patient summary cards
	var patients_header := Label.new()
	patients_header.text = "Patient Summary"
	patients_header.add_theme_font_size_override("font_size", 22)
	outer_vbox.add_child(patients_header)

	_patients_scroll = ScrollContainer.new()
	_patients_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_vbox.add_child(_patients_scroll)

	_patients_vbox = VBoxContainer.new()
	_patients_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_patients_scroll.add_child(_patients_vbox)

	outer_vbox.add_child(HSeparator.new())

	outer_vbox.add_child(HSeparator.new())

	# AI Review section
	_review_status_label = Label.new()
	_review_status_label.text = "AI Review"
	_review_status_label.add_theme_font_size_override("font_size", 22)
	_review_status_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))
	outer_vbox.add_child(_review_status_label)

	# Scrollable review text area
	_review_scroll = ScrollContainer.new()
	_review_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_review_scroll.custom_minimum_size = Vector2(0, 150)
	outer_vbox.add_child(_review_scroll)

	_review_text_label = RichTextLabel.new()
	_review_text_label.bbcode_enabled = true
	_review_text_label.fit_content = true
	_review_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_review_text_label.add_theme_font_size_override("normal_font_size", 14)
	_review_text_label.add_theme_color_override("default_color", Color(0.8, 0.85, 0.9))
	_review_text_label.text = ""
	_review_scroll.add_child(_review_text_label)

	# Buttons row
	var btn_hbox := HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_hbox.add_theme_constant_override("separation", 20)
	outer_vbox.add_child(btn_hbox)

	var menu_btn := Button.new()
	menu_btn.text = "Return to Menu"
	menu_btn.custom_minimum_size = Vector2(180, 40)
	menu_btn.pressed.connect(_on_return_to_menu)
	btn_hbox.add_child(menu_btn)


## Wire to ScenarioManager and AI review signals.
func _wire_signals() -> void:
	await get_tree().process_frame

	# Wire ScenarioManager.scenario_ended
	var scenario_mgr := get_node_or_null("/root/ScenarioManager")
	if scenario_mgr and scenario_mgr.has_signal("scenario_ended"):
		scenario_mgr.scenario_ended.connect(_on_scenario_ended)

	# Find ReviewPanel sibling (added to same parent)
	_review_panel = _find_sibling_review_panel()

	# Wire AI review signals — check autoload first, then scene tree
	var review_client := get_node_or_null("/root/OllamaReviewClient")
	if review_client:
		_wire_ai_signals(review_client)
	var root := get_tree().current_scene
	if root:
		_wire_ai_signals(root)


## Show debrief with immediate results from session data.
func show_debrief(results: Dictionary) -> void:
	_session_results = results
	visible = true
	_review_requested = false
	# Release mouse so player can interact with the debrief UI
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Set title with scenario name
	var scenario_name: String = results.get("scenario_name", "")
	if scenario_name != "":
		_title_label.text = "Scenario Complete — %s" % scenario_name
	else:
		_title_label.text = "Scenario Complete"

	_populate_stats(results)
	_populate_patient_cards(results)

	# Try to request AI review, show fallback if unavailable
	_request_ai_review(results)


## ScenarioManager.scenario_ended handler.
func _on_scenario_ended(results: Dictionary) -> void:
	show_debrief(results)


## Populate quick stats from session results.
func _populate_stats(results: Dictionary) -> void:
	for child in _stats_vbox.get_children():
		child.queue_free()

	var stats_grid := GridContainer.new()
	stats_grid.columns = 2
	stats_grid.add_theme_constant_override("h_separation", 24)
	stats_grid.add_theme_constant_override("v_separation", 6)
	_stats_vbox.add_child(stats_grid)

	# Scenario time
	var duration: float = results.get("duration_seconds", 0.0)
	var time_limit: float = results.get("time_limit", 0.0)
	var minutes := int(duration) / 60
	var seconds := int(duration) % 60
	var time_text := "%02d:%02d" % [minutes, seconds]
	if time_limit > 0.0:
		var lim_min := int(time_limit) / 60
		var lim_sec := int(time_limit) % 60
		time_text += " / %02d:%02d" % [lim_min, lim_sec]
	_add_stat(stats_grid, "Time Taken", time_text)

	# Patients found / total
	var events: Array = results.get("events", [])
	var patients_total: int = results.get("patient_count", 0)
	var patients_assessed := _count_unique_patients_assessed(events)
	_add_stat(stats_grid, "Patients Assessed", "%d / %d" % [patients_assessed, patients_total])

	# Equipment deployed count
	var equip_count: int = 0
	for event: Dictionary in events:
		if event.get("type", "") == "treatment_applied":
			equip_count += 1
	# Also count from patient summaries
	var patient_summaries: Array = results.get("patient_summaries", [])
	for ps: Dictionary in patient_summaries:
		var deployed: Array = ps.get("deployed_equipment", [])
		equip_count = maxi(equip_count, deployed.size())
	_add_stat(stats_grid, "Equipment Deployed", str(equip_count))

	# Triage accuracy
	var triage_data: Dictionary = results.get("triage_summary", {})
	var accuracy: float = triage_data.get("accuracy", 0.0)
	var tagged: int = triage_data.get("total_tagged", 0)
	if patients_total > 1:
		_add_stat(stats_grid, "Triage Accuracy", "%.0f%% (%d/%d tagged)" % [accuracy, tagged, patients_total])
	else:
		_add_stat(stats_grid, "Triage", "N/A (single patient)")

	# Diagnosis accuracy
	var diag_data: Dictionary = results.get("diagnosis_summary", {})
	var diag_patients: int = diag_data.get("patients_diagnosed", 0)
	var diag_correct: int = diag_data.get("patients_with_correct", 0)
	var correct_list: Array = results.get("correct_diagnosis", [])
	if diag_patients > 0:
		_add_stat(stats_grid, "Diagnosis", "%d/%d patients with correct DDx" % [diag_correct, diag_patients])
	elif not correct_list.is_empty():
		_add_stat(stats_grid, "Correct Diagnosis", ", ".join(PackedStringArray(correct_list)))

	# Actions performed
	# Filter out system events
	var action_count: int = 0
	for event: Dictionary in events:
		var etype: String = event.get("type", "")
		if etype != "scenario_started" and etype != "scenario_ended" and etype != "scenario_time_expired":
			action_count += 1
	_add_stat(stats_grid, "Actions Performed", str(action_count))


## Populate per-patient summary cards.
func _populate_patient_cards(results: Dictionary) -> void:
	for child in _patients_vbox.get_children():
		child.queue_free()

	var patient_summaries: Array = results.get("patient_summaries", [])
	if patient_summaries.is_empty():
		# Build from available data
		patient_summaries = _build_patient_summaries_from_events(results)

	for summary: Dictionary in patient_summaries:
		_add_patient_card(summary)


## Build patient summaries from telemetry events if not provided directly.
func _build_patient_summaries_from_events(results: Dictionary) -> Array:
	var summaries: Array = []
	var events: Array = results.get("events", [])
	var seen_patients: Dictionary = {}

	for event: Dictionary in events:
		var target: String = event.get("target", "")
		if target == "" or target in seen_patients:
			continue
		var event_type: String = event.get("type", "")
		if event_type.begins_with("assess_") or event_type == "triage_assign":
			seen_patients[target] = true
			summaries.append({
				"name": target,
				"final_state": event.get("details", {}).get("state", "Unknown"),
				"triage_tag": event.get("details", {}).get("assigned_tag", ""),
				"triage_correct": event.get("details", {}).get("is_correct", true),
			})

	return summaries


## Add a patient summary card.
func _add_patient_card(summary: Dictionary) -> void:
	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	# Top row: name + state + triage
	var top_hbox := HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(top_hbox)

	# Patient name
	var name_lbl := Label.new()
	name_lbl.text = summary.get("name", "Unknown")
	name_lbl.add_theme_font_size_override("font_size", 16)
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(name_lbl)

	# Final state
	var state_lbl := Label.new()
	var final_state: String = summary.get("final_state", "Unknown")
	state_lbl.text = final_state
	state_lbl.add_theme_font_size_override("font_size", 14)
	var state_colour := Color.WHITE
	match final_state:
		"CONSCIOUS":
			state_colour = Color(0.3, 0.9, 0.3)
		"UNCONSCIOUS":
			state_colour = Color(1.0, 0.9, 0.2)
		"CARDIAC_ARREST":
			state_colour = Color(1.0, 0.3, 0.3)
		"DEAD":
			state_colour = Color(0.4, 0.4, 0.4)
	state_lbl.add_theme_color_override("font_color", state_colour)
	top_hbox.add_child(state_lbl)

	# Triage tag (colour-coded)
	var tag: String = summary.get("triage_tag", "")
	if tag != "":
		var tag_lbl := Label.new()
		tag_lbl.text = "[%s]" % tag
		tag_lbl.add_theme_font_size_override("font_size", 14)
		var tag_colours := {
			"GREEN": Color(0.0, 1.0, 0.0),
			"YELLOW": Color(1.0, 1.0, 0.0),
			"RED": Color(1.0, 0.0, 0.0),
			"BLACK": Color(0.5, 0.5, 0.5),
		}
		tag_lbl.add_theme_color_override("font_color", tag_colours.get(tag, Color.WHITE))
		top_hbox.add_child(tag_lbl)

	# Bottom row: equipment + diagnoses
	var deployed: Array = summary.get("deployed_equipment", [])
	if not deployed.is_empty():
		var equip_lbl := Label.new()
		var equip_names: PackedStringArray = PackedStringArray()
		for eq in deployed:
			equip_names.append(str(eq).replace("_", " ").capitalize())
		equip_lbl.text = "Equipment: %s" % ", ".join(equip_names)
		equip_lbl.add_theme_font_size_override("font_size", 12)
		equip_lbl.add_theme_color_override("font_color", Color(0.5, 0.7, 0.9))
		equip_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(equip_lbl)

	var diagnoses: Array = summary.get("diagnoses", [])
	if not diagnoses.is_empty():
		var diag_matches: int = summary.get("diagnosis_matches", 0)
		var diag_lbl := Label.new()
		diag_lbl.text = "DDx: %s (%d correct)" % [", ".join(PackedStringArray(diagnoses)), diag_matches]
		diag_lbl.add_theme_font_size_override("font_size", 12)
		var diag_colour := Color(0.3, 0.9, 0.3) if diag_matches > 0 else Color(1.0, 0.5, 0.3)
		diag_lbl.add_theme_color_override("font_color", diag_colour)
		diag_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(diag_lbl)

	_patients_vbox.add_child(card)


## Add a stat label pair to the grid.
func _add_stat(grid: GridContainer, label_text: String, value_text: String) -> void:
	var name_lbl := Label.new()
	name_lbl.text = label_text
	name_lbl.add_theme_font_size_override("font_size", 14)
	name_lbl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.7))
	grid.add_child(name_lbl)

	var val_lbl := Label.new()
	val_lbl.text = value_text
	val_lbl.add_theme_font_size_override("font_size", 18)
	grid.add_child(val_lbl)


## Count unique patients that were assessed (from telemetry events).
func _count_unique_patients_assessed(events: Array) -> int:
	var assessed: Dictionary = {}
	for event: Dictionary in events:
		var event_type: String = event.get("type", "")
		if event_type.begins_with("assess_"):
			assessed[event.get("target", "")] = true
	return assessed.size()


## Request AI review from OllamaReviewClient.
func _request_ai_review(results: Dictionary) -> void:
	var review_client: Node = get_node_or_null("/root/OllamaReviewClient")
	if not review_client or not review_client.has_method("request_review"):
		_review_status_label.text = "AI Review: Ollama not configured"
		_review_status_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		return

	# Show discovered URL if available
	var discovered_url: String = ""
	if review_client.has_method("get_discovered_url"):
		discovered_url = review_client.get_discovered_url()
	if discovered_url != "":
		_review_status_label.text = "Requesting AI Review from %s..." % discovered_url
	else:
		_review_status_label.text = "Discovering Ollama & requesting AI Review..."
	_review_status_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0))

	# Build rich session_data including all events and patient summaries
	var session_data: Dictionary = results.get("session_data", {})
	if session_data.is_empty():
		session_data = {
			"scenario_id": results.get("scenario_id", "unknown"),
			"duration_seconds": results.get("duration_seconds", 0.0),
			"events": results.get("events", []),
		}
	# Always include patient_summaries in session_data for AI context
	if not session_data.has("patient_summaries"):
		session_data["patient_summaries"] = results.get("patient_summaries", [])

	var protocol_analysis := {
		"overall_adherence": 0.0,
		"patient_reports": [],
	}
	var errors: Array = []
	var answer_sheet := {
		"correct_diagnosis": results.get("correct_diagnosis", []),
		"patient_count": results.get("patient_count", 0),
		"patient_summaries": results.get("patient_summaries", []),
		"triage_summary": results.get("triage_summary", {}),
		"diagnosis_summary": results.get("diagnosis_summary", {}),
		"player_hazard_time": results.get("player_hazard_time", 0.0),
	}

	review_client.request_review(session_data, protocol_analysis, errors, answer_sheet)

	# Timeout fallback — 30s to account for discovery + LLM generation
	var timer := get_tree().create_timer(30.0)
	timer.timeout.connect(_on_review_timeout)


func _on_review_timeout() -> void:
	if "Requesting" in _review_status_label.text or "Discovering" in _review_status_label.text or "Processing" in _review_status_label.text:
		var review_client: Node = get_node_or_null("/root/OllamaReviewClient")
		var url_hint := ""
		if review_client and review_client.has_method("get_discovered_url"):
			url_hint = review_client.get_discovered_url()
		if url_hint != "":
			_review_status_label.text = "AI Review: Ollama at %s not responding (model may be loading)" % url_hint
		else:
			_review_status_label.text = "AI Review: Ollama not found on localhost, 127.0.0.1, or LAN IPs"
		_review_status_label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.3))


## Wire AI review signals from OllamaReviewClient and ReviewParser.
func _wire_ai_signals(node: Node) -> void:
	# Look for ReviewParser
	if node.has_signal("review_parsed"):
		node.review_parsed.connect(_on_review_parsed)
	# Look for OllamaReviewClient
	if node.has_signal("review_received"):
		node.review_received.connect(_on_review_text_received)
	if node.has_signal("review_failed"):
		node.review_failed.connect(_on_review_failed)

	for child in node.get_children():
		_wire_ai_signals(child)


## ReviewParser.review_parsed — structured review data ready.
func _on_review_parsed(review_data: Dictionary) -> void:
	_review_status_label.text = "AI Review Ready"
	_review_status_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))

	if _review_panel and _review_panel.has_method("show_review"):
		# Build metrics from stored session data
		var metrics := _build_metrics_dict()
		_review_panel.show_review(review_data, metrics)


## OllamaReviewClient.review_received — display review text directly.
func _on_review_text_received(review_text: String) -> void:
	_review_status_label.text = "AI Review"
	_review_status_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))

	# Display the raw review text in the scrollable area
	if _review_text_label:
		_review_text_label.text = review_text


## OllamaReviewClient.review_failed — API error.
func _on_review_failed(error: String) -> void:
	_review_status_label.text = "AI Review unavailable"
	_review_status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))

	if _review_text_label:
		_review_text_label.text = error

	if _review_panel and _review_panel.has_method("show_error"):
		_review_panel.show_error("AI Review unavailable: " + error)


## Build metrics dictionary for ReviewPanel sidebar.
func _build_metrics_dict() -> Dictionary:
	var results := _session_results
	var duration: float = results.get("duration_seconds", 0.0)
	var minutes := int(duration) / 60
	var seconds := int(duration) % 60

	var events: Array = results.get("events", [])
	var assessed := _count_unique_patients_assessed(events)
	var triage_data: Dictionary = results.get("triage_summary", {})

	return {
		"scenario_time": "%02d:%02d" % [minutes, seconds],
		"patients_treated": str(assessed),
		"triage_accuracy": "%.0f%%" % triage_data.get("accuracy", 0.0),
		"protocol_adherence": results.get("protocol_adherence", "—"),
	}


## Find ReviewPanel as sibling in the same parent.
func _find_sibling_review_panel() -> Control:
	var parent := get_parent()
	if not parent:
		return null
	for child in parent.get_children():
		if child != self and child.has_method("show_review"):
			return child
	return null


func _on_return_to_menu() -> void:
	visible = false
	return_to_menu.emit()
	if GameManager:
		GameManager.change_state(GameManager.GameState.MENU)
		GameManager.change_scene("res://scenes/main/MainMenu.tscn")
