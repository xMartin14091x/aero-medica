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

## Timeline references.
var _timeline_tabs: HBoxContainer = null
var _timeline_vbox: VBoxContainer = null
var _timeline_events: Array = []  # All events from session
var _selected_patient_tab: String = ""  # Currently selected patient filter

## Stored session data for metrics.
var _session_results: Dictionary = {}
var _review_requested: bool = false


func _ready() -> void:
	visible = false
	_build_ui()
	_wire_signals.call_deferred()


func _build_ui() -> void:
	var T := ThemeMedical

	# Background
	_background = ColorRect.new()
	_background.color = T.c("bg_main")
	_background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_background)

	# Main margin
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_bottom", 24)
	add_child(margin)

	var outer_vbox := VBoxContainer.new()
	outer_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_vbox.add_theme_constant_override("separation", 12)
	margin.add_child(outer_vbox)

	# Title
	_title_label = Label.new()
	_title_label.text = tr("DEBRIEF_SCENARIO_COMPLETE")
	T.style_label(_title_label, "title_large", "accent_blue")
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer_vbox.add_child(_title_label)

	# ══ Main 2-column layout: Left (1/4) | Right (3/4) ══
	var main_row := HBoxContainer.new()
	main_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_row.add_theme_constant_override("separation", 16)
	outer_vbox.add_child(main_row)

	# ── LEFT COLUMN (1/4 width) ──
	var left_col := VBoxContainer.new()
	left_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_col.size_flags_stretch_ratio = 1.0
	left_col.add_theme_constant_override("separation", 12)
	main_row.add_child(left_col)

	# Quick Summary card (40% of left column)
	var stats_card := PanelContainer.new()
	T.style_panel(stats_card)
	stats_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stats_card.size_flags_stretch_ratio = 0.4
	left_col.add_child(stats_card)

	var stats_inner := VBoxContainer.new()
	stats_inner.add_theme_constant_override("separation", 6)
	stats_card.add_child(stats_inner)

	var stats_header := Label.new()
	stats_header.text = tr("DEBRIEF_STATS_HEADER")
	T.style_label(stats_header, "subtitle", "text_primary")
	stats_inner.add_child(stats_header)

	_stats_vbox = VBoxContainer.new()
	stats_inner.add_child(_stats_vbox)

	# Timeline card (60% of left column)
	var timeline_card := PanelContainer.new()
	T.style_panel(timeline_card)
	timeline_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	timeline_card.size_flags_stretch_ratio = 0.6
	left_col.add_child(timeline_card)

	var timeline_inner := VBoxContainer.new()
	timeline_inner.add_theme_constant_override("separation", 6)
	timeline_card.add_child(timeline_inner)

	var timeline_header := Label.new()
	timeline_header.text = "Timeline"
	T.style_label(timeline_header, "subtitle", "text_primary")
	timeline_inner.add_child(timeline_header)

	# Patient tabs (horizontal buttons to filter timeline)
	_timeline_tabs = HBoxContainer.new()
	_timeline_tabs.add_theme_constant_override("separation", 4)
	timeline_inner.add_child(_timeline_tabs)

	# Scrollable timeline events
	var timeline_scroll := ScrollContainer.new()
	timeline_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	timeline_inner.add_child(timeline_scroll)

	_timeline_vbox = VBoxContainer.new()
	_timeline_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_timeline_vbox.add_theme_constant_override("separation", 2)
	timeline_scroll.add_child(_timeline_vbox)

	# Patient Summary cards (below timeline in left column)
	var patients_header := Label.new()
	patients_header.text = tr("DEBRIEF_PATIENTS_HEADER")
	T.style_label(patients_header, "subtitle", "text_primary")
	left_col.add_child(patients_header)

	_patients_scroll = ScrollContainer.new()
	_patients_scroll.custom_minimum_size = Vector2(0, 100)
	left_col.add_child(_patients_scroll)

	_patients_vbox = VBoxContainer.new()
	_patients_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_patients_vbox.add_theme_constant_override("separation", 6)
	_patients_scroll.add_child(_patients_vbox)

	# ── RIGHT COLUMN (3/4 width) — AI Review ──
	var right_col := VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_col.size_flags_stretch_ratio = 3.0
	right_col.add_theme_constant_override("separation", 8)
	main_row.add_child(right_col)

	var review_card := PanelContainer.new()
	T.style_panel(review_card, "info")
	review_card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_col.add_child(review_card)

	var review_inner := VBoxContainer.new()
	review_inner.add_theme_constant_override("separation", 8)
	review_card.add_child(review_inner)

	_review_status_label = Label.new()
	_review_status_label.text = tr("REVIEW_TITLE")
	T.style_label(_review_status_label, "subtitle", "accent_blue")
	review_inner.add_child(_review_status_label)

	_review_scroll = ScrollContainer.new()
	_review_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	review_inner.add_child(_review_scroll)

	_review_text_label = RichTextLabel.new()
	_review_text_label.bbcode_enabled = true
	_review_text_label.fit_content = true
	_review_text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	T.style_rich_label(_review_text_label, "body")
	_review_text_label.text = ""
	_review_scroll.add_child(_review_text_label)

	# Return to Menu button (centered below both columns)
	var btn_hbox := HBoxContainer.new()
	btn_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	outer_vbox.add_child(btn_hbox)

	var menu_btn := Button.new()
	menu_btn.text = tr("DEBRIEF_RETURN_MENU")
	menu_btn.custom_minimum_size = Vector2(220, 48)
	T.style_button(menu_btn, "large")
	menu_btn.pressed.connect(_on_return_to_menu)
	btn_hbox.add_child(menu_btn)


## Wire to ScenarioManager and AI review signals.
func _wire_signals() -> void:
	await get_tree().process_frame

	# Wire ScenarioManager.scenario_ended
	var scenario_mgr := get_node_or_null("/root/ScenarioManager")
	if scenario_mgr and scenario_mgr.has_signal("scenario_ended"):
		if not scenario_mgr.scenario_ended.is_connected(_on_scenario_ended):
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

	# Disconnect on scene exit
	tree_exiting.connect(_disconnect_debrief_signals)


func _disconnect_debrief_signals() -> void:
	var scenario_mgr := get_node_or_null("/root/ScenarioManager")
	if scenario_mgr and scenario_mgr.has_signal("scenario_ended"):
		if scenario_mgr.scenario_ended.is_connected(_on_scenario_ended):
			scenario_mgr.scenario_ended.disconnect(_on_scenario_ended)
	var review_client := get_node_or_null("/root/OllamaReviewClient")
	if review_client:
		if review_client.has_signal("review_received") and review_client.review_received.is_connected(_on_review_text_received):
			review_client.review_received.disconnect(_on_review_text_received)
		if review_client.has_signal("review_failed") and review_client.review_failed.is_connected(_on_review_failed):
			review_client.review_failed.disconnect(_on_review_failed)


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
		_title_label.text = tr("DEBRIEF_SCENARIO_COMPLETE") + " — %s" % scenario_name
	else:
		_title_label.text = tr("DEBRIEF_SCENARIO_COMPLETE")

	_populate_stats(results)
	_populate_patient_cards(results)
	_populate_timeline(results)

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
	var T := ThemeMedical

	# Determine card severity from final state
	var final_state: String = summary.get("final_state", "Unknown")
	var severity := "normal"
	match final_state:
		"CONSCIOUS": severity = "good"
		"UNCONSCIOUS": severity = "warning"
		"CARDIAC_ARREST": severity = "critical"
		"DEAD": severity = "critical"

	var card := PanelContainer.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	T.style_panel(card, severity)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	# Top row: name + state + triage
	var top_hbox := HBoxContainer.new()
	top_hbox.add_theme_constant_override("separation", 16)
	vbox.add_child(top_hbox)

	# Patient name
	var name_lbl := Label.new()
	name_lbl.text = summary.get("name", "Unknown")
	T.style_label(name_lbl, "subtitle", "text_primary")
	name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_hbox.add_child(name_lbl)

	# Final state
	var state_lbl := Label.new()
	state_lbl.text = final_state
	T.style_label(state_lbl, "body")
	var state_colour := T.c("text_secondary")
	match final_state:
		"CONSCIOUS": state_colour = T.c("accent_green")
		"UNCONSCIOUS": state_colour = T.c("accent_yellow")
		"CARDIAC_ARREST": state_colour = T.c("accent_red")
		"DEAD": state_colour = T.c("text_muted")
	state_lbl.add_theme_color_override("font_color", state_colour)
	top_hbox.add_child(state_lbl)

	# Triage tag (colour-coded)
	var tag: String = summary.get("triage_tag", "")
	if tag != "":
		var tag_lbl := Label.new()
		tag_lbl.text = "[%s]" % tag
		T.style_label(tag_lbl, "body")
		tag_lbl.add_theme_color_override("font_color", T.triage_color(tag))
		top_hbox.add_child(tag_lbl)

	# Bottom row: equipment + diagnoses
	var deployed: Array = summary.get("deployed_equipment", [])
	if not deployed.is_empty():
		var equip_lbl := Label.new()
		var equip_names: PackedStringArray = PackedStringArray()
		for eq in deployed:
			equip_names.append(str(eq).replace("_", " ").capitalize())
		equip_lbl.text = "Equipment: %s" % ", ".join(equip_names)
		T.style_label(equip_lbl, "body_small", "accent_blue")
		equip_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(equip_lbl)

	var diagnoses: Array = summary.get("diagnoses", [])
	if not diagnoses.is_empty():
		var diag_matches: int = summary.get("diagnosis_matches", 0)
		var diag_lbl := Label.new()
		diag_lbl.text = "DDx: %s (%d correct)" % [", ".join(PackedStringArray(diagnoses)), diag_matches]
		T.style_label(diag_lbl, "body_small")
		var diag_colour := T.c("accent_green") if diag_matches > 0 else T.c("accent_yellow")
		diag_lbl.add_theme_color_override("font_color", diag_colour)
		diag_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox.add_child(diag_lbl)

	_patients_vbox.add_child(card)


## Add a stat label pair to the grid.
func _add_stat(grid: GridContainer, label_text: String, value_text: String) -> void:
	var T := ThemeMedical

	var name_lbl := Label.new()
	name_lbl.text = label_text
	T.style_label(name_lbl, "body", "text_secondary")
	grid.add_child(name_lbl)

	var val_lbl := Label.new()
	val_lbl.text = value_text
	T.style_label(val_lbl, "subtitle", "text_primary")
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
		_review_status_label.text = tr("DEBRIEF_OLLAMA_UNCONFIGURED")
		_review_status_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		return

	# Show discovered URL if available
	var discovered_url: String = ""
	if review_client.has_method("get_discovered_url"):
		discovered_url = review_client.get_discovered_url()
	if discovered_url != "":
		_review_status_label.text = tr("DEBRIEF_REQUESTING_REVIEW") % discovered_url
	else:
		_review_status_label.text = tr("DEBRIEF_DISCOVERING_OLLAMA")
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
		# Timeout — try cached fallback
		_on_review_failed("Ollama timeout after 30 seconds")


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
	_review_status_label.text = tr("DEBRIEF_REVIEW_READY")
	_review_status_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))

	if _review_panel and _review_panel.has_method("show_review"):
		# Build metrics from stored session data
		var metrics := _build_metrics_dict()
		_review_panel.show_review(review_data, metrics)


## OllamaReviewClient.review_received — display review text directly.
func _on_review_text_received(review_text: String) -> void:
	_review_status_label.text = tr("REVIEW_TITLE")
	_review_status_label.add_theme_color_override("font_color", Color(0.3, 0.9, 0.3))

	if _review_text_label:
		_review_text_label.text = _markdown_to_bbcode(review_text)


## OllamaReviewClient.review_failed — fallback to cached review, then show error.
func _on_review_failed(_error: String) -> void:
	# Try cached fallback before showing error
	var fallback: Node = get_node_or_null("/root/AIDemoFallback")
	if fallback and fallback.has_method("try_serve_cached"):
		var scenario_id: String = _session_results.get("scenario_id", "")
		var score: float = _session_results.get("overall_score", 50.0)
		var event_count: int = _session_results.get("events", []).size()
		if not fallback.cached_review_served.is_connected(_on_cached_review_served):
			fallback.cached_review_served.connect(_on_cached_review_served, CONNECT_ONE_SHOT)
		var served: bool = fallback.try_serve_cached(scenario_id, score, event_count)
		if served:
			return

	# No fallback available — show error
	_review_status_label.text = "AI Review unavailable (Ollama offline)"
	_review_status_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.3))

	if _review_text_label:
		_review_text_label.text = "[color=#cc8844]Ollama is not running. Start Ollama for live AI review, or cached reviews will be shown when available.[/color]"


## Cached review fallback handler.
func _on_cached_review_served(review_text: String, _is_cached: bool) -> void:
	_review_status_label.text = tr("REVIEW_CACHED")
	_review_status_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.3))

	if _review_text_label:
		_review_text_label.text = _markdown_to_bbcode(review_text)


## Convert basic markdown to BBCode for RichTextLabel display.
func _markdown_to_bbcode(text: String) -> String:
	var lines: PackedStringArray = text.split("\n")
	var result: String = ""
	for line in lines:
		var trimmed: String = line.strip_edges()
		if trimmed.begins_with("## "):
			result += "[b][font_size=20][color=#6cb4ee]%s[/color][/font_size][/b]\n" % trimmed.substr(3)
		elif trimmed.begins_with("# "):
			result += "[b][font_size=24][color=#6cb4ee]%s[/color][/font_size][/b]\n" % trimmed.substr(2)
		elif trimmed.begins_with("- **") and "**:" in trimmed:
			var parts: PackedStringArray = trimmed.substr(2).split("**:", true, 1)
			if parts.size() == 2:
				result += "  [color=#e8a838]%s[/color]:%s\n" % [parts[0].replace("**", ""), parts[1]]
			else:
				result += "  %s\n" % _inline_bold(trimmed.substr(2))
		elif trimmed.begins_with("- "):
			result += "  %s\n" % _inline_bold(trimmed.substr(2))
		elif trimmed == "":
			result += "\n"
		else:
			result += "%s\n" % _inline_bold(trimmed)
	return result


## Convert **bold** markers to BBCode [b] tags.
func _inline_bold(text: String) -> String:
	var out: String = text
	while "**" in out:
		var first: int = out.find("**")
		var second: int = out.find("**", first + 2)
		if second == -1:
			break
		var bold_text: String = out.substr(first + 2, second - first - 2)
		out = out.substr(0, first) + "[b]" + bold_text + "[/b]" + out.substr(second + 2)
	return out


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


## Event types to show in timeline + their display names.
const TIMELINE_EVENT_TYPES := {
	"interact": "Interacted",
	"assess_airway": "Checked Airway",
	"assess_breathing": "Checked Breathing",
	"assess_pulse": "Checked Pulse",
	"assess_consciousness": "Checked Consciousness",
	"assess_bleeding": "Checked Bleeding",
	"assess_heart_rate": "Checked Heart Rate",
	"assess_blood_pressure": "Checked Blood Pressure",
	"assess_spo2": "Checked SpO2",
	"assess_pupils": "Checked Pupils",
	"assess_temperature": "Checked Temperature",
	"assess_blood_glucose": "Checked Blood Glucose",
	"assess_capillary_refill": "Checked Capillary Refill",
	"assess_skin": "Checked Skin",
	"treatment_applied": "Treatment Applied",
	"triage_assign": "Triage Assigned",
	"patient_state_changed": "State Changed",
	"diagnosis_submitted": "Diagnosis Submitted",
	"cpr_performed": "CPR Performed",
	"secondary_survey": "Secondary Survey",
}

## Get patient names from patient_summaries (reliable source — not from raw events).
func _get_patient_names_from_results(results: Dictionary) -> Array[String]:
	var names: Array[String] = []
	var summaries: Array = results.get("patient_summaries", [])
	for s: Dictionary in summaries:
		var name: String = s.get("name", "")
		if name != "" and name not in names:
			names.append(name)
	return names


## Populate timeline with patient tabs and event entries.
func _populate_timeline(results: Dictionary) -> void:
	var T := ThemeMedical
	_timeline_events = results.get("events", [])

	# Clear existing tabs and entries
	for child in _timeline_tabs.get_children():
		child.queue_free()
	for child in _timeline_vbox.get_children():
		child.queue_free()

	# Get patient names from summaries (not raw events — avoids Sidewalk etc.)
	var patient_names := _get_patient_names_from_results(results)

	# "All" tab
	var all_btn := Button.new()
	all_btn.text = tr("DEBRIEF_FILTER_ALL")
	all_btn.custom_minimum_size = Vector2(60, 28)
	all_btn.focus_mode = Control.FOCUS_NONE
	all_btn.pressed.connect(_on_timeline_tab_pressed.bind(""))
	T.style_button(all_btn, "small")
	_timeline_tabs.add_child(all_btn)

	# Per-patient tabs — ordered by first interaction time
	for pname in patient_names:
		var tab_btn := Button.new()
		tab_btn.text = pname
		tab_btn.custom_minimum_size = Vector2(60, 28)
		tab_btn.focus_mode = Control.FOCUS_NONE
		tab_btn.pressed.connect(_on_timeline_tab_pressed.bind(pname))
		T.style_button(tab_btn, "small")
		_timeline_tabs.add_child(tab_btn)

	_selected_patient_tab = ""
	_refresh_timeline_entries(patient_names)


## Refresh timeline entries based on selected patient filter.
func _refresh_timeline_entries(known_patients: Array[String] = []) -> void:
	var T := ThemeMedical
	for child in _timeline_vbox.get_children():
		child.queue_free()

	# Sort events by timestamp
	var sorted_events := _timeline_events.duplicate()
	sorted_events.sort_custom(func(a: Dictionary, b: Dictionary): return a.get("timestamp", 0.0) < b.get("timestamp", 0.0))

	for event: Dictionary in sorted_events:
		var etype: String = event.get("type", "")

		# Only show recognized event types
		if etype not in TIMELINE_EVENT_TYPES:
			continue

		var target: String = event.get("target", "")

		# Filter out non-patient targets (Sidewalk, equipment entities, etc.)
		if target != "" and not known_patients.is_empty() and target not in known_patients:
			continue

		# Apply patient filter tab
		if _selected_patient_tab != "" and target != _selected_patient_tab:
			continue

		var timestamp: float = event.get("timestamp", 0.0)
		var minutes := int(timestamp) / 60
		var seconds := int(timestamp) % 60
		var details: Dictionary = event.get("details", {})

		# Build display text
		var action_name: String = TIMELINE_EVENT_TYPES[etype]

		# Enrich with details
		match etype:
			"treatment_applied":
				var equip: String = details.get("equipment_name", "")
				if equip != "":
					action_name = equip
				var correct: bool = details.get("was_correct", false)
				action_name += " [OK]" if correct else ""
			"triage_assign":
				var tag: String = details.get("assigned_tag", "")
				var correct: bool = details.get("was_correct", false)
				action_name = "Triage: %s %s" % [tag, "✓" if correct else "✗"]
			"patient_state_changed":
				var new_state: String = details.get("new_state", "")
				action_name = "→ %s" % new_state
			"diagnosis_submitted":
				var diags: Array = details.get("diagnoses", [])
				if not diags.is_empty():
					action_name = "DDx: %s" % ", ".join(PackedStringArray(diags))

		var display := "%02d:%02d  %s" % [minutes, seconds, action_name]
		if target != "" and _selected_patient_tab == "":
			display += "  — %s" % target

		var entry := Label.new()
		entry.text = display
		T.style_label(entry, "caption", "text_secondary")
		entry.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_timeline_vbox.add_child(entry)


## Handle timeline tab press — filter by patient.
func _on_timeline_tab_pressed(patient_name: String) -> void:
	_selected_patient_tab = patient_name
	var known := _get_patient_names_from_results(_session_results)
	_refresh_timeline_entries(known)

	# Highlight active tab
	var T := ThemeMedical
	for child in _timeline_tabs.get_children():
		if child is Button:
			if child.text == patient_name or (patient_name == "" and child.text == tr("DEBRIEF_FILTER_ALL")):
				child.add_theme_color_override("font_color", T.c("accent_blue"))
			else:
				child.add_theme_color_override("font_color", T.c("text_secondary"))


func _on_return_to_menu() -> void:
	visible = false
	return_to_menu.emit()
	if GameManager:
		GameManager.change_state(GameManager.GameState.MENU)
		GameManager.change_scene("res://scenes/main/MainMenu.tscn")
