## PatientInteractionUI — Full-screen tabbed panel for patient interaction.
## Opened when player presses E near a patient. Contains 4 tabs:
## Patient (info + AI talk), Exam (DRSABCDE), Stabilize (medical bag), Differential (diagnosis).
## Layout: left content panel + right vertical tab strip.
extends Control

## Emitted when the UI is closed (Escape or close button).
signal interaction_closed

## Emitted when an assessment action is performed.
signal assessment_action(action_name: String)

## Emitted when equipment is used from the medical bag.
signal equipment_used(equipment_type: String, patient: Node)

## Emitted when a diagnosis is selected.
signal diagnosis_selected(diagnosis: String)

## Tab identifiers.
enum Tab { PATIENT, EXAM, STABILIZE, DIFFERENTIAL }

## The patient node being interacted with.
var _patient: Node = null

## Player reference (for distance check).
var _player: Node = null

## Distance threshold — auto-close if player walks away.
const CLOSE_DISTANCE := 4.0

## Current active tab.
var _current_tab: Tab = Tab.PATIENT

## UI references (built in _ready).
var _tab_buttons: Dictionary = {}  # Tab enum → Button
var _tab_contents: Dictionary = {}  # Tab enum → Control
var _left_panel: PanelContainer = null
var _content_container: VBoxContainer = null

## Tab-specific state.
var _exam_buttons: Dictionary = {}  # action_name → Button
var _exam_results: Dictionary = {}  # action_name → Label
var _exam_completed: int = 0
var _exam_total: int = 8
var _exam_counter_label: Label = null
var _equipment_buttons: Dictionary = {}  # equip_type → Button
var _applied_equipment: Array[String] = []

## Maps Equipment button keys (lowercase) ↔ Bag manager keys (UPPERCASE).
const EQUIP_TO_BAG_KEY := {
	"oxygen_mask": "OXYGEN_MASK",
	"bvm": "BVM",
	"aed": "AED",
	"iv_access": "IV_ACCESS",
	"c_collar": "CERVICAL_COLLAR",
	"tourniquet": "TOURNIQUET",
	"bandage": "BANDAGE",
	"splint": "SPLINT_SAM",
	"stretcher": "STRETCHER",
	"pulse_oximeter": "PULSE_OXIMETER",
	"bp_cuff": "BP_CUFF",
	"penlight": "PENLIGHT",
	"thermometer": "THERMOMETER",
	"glucometer": "GLUCOMETER",
}
const BAG_TO_EQUIP_KEY := {
	"OXYGEN_MASK": "oxygen_mask",
	"BVM": "bvm",
	"AED": "aed",
	"IV_ACCESS": "iv_access",
	"CERVICAL_COLLAR": "c_collar",
	"TOURNIQUET": "tourniquet",
	"BANDAGE": "bandage",
	"SPLINT_SAM": "splint",
	"STRETCHER": "stretcher",
	"PULSE_OXIMETER": "pulse_oximeter",
	"BP_CUFF": "bp_cuff",
	"PENLIGHT": "penlight",
	"THERMOMETER": "thermometer",
	"GLUCOMETER": "glucometer",
}
var _diagnosis_buttons: Array[Button] = []
var _selected_diagnoses: Array[String] = []
var _diagnosis_submitted: bool = false
var _submit_diagnosis_btn: Button = null
var _diagnosis_rank_label: Label = null

## Chat elements (Patient tab).
var _chat_container: VBoxContainer = null
var _chat_scroll: ScrollContainer = null
var _chat_input: LineEdit = null
var _talk_button: Button = null
var _patient_info_label: RichTextLabel = null
var _ai_status_label: Label = null
var _patient_info_card: PanelContainer = null
var _patient_name_label: Label = null
var _patient_state_label: Label = null
var _patient_detail_label: Label = null

## Responsive grid tracking.
var _responsive_grids: Array[Dictionary] = []

## Differential tab — search + categories.
var _ddx_search_input: LineEdit = null
var _ddx_category_containers: Dictionary = {}
var _ddx_category_grids: Dictionary = {}
var _ddx_category_collapsed: Dictionary = {}
var _selected_chips_hbox: HBoxContainer = null

## Action cooldown system — tracks active cooldowns per group.
## Key = group name, Value = number of actions currently cooling down.
var _cooldown_active: Dictionary = {}  # group → int (active count)

## Cooldown queue — maps group name → Array of queued entries.
## Each entry: {"btn": Button, "group": String, "on_complete": Callable, "circle": _CooldownCircle, "original_text": String}
var _cooldown_queue: Dictionary = {}  # group → Array[Dictionary]
const COOLDOWN_CONFIG := {
	"drs":       {"delay": 0.5, "max_concurrent": 1},
	"abcde":     {"delay": 2.0, "max_concurrent": 1},
	"vitals":    {"delay": 1.5, "max_concurrent": 2},
	"secondary": {"delay": 2.0, "max_concurrent": 1},
	"equipment": {"delay": 3.0, "max_concurrent": 2},
	"drug":      {"delay": 5.0, "max_concurrent": 1},
}

## Ollama dialogue client reference.
var _dialogue_client: Node = null

## History taking manager reference.
var _history_manager: Node = null

## Assessment manager reference.
var _assessment_manager: Node = null

## ARC-12: OPQRST button reference.
var _opqrst_btn: Button = null

## ARC-13: Vital sign assessment buttons and result labels.
var _vital_buttons: Dictionary = {}  # key → Button
var _vital_results: Dictionary = {}  # key → Label

## ARC-14: ECG overlay panel and widgets.
var _ecg_panel: PanelContainer = null
var _ecg_texture_rect: TextureRect = null
var _ecg_rhythm_label: Label = null
var _ecg_mode_label: Label = null
var _ecg_rhythm_manager: Node = null

## ARC-15: GCS assessment UI.
var _gcs_component_selection: Dictionary = {}  # "eye"/"verbal"/"motor" → int (selected value, 0 = none)
var _gcs_component_btns: Dictionary = {}  # "eye_1"/"eye_2"/etc → Button
var _gcs_total_label: Label = null
var _gcs_severity_label: Label = null
var _gcs_manager: Node = null

## ARC-16: Secondary survey UI.
var _secondary_buttons: Dictionary = {}  # region → Button
var _secondary_results: Dictionary = {}  # region → Label
var _secondary_completed_count: int = 0
var _secondary_counter_label: Label = null
var _secondary_survey_manager: Node = null

## ARC-17: Drug administration UI.
var _drug_name_btn: OptionButton = null
var _drug_route_btn: OptionButton = null
var _drug_dose_btn: OptionButton = null
var _drug_feedback_label: Label = null
var _drug_log_vbox: VBoxContainer = null
var _drug_admin_manager: Node = null
var _drug_admin_btn: Button = null
var _triage_feedback_label: Label = null
var _current_drug_data: Dictionary = {}  # loaded drugs.json

## ARC-18: Medical bag tier UI.
var _bag_tier_label: Label = null
var _bag_items_vbox: VBoxContainer = null
var _bag_tier_manager: Node = null
var _current_bag_data: Dictionary = {}  # loaded medical_bag_tiers.json

## CPR action UI.
var _cpr_button: Button = null
var _cpr_status_label: Label = null
var _cpr_active: bool = false

## Close button reference for theme re-application.
var _close_btn: Button = null

## Exam sub-tab system.
var _exam_sub_tabs: Dictionary = {}  # name -> VBoxContainer
var _exam_sub_tab_btns: Dictionary = {}  # name -> Button
var _current_exam_sub: String = "primary"

## Stabilize sub-tab system.
var _stab_sub_tabs: Dictionary = {}  # name -> VBoxContainer
var _stab_sub_tab_btns: Dictionary = {}  # name -> Button
var _current_stab_sub: String = "equipment"


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_apply_theme()
	_find_systems.call_deferred()
	# Connect theme change signal for live re-styling.
	var theme_mgr := _get_theme_medical()
	if theme_mgr:
		if not theme_mgr.theme_changed.is_connected(_on_theme_changed):
			theme_mgr.theme_changed.connect(_on_theme_changed)
	# Disconnect autoload signals on scene exit
	tree_exiting.connect(_disconnect_autoload_signals_piu)


## Start a cooldown on a button with circular progress overlay.
## Callback fires AFTER delay with result.
## If group is at max concurrent, queues the action instead of rejecting.
## Returns true always (action either started or queued).
func _start_cooldown(btn: Button, group: String, on_complete: Callable = Callable()) -> bool:
	var config: Dictionary = COOLDOWN_CONFIG.get(group, {"delay": 1.0, "max_concurrent": 1})
	var active: int = _cooldown_active.get(group, 0)

	if active >= config["max_concurrent"]:
		# Queue the action instead of rejecting
		_queue_cooldown(btn, group, on_complete)
		return true  # Queued, not rejected

	# Start immediately
	_cooldown_active[group] = active + 1
	btn.disabled = true
	var delay: float = config["delay"]

	# Create circular progress overlay on the button
	var progress := _CooldownCircle.new()
	progress.duration = delay
	progress.on_complete = func():
		_cooldown_active[group] = maxi(0, _cooldown_active.get(group, 1) - 1)
		if is_instance_valid(btn):
			btn.disabled = false
			btn.modulate.a = 1.0
		if on_complete.is_valid():
			on_complete.call()
		# Process next queued action for this group
		_process_queue(group)
	btn.add_child(progress)
	btn.modulate.a = 0.7
	# Hide button text during cooldown — circle is the visual
	var original_text: String = btn.text
	btn.text = ""
	progress.on_text_restore = func():
		if is_instance_valid(btn):
			btn.text = original_text
	return true


## Queue a cooldown action when the group is at max concurrent.
## Shows a static 0% circle with queue position number. Click again to cancel.
func _queue_cooldown(btn: Button, group: String, on_complete: Callable) -> void:
	if group not in _cooldown_queue:
		_cooldown_queue[group] = []

	var queue: Array = _cooldown_queue[group]
	var queue_pos: int = queue.size() + 1  # 1-based position for display

	# Create a static (non-progressing) circle overlay showing queue position
	var circle := _CooldownCircle.new()
	circle.duration = 99999.0  # Won't progress — effectively frozen
	circle.queued = true
	circle.queue_position = queue_pos + _cooldown_active.get(group, 0)
	btn.add_child(circle)
	btn.modulate.a = 0.5

	var original_text: String = btn.text
	btn.text = ""

	var entry: Dictionary = {
		"btn": btn,
		"group": group,
		"on_complete": on_complete,
		"circle": circle,
		"original_text": original_text,
	}
	queue.append(entry)

	# Allow clicking again to cancel while queued
	circle.on_cancel = func():
		_cancel_queued(group, entry)

	# Connect button press to cancel (only while queued)
	var cancel_callable := func():
		if is_instance_valid(circle) and circle.queued:
			_cancel_queued(group, entry)
	btn.pressed.connect(cancel_callable, CONNECT_ONE_SHOT)


## Cancel a queued cooldown action — removes overlay and restores button.
func _cancel_queued(group: String, entry: Dictionary) -> void:
	if group in _cooldown_queue:
		_cooldown_queue[group].erase(entry)
		# Update queue positions for remaining entries
		_update_queue_positions(group)

	var btn: Button = entry.get("btn")
	var circle: Control = entry.get("circle")
	var original_text: String = entry.get("original_text", "")

	if is_instance_valid(circle):
		circle.queue_free()
	if is_instance_valid(btn):
		btn.disabled = false
		btn.modulate.a = 1.0
		btn.text = original_text


## Process the next queued action when a cooldown slot opens.
func _process_queue(group: String) -> void:
	if group not in _cooldown_queue:
		return
	var queue: Array = _cooldown_queue[group]
	if queue.is_empty():
		return

	var config: Dictionary = COOLDOWN_CONFIG.get(group, {"delay": 1.0, "max_concurrent": 1})
	var active: int = _cooldown_active.get(group, 0)
	if active >= config["max_concurrent"]:
		return  # Still full

	# Pop next entry and start it
	var entry: Dictionary = queue.pop_front()
	_update_queue_positions(group)

	var btn: Button = entry.get("btn")
	var old_circle: Control = entry.get("circle")
	var on_complete: Callable = entry.get("on_complete", Callable())
	var original_text: String = entry.get("original_text", "")

	# Remove the static queued circle
	if is_instance_valid(old_circle):
		old_circle.queue_free()

	if not is_instance_valid(btn):
		return

	# Start the real cooldown
	_cooldown_active[group] = active + 1
	btn.disabled = true
	var delay: float = config["delay"]

	var progress := _CooldownCircle.new()
	progress.duration = delay
	progress.on_complete = func():
		_cooldown_active[group] = maxi(0, _cooldown_active.get(group, 1) - 1)
		if is_instance_valid(btn):
			btn.disabled = false
			btn.modulate.a = 1.0
			btn.text = original_text
		if on_complete.is_valid():
			on_complete.call()
		_process_queue(group)
	btn.add_child(progress)
	btn.modulate.a = 0.7
	btn.text = ""


## Update displayed queue position numbers after a cancel or dequeue.
func _update_queue_positions(group: String) -> void:
	if group not in _cooldown_queue:
		return
	var queue: Array = _cooldown_queue[group]
	var active: int = _cooldown_active.get(group, 0)
	for i in queue.size():
		var entry: Dictionary = queue[i]
		var circle: Control = entry.get("circle")
		if is_instance_valid(circle) and circle is _CooldownCircle:
			circle.queue_position = i + 1 + active
			circle.queue_redraw()


## Flash a button red briefly when rejected (max concurrent reached).
## Always resets to white — prevents stacking from rapid clicks.
func _flash_button_rejected(btn: Button) -> void:
	if not is_instance_valid(btn):
		return
	btn.modulate = Color(1.0, 0.3, 0.3, 1.0)
	var flash_timer := get_tree().create_timer(0.3)
	flash_timer.timeout.connect(func():
		if is_instance_valid(btn):
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
	)


## Inner class: circular progress overlay drawn on top of a button.
## Supports queue mode: when `queued` is true, progress stays at 0% and shows position number.
class _CooldownCircle extends Control:
	var duration: float = 1.0
	var elapsed: float = 0.0
	var on_complete: Callable = Callable()
	var on_text_restore: Callable = Callable()
	var on_cancel: Callable = Callable()
	var queued: bool = false
	var queue_position: int = 0
	var _ring_color: Color = Color(0.298, 0.604, 1.0, 0.8)
	var _bg_color: Color = Color(0.0, 0.0, 0.0, 0.3)
	var _done: bool = false

	func _ready() -> void:
		# Cover the entire button
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		z_index = 10

	func _process(delta: float) -> void:
		if _done:
			return
		if queued:
			return  # Don't progress while queued — stay at 0%
		elapsed += delta
		queue_redraw()
		if elapsed >= duration:
			_done = true
			if on_text_restore.is_valid():
				on_text_restore.call()
			if on_complete.is_valid():
				on_complete.call()
			queue_free()

	func _draw() -> void:
		var center := size / 2.0
		var radius := minf(size.x, size.y) * 0.3
		var progress := 0.0 if queued else clampf(elapsed / duration, 0.0, 1.0)

		# Background dim
		draw_rect(Rect2(Vector2.ZERO, size), _bg_color)

		# Background circle (track)
		draw_arc(center, radius, 0, TAU, 32, Color(0.3, 0.3, 0.4, 0.4), 3.0)

		# Progress arc (only when not queued)
		if progress > 0.0:
			var start_angle := -PI / 2.0  # 12 o'clock
			var end_angle := start_angle + TAU * progress
			draw_arc(center, radius, start_angle, end_angle, 32, _ring_color, 4.0)

		if queued:
			# Show queue position number at top-left of circle
			var pos_text := str(queue_position)
			var font := ThemeDB.fallback_font
			draw_string(font, Vector2(6, 16), pos_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1.0, 0.85, 0.2, 0.9))
			# Show 0% in center
			draw_string(font, center + Vector2(-10, 5), "0%", HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color(0.7, 0.7, 0.7, 0.6))
		else:
			# Center percentage text
			var pct := int(progress * 100.0)
			draw_string(ThemeDB.fallback_font, center + Vector2(-10, 5), "%d%%" % pct, HORIZONTAL_ALIGNMENT_CENTER, -1, 12, Color.WHITE)


## Check if a cooldown group can accept another action.
func _can_start_cooldown(group: String) -> bool:
	var config: Dictionary = COOLDOWN_CONFIG.get(group, {"delay": 1.0, "max_concurrent": 1})
	return _cooldown_active.get(group, 0) < config["max_concurrent"]


func _disconnect_autoload_signals_piu() -> void:
	var tm := _get_theme_medical()
	if tm and tm.has_signal("theme_changed") and tm.theme_changed.is_connected(_on_theme_changed):
		tm.theme_changed.disconnect(_on_theme_changed)
	if _dialogue_client:
		if _dialogue_client.has_signal("dialogue_response_received") and _dialogue_client.dialogue_response_received.is_connected(_on_ai_response):
			_dialogue_client.dialogue_response_received.disconnect(_on_ai_response)
		if _dialogue_client.has_signal("dialogue_failed") and _dialogue_client.dialogue_failed.is_connected(_on_ai_failed):
			_dialogue_client.dialogue_failed.disconnect(_on_ai_failed)


func _get_theme_medical() -> Node:
	return get_node_or_null("/root/ThemeMedical")


func _on_theme_changed(_mode: String) -> void:
	_apply_theme()


## Responsive column calculator — returns optimal column count for available width.
func _get_responsive_columns(container_width: float, item_min_width: float, max_cols: int) -> int:
	var cols := int(container_width / item_min_width)
	return clampi(cols, 2, max_cols)


## Register a GridContainer for responsive column recalculation.
func _register_responsive_grid(grid: GridContainer, min_width: float, max_cols: int, resize_source: Control) -> void:
	_responsive_grids.append({"grid": grid, "min_width": min_width, "max_cols": max_cols, "source": resize_source})
	if not resize_source.resized.is_connected(_on_responsive_resize):
		resize_source.resized.connect(_on_responsive_resize)


## Recalculate all registered responsive grids on resize.
func _on_responsive_resize() -> void:
	for entry in _responsive_grids:
		var grid: GridContainer = entry["grid"]
		var source: Control = entry["source"]
		if is_instance_valid(grid) and is_instance_valid(source):
			grid.columns = _get_responsive_columns(source.size.x, entry["min_width"], entry["max_cols"])


func _find_systems() -> void:
	await get_tree().process_frame
	_dialogue_client = get_node_or_null("/root/OllamaDialogueClient")
	if _dialogue_client:
		if not _dialogue_client.dialogue_response_received.is_connected(_on_ai_response):
			_dialogue_client.dialogue_response_received.connect(_on_ai_response)
		if not _dialogue_client.dialogue_failed.is_connected(_on_ai_failed):
			_dialogue_client.dialogue_failed.connect(_on_ai_failed)
	_load_drugs_json()
	_load_bag_json()


func _process(_delta: float) -> void:
	if not visible or not _player or not _patient:
		return
	if not is_instance_valid(_patient):
		close_ui()
		return
	var dist: float = _player.global_position.distance_to(_patient.global_position)
	if dist > CLOSE_DISTANCE:
		close_ui()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	# Consume the interact action (E key) so InteractionManager doesn't re-trigger.
	# Pressing E while open closes the UI (toggle behavior).
	if event.is_action_pressed("interact"):
		close_ui()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_ESCAPE:
			close_ui()
			get_viewport().set_input_as_handled()
		elif not _chat_input or not _chat_input.has_focus():
			match event.physical_keycode:
				KEY_1:
					_switch_tab(Tab.PATIENT)
					get_viewport().set_input_as_handled()
				KEY_2:
					_switch_tab(Tab.EXAM)
					get_viewport().set_input_as_handled()
				KEY_3:
					_switch_tab(Tab.STABILIZE)
					get_viewport().set_input_as_handled()
				KEY_4:
					_switch_tab(Tab.DIFFERENTIAL)
					get_viewport().set_input_as_handled()


## Open the interaction UI for a patient.
func open_ui(patient: Node, player: Node) -> void:
	# Block if scenario has ended
	var sm: Node = get_node_or_null("/root/ScenarioManager")
	if sm and "_scenario_running" in sm and not sm._scenario_running:
		return
	_patient = patient
	_player = player
	_current_tab = Tab.PATIENT

	# Restore diagnosis state from patient metadata if already submitted.
	# Prevents re-interaction from wiping a completed diagnosis.
	if patient.has_meta("player_diagnoses") and not (patient.get_meta("player_diagnoses") as Array).is_empty():
		_selected_diagnoses = (patient.get_meta("player_diagnoses") as Array).duplicate()
		_diagnosis_submitted = true
	else:
		_selected_diagnoses.clear()
		_diagnosis_submitted = false

	# Find managers on player
	_assessment_manager = player.get_node_or_null("AssessmentManager")
	_history_manager = player.get_node_or_null("HistoryTakingManager")

	# ARC-14/15/16/17/18: find additional managers
	_ecg_rhythm_manager = get_node_or_null("/root/ECGRhythmManager")
	_gcs_manager = get_node_or_null("/root/GCSAssessmentManager")
	_secondary_survey_manager = get_node_or_null("/root/SecondarySurveyManager")
	_drug_admin_manager = player.get_node_or_null("DrugAdministrationManager")
	_bag_tier_manager = player.get_node_or_null("MedicalBagTierManager")

	# Rebuild _applied_equipment from patient metadata (persists across UI open/close)
	_applied_equipment.clear()
	if patient.has_meta("deployed_equipment"):
		var deployed: Array = patient.get_meta("deployed_equipment")
		for bag_key in deployed:
			var equip_key: String = BAG_TO_EQUIP_KEY.get(str(bag_key), str(bag_key).to_lower())
			if equip_key not in _applied_equipment:
				_applied_equipment.append(equip_key)

	# Make visible BEFORE begin_assessment() so HUDController's guard clause
	# sees this panel is active and does not open the legacy ActionMenu.
	visible = true

	# Notify DeteriorationSystem that this patient is now player-focused
	var deterioration: Node = patient.get_node_or_null("DeteriorationSystem")
	if deterioration and deterioration.has_method("set_player_focused"):
		deterioration.set_player_focused(true)

	# Start history session
	if _history_manager and not _history_manager.is_active:
		_history_manager.begin_history(patient)

	# Start assessment session
	if _assessment_manager:
		_assessment_manager.begin_assessment(patient)

	# Set up Ollama context
	_setup_ollama_context()

	# Populate all tabs
	_populate_patient_tab()
	_populate_exam_tab()
	_populate_stabilize_tab()
	_populate_differential_tab()

	# ARC-13/14/15/16/17/18: populate new sections
	_populate_vitals_section()
	_populate_ecg_section()
	_populate_gcs_section()
	_populate_secondary_section()
	_populate_drug_section()
	_populate_bag_section()

	_switch_tab(Tab.PATIENT)

	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if _ai_status_label:
		var tm := _get_theme_medical()
		if _dialogue_client and _dialogue_client.ollama_available:
			_ai_status_label.text = tr("PATIENT_AI_ACTIVE")
			_ai_status_label.add_theme_color_override("font_color", tm.c("accent_green") if tm else Color(0.3, 0.9, 0.4))
		else:
			_ai_status_label.text = tr("PATIENT_SCRIPTED_RESPONSES")
			_ai_status_label.add_theme_color_override("font_color", tm.c("accent_yellow") if tm else Color(0.9, 0.7, 0.3))

	# ARC-17: connect drug administered signal if available
	if _drug_admin_manager and _drug_admin_manager.has_signal("drug_administered"):
		if not _drug_admin_manager.drug_administered.is_connected(_on_drug_administered_signal):
			_drug_admin_manager.drug_administered.connect(_on_drug_administered_signal)


## Close the UI.
func close_ui() -> void:
	# Notify DeteriorationSystem that this patient is no longer player-focused
	if _patient:
		var deterioration: Node = _patient.get_node_or_null("DeteriorationSystem")
		if deterioration and deterioration.has_method("set_player_focused"):
			deterioration.set_player_focused(false)
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if _history_manager and _history_manager.is_active:
		_history_manager.end_history()
	if _assessment_manager and _assessment_manager.in_assessment:
		_assessment_manager.end_assessment()
	_patient = null
	_player = null
	interaction_closed.emit()


# ==============================================================================
# UI BUILD — main structure
# ==============================================================================

func _build_ui() -> void:
	var tm := _get_theme_medical()

	# Dim overlay background
	var bg := ColorRect.new()
	bg.color = tm.c("overlay") if tm else Color(0, 0, 0, 0.7)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	bg.name = "OverlayBg"
	add_child(bg)

	# Outer margin container — tighter margins for more screen usage
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	add_child(margin)

	# Main horizontal container: [content panel] [tab strip]
	var main_hbox := HBoxContainer.new()
	main_hbox.add_theme_constant_override("separation", 8)
	margin.add_child(main_hbox)

	# Left content panel
	_left_panel = PanelContainer.new()
	_left_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_left_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	if tm:
		tm.style_panel(_left_panel)
	main_hbox.add_child(_left_panel)

	_content_container = VBoxContainer.new()
	_content_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_left_panel.add_child(_content_container)

	# Build each tab's content
	_tab_contents[Tab.PATIENT] = _build_patient_tab()
	_tab_contents[Tab.EXAM] = _build_exam_tab()
	_tab_contents[Tab.STABILIZE] = _build_stabilize_tab()
	_tab_contents[Tab.DIFFERENTIAL] = _build_differential_tab()

	for tab_content in _tab_contents.values():
		_content_container.add_child(tab_content)
		tab_content.visible = false

	# Right tab strip
	var tab_strip := VBoxContainer.new()
	tab_strip.custom_minimum_size = Vector2(120, 0)
	tab_strip.add_theme_constant_override("separation", 4)
	main_hbox.add_child(tab_strip)

	var tab_labels := {
		Tab.PATIENT:      "[1]\n" + tr("TAB_PATIENT"),
		Tab.EXAM:         "[2]\n" + tr("TAB_EXAM"),
		Tab.STABILIZE:    "[3]\n" + tr("TAB_STABILIZE"),
		Tab.DIFFERENTIAL: "[4]\n" + tr("TAB_DIFFERENTIAL"),
	}

	for tab_id in [Tab.PATIENT, Tab.EXAM, Tab.STABILIZE, Tab.DIFFERENTIAL]:
		var btn := Button.new()
		btn.text = tab_labels[tab_id]
		btn.custom_minimum_size = Vector2(110, 70)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_switch_tab.bind(tab_id))
		if tm:
			tm.style_button(btn)
			btn.add_theme_stylebox_override("normal", tm.make_tab_inactive())
		tab_strip.add_child(btn)
		_tab_buttons[tab_id] = btn

	# Spacer + close button at bottom of strip
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_strip.add_child(spacer)

	_close_btn = Button.new()
	_close_btn.text = tr("PATIENT_CLOSE_BUTTON")
	_close_btn.custom_minimum_size = Vector2(110, 50)
	_close_btn.focus_mode = Control.FOCUS_NONE
	_close_btn.pressed.connect(close_ui)
	if tm:
		tm.style_button(_close_btn)
		_close_btn.add_theme_color_override("font_color", tm.c("accent_red"))
		_close_btn.add_theme_color_override("font_hover_color", tm.c("accent_red"))
	tab_strip.add_child(_close_btn)


func _switch_tab(tab: Tab) -> void:
	_current_tab = tab
	var tm := _get_theme_medical()
	for tab_id in _tab_contents:
		_tab_contents[tab_id].visible = (tab_id == tab)
	for tab_id in _tab_buttons:
		var btn: Button = _tab_buttons[tab_id]
		btn.disabled = (tab_id == tab)
		if tm:
			if tab_id == tab:
				btn.add_theme_stylebox_override("normal", tm.make_tab_active())
				btn.add_theme_stylebox_override("disabled", tm.make_tab_active())
				btn.add_theme_color_override("font_color", tm.c("accent_blue"))
				btn.add_theme_color_override("font_disabled_color", tm.c("accent_blue"))
			else:
				btn.add_theme_stylebox_override("normal", tm.make_tab_inactive())
				btn.add_theme_stylebox_override("disabled", tm.make_tab_inactive())
				btn.add_theme_color_override("font_color", tm.c("text_secondary"))
				btn.add_theme_color_override("font_disabled_color", tm.c("text_secondary"))


func _switch_exam_sub(sub_name: String) -> void:
	_current_exam_sub = sub_name
	var tm: Node = _get_theme_medical()
	for key in _exam_sub_tabs:
		_exam_sub_tabs[key].visible = (key == sub_name)
		if tm:
			if key == sub_name:
				_exam_sub_tab_btns[key].add_theme_stylebox_override("normal", tm.make_tab_active())
			else:
				_exam_sub_tab_btns[key].add_theme_stylebox_override("normal", tm.make_tab_inactive())


func _switch_stab_sub(sub_name: String) -> void:
	_current_stab_sub = sub_name
	var tm: Node = _get_theme_medical()
	for key in _stab_sub_tabs:
		_stab_sub_tabs[key].visible = (key == sub_name)
		if tm:
			if key == sub_name:
				_stab_sub_tab_btns[key].add_theme_stylebox_override("normal", tm.make_tab_active())
			else:
				_stab_sub_tab_btns[key].add_theme_stylebox_override("normal", tm.make_tab_inactive())


# ==============================================================================
# TAB BUILD — Patient
# ==============================================================================

func _build_patient_tab() -> Control:
	var tm := _get_theme_medical()

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)

	# ── Patient Info Card (compact 2-line card at top) ──
	_patient_info_card = PanelContainer.new()
	_patient_info_card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if tm:
		tm.style_panel(_patient_info_card)
	root.add_child(_patient_info_card)

	var info_vbox := VBoxContainer.new()
	info_vbox.add_theme_constant_override("separation", 4)
	_patient_info_card.add_child(info_vbox)

	# Top row: Name + State badge
	var info_top := HBoxContainer.new()
	info_vbox.add_child(info_top)

	_patient_name_label = Label.new()
	_patient_name_label.text = "Patient"
	_patient_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if tm:
		tm.style_label(_patient_name_label, "subtitle", "text_primary")
	else:
		_patient_name_label.add_theme_font_size_override("font_size", 18)
	info_top.add_child(_patient_name_label)

	_patient_state_label = Label.new()
	_patient_state_label.text = ""
	if tm:
		tm.style_label(_patient_state_label, "body", "accent_green")
	info_top.add_child(_patient_state_label)

	# Detail row: Pain | Panic | Clarity
	_patient_detail_label = Label.new()
	_patient_detail_label.text = ""
	if tm:
		tm.style_label(_patient_detail_label, "body_small", "text_secondary")
	else:
		_patient_detail_label.add_theme_font_size_override("font_size", 13)
	info_vbox.add_child(_patient_detail_label)

	# Keep RichTextLabel for backward compat (populate functions write to it)
	_patient_info_label = RichTextLabel.new()
	_patient_info_label.bbcode_enabled = true
	_patient_info_label.visible = false  # Hidden — using card labels instead
	root.add_child(_patient_info_label)

	# ── SAMPLE History (horizontal pill buttons) ──
	var sample_flow := HFlowContainer.new()
	sample_flow.add_theme_constant_override("h_separation", 6)
	sample_flow.add_theme_constant_override("v_separation", 6)
	root.add_child(sample_flow)

	var sample_categories := [
		["S", "signs_symptoms"],
		["A", "allergies"],
		["M", "medications"],
		["P", "past_history"],
		["L", "last_oral_intake"],
		["E", "events"],
	]

	for cat in sample_categories:
		var btn := Button.new()
		btn.text = cat[0]
		btn.custom_minimum_size = Vector2(48, 32)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_sample_category_pressed.bind(cat[1]))
		if tm:
			tm.style_button(btn, "small")
		else:
			btn.add_theme_font_size_override("font_size", 13)
		sample_flow.add_child(btn)

	## OPQRST button (accent yellow)
	_opqrst_btn = Button.new()
	_opqrst_btn.text = "OPQRST"
	_opqrst_btn.custom_minimum_size = Vector2(72, 32)
	_opqrst_btn.focus_mode = Control.FOCUS_NONE
	_opqrst_btn.pressed.connect(_on_sample_category_pressed.bind("opqrst"))
	if tm:
		tm.style_button(_opqrst_btn, "small")
		_opqrst_btn.add_theme_color_override("font_color", tm.c("accent_yellow"))
	else:
		_opqrst_btn.add_theme_font_size_override("font_size", 13)
		_opqrst_btn.add_theme_color_override("font_color", Color(1.0, 0.75, 0.2))
	sample_flow.add_child(_opqrst_btn)

	# ── Chat Area (primary focus — takes remaining space) ──
	_chat_scroll = ScrollContainer.new()
	_chat_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_chat_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(_chat_scroll)

	_chat_container = VBoxContainer.new()
	_chat_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chat_container.add_theme_constant_override("separation", 8)
	_chat_scroll.add_child(_chat_container)

	# ── Chat Input Row ──
	var input_row := HBoxContainer.new()
	input_row.add_theme_constant_override("separation", 8)
	root.add_child(input_row)

	_chat_input = LineEdit.new()
	_chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_chat_input.placeholder_text = tr("PATIENT_CHAT_PLACEHOLDER")
	_chat_input.text_submitted.connect(_on_chat_submitted)
	if tm:
		tm.style_input(_chat_input)
	input_row.add_child(_chat_input)

	_talk_button = Button.new()
	_talk_button.text = "Talk"
	_talk_button.focus_mode = Control.FOCUS_NONE
	_talk_button.pressed.connect(_on_talk_button_pressed)
	if tm:
		tm.style_button(_talk_button)
	input_row.add_child(_talk_button)

	# ── AI Status (subtle, bottom-right) ──
	_ai_status_label = Label.new()
	_ai_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	if tm:
		tm.style_label(_ai_status_label, "caption", "text_muted")
	else:
		_ai_status_label.add_theme_font_size_override("font_size", 11)
	root.add_child(_ai_status_label)

	return root


# ==============================================================================
# TAB BUILD — Exam
# ==============================================================================

func _build_exam_tab() -> Control:
	var tm := _get_theme_medical()

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)

	# ── Sub-tab pill strip ──
	var pill_strip := HBoxContainer.new()
	pill_strip.add_theme_constant_override("separation", 4)
	root.add_child(pill_strip)

	var exam_sub_defs: Array = [
		["primary", tr("SUB_PRIMARY")],
		["vitals", tr("SUB_VITALS")],
		["gcs", tr("SUB_GCS")],
		["head_to_toe", tr("SUB_HEAD_TO_TOE")],
	]

	for sub_def in exam_sub_defs:
		var sub_key: String = sub_def[0]
		var sub_label: String = sub_def[1]
		var pill_btn := Button.new()
		pill_btn.text = sub_label
		pill_btn.custom_minimum_size = Vector2(80, 32)
		pill_btn.focus_mode = Control.FOCUS_NONE
		pill_btn.pressed.connect(_switch_exam_sub.bind(sub_key))
		if tm:
			tm.style_button(pill_btn, "small")
			if sub_key == _current_exam_sub:
				pill_btn.add_theme_stylebox_override("normal", tm.make_tab_active())
			else:
				pill_btn.add_theme_stylebox_override("normal", tm.make_tab_inactive())
		pill_strip.add_child(pill_btn)
		_exam_sub_tab_btns[sub_key] = pill_btn

	# ── Sub-tab content panels (only one visible at a time) ──
	var sub_container := Control.new()
	sub_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(sub_container)

	# ════════════════════════════════════════════════════════════
	# SUB-TAB: "primary" — DRSABCDE
	# ════════════════════════════════════════════════════════════
	var primary_scroll := ScrollContainer.new()
	primary_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	primary_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	primary_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sub_container.add_child(primary_scroll)
	_exam_sub_tabs["primary"] = primary_scroll

	var primary_vbox := VBoxContainer.new()
	primary_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	primary_vbox.add_theme_constant_override("separation", 8)
	primary_scroll.add_child(primary_vbox)

	var title_row := HBoxContainer.new()
	primary_vbox.add_child(title_row)
	var title := Label.new()
	title.text = tr("EXAM_PRIMARY_SURVEY")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if tm:
		tm.style_label(title, "subtitle", "text_primary")
	title_row.add_child(title)
	_exam_counter_label = Label.new()
	_exam_counter_label.text = "0/8"
	if tm:
		tm.style_label(_exam_counter_label, "body", "accent_blue")
	title_row.add_child(_exam_counter_label)

	var drs_steps := [
		[tr("EXAM_DANGER"), "check_danger"],
		[tr("EXAM_RESPONSE"), "check_response"],
		[tr("EXAM_SEND_HELP"), "send_help"],
		[tr("EXAM_AIRWAY"), "check_airway"],
		[tr("EXAM_BREATHING"), "check_breathing"],
		[tr("EXAM_CIRCULATION"), "check_circulation"],
		[tr("EXAM_DISABILITY"), "check_disability"],
		[tr("EXAM_EXPOSURE"), "check_exposure"],
	]

	var steps_grid := GridContainer.new()
	steps_grid.columns = 4
	steps_grid.add_theme_constant_override("h_separation", 6)
	steps_grid.add_theme_constant_override("v_separation", 4)
	primary_vbox.add_child(steps_grid)

	for step in drs_steps:
		var step_panel := PanelContainer.new()
		step_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if tm:
			tm.style_panel(step_panel)
		steps_grid.add_child(step_panel)

		var step_vbox := VBoxContainer.new()
		step_vbox.add_theme_constant_override("separation", 4)
		step_panel.add_child(step_vbox)

		var btn := Button.new()
		btn.text = step[0]
		btn.custom_minimum_size = Vector2(0, 50)
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_exam_action_pressed.bind(step[1]))
		if tm:
			tm.style_button(btn)
		step_vbox.add_child(btn)
		_exam_buttons[step[1]] = btn

		var result_lbl := Label.new()
		result_lbl.text = ""
		result_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if tm:
			tm.style_label(result_lbl, "body_small", "text_secondary")
		else:
			result_lbl.add_theme_font_size_override("font_size", 12)
		step_vbox.add_child(result_lbl)
		_exam_results[step[1]] = result_lbl

	# ════════════════════════════════════════════════════════════
	# SUB-TAB: "vitals" — Vital Signs + ECG
	# ════════════════════════════════════════════════════════════
	var vitals_scroll := ScrollContainer.new()
	vitals_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vitals_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vitals_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vitals_scroll.visible = false
	sub_container.add_child(vitals_scroll)
	_exam_sub_tabs["vitals"] = vitals_scroll

	var vitals_vbox := VBoxContainer.new()
	vitals_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vitals_vbox.add_theme_constant_override("separation", 8)
	vitals_scroll.add_child(vitals_vbox)

	var vitals_title := Label.new()
	vitals_title.text = tr("VITAL_SIGNS_TITLE") if tr("VITAL_SIGNS_TITLE") != "VITAL_SIGNS_TITLE" else "Vital Signs Assessment"
	if tm:
		tm.style_label(vitals_title, "subtitle", "accent_blue")
	else:
		vitals_title.add_theme_font_size_override("font_size", 17)
	vitals_vbox.add_child(vitals_title)

	var vitals_grid := GridContainer.new()
	vitals_grid.columns = 4
	vitals_grid.add_theme_constant_override("h_separation", 6)
	vitals_grid.add_theme_constant_override("v_separation", 4)
	vitals_vbox.add_child(vitals_grid)

	# Enum values from AssessmentManager.AssessmentAction:
	# CHECK_HEART_RATE=5, CHECK_BLOOD_PRESSURE=6, CHECK_SPO2=7,
	# CHECK_PUPILS=8, CHECK_TEMPERATURE=9, CHECK_BLOOD_GLUCOSE=10,
	# CHECK_CAPILLARY_REFILL=11, CHECK_SKIN=12
	var vital_defs := [
		[tr("VITAL_HEART_RATE"), "check_heart_rate", 5],
		[tr("VITAL_BLOOD_PRESSURE"), "check_blood_pressure", 6],
		[tr("VITAL_SPO2"), "check_spo2", 7],
		[tr("VITAL_TEMPERATURE"), "check_temperature", 9],
		[tr("VITAL_BLOOD_GLUCOSE"), "check_blood_glucose", 10],
		[tr("VITAL_CAPILLARY_REFILL"), "check_capillary_refill", 11],
		[tr("VITAL_PUPILS"), "check_pupils", 8],
		[tr("VITAL_SKIN"), "check_skin", 12],
	]

	for vd in vital_defs:
		var v_panel := PanelContainer.new()
		v_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if tm:
			tm.style_panel(v_panel)
		vitals_grid.add_child(v_panel)

		var v_vbox := VBoxContainer.new()
		v_vbox.add_theme_constant_override("separation", 4)
		v_panel.add_child(v_vbox)

		var v_btn := Button.new()
		v_btn.text = vd[0]
		v_btn.custom_minimum_size = Vector2(0, 40)
		v_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		v_btn.focus_mode = Control.FOCUS_NONE
		v_btn.pressed.connect(_on_vital_pressed.bind(vd[1], vd[2]))
		if tm:
			tm.style_button(v_btn, "small")
		v_btn.add_theme_color_override("font_color", tm.c("text_primary") if tm else Color(0.1, 0.1, 0.2))
		v_vbox.add_child(v_btn)
		_vital_buttons[vd[1]] = v_btn

		var v_result := Label.new()
		v_result.text = ""
		v_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if tm:
			tm.style_label(v_result, "body_small", "text_secondary")
		else:
			v_result.add_theme_font_size_override("font_size", 12)
		v_vbox.add_child(v_result)
		_vital_results[vd[1]] = v_result

	# ── ECG Section (below vitals grid) ──
	var ecg_title := Label.new()
	ecg_title.text = "ECG / Cardiac Monitor"
	if tm:
		tm.style_label(ecg_title, "subtitle", "accent_green")
	vitals_vbox.add_child(ecg_title)

	_ecg_mode_label = Label.new()
	_ecg_mode_label.text = ""
	_ecg_mode_label.visible = false
	if tm:
		tm.style_label(_ecg_mode_label, "label", "text_muted")
	vitals_vbox.add_child(_ecg_mode_label)

	_ecg_panel = PanelContainer.new()
	_ecg_panel.custom_minimum_size = Vector2(0, 110)
	_ecg_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ecg_panel.visible = false
	if tm:
		tm.style_panel(_ecg_panel, "info")
	vitals_vbox.add_child(_ecg_panel)

	var ecg_inner := VBoxContainer.new()
	_ecg_panel.add_child(ecg_inner)

	_ecg_texture_rect = TextureRect.new()
	_ecg_texture_rect.custom_minimum_size = Vector2(400, 100)
	_ecg_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_ecg_texture_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ecg_inner.add_child(_ecg_texture_rect)

	_ecg_rhythm_label = Label.new()
	_ecg_rhythm_label.text = ""
	_ecg_rhythm_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if tm:
		tm.style_label(_ecg_rhythm_label, "label", "text_secondary")
	else:
		_ecg_rhythm_label.add_theme_font_size_override("font_size", 13)
	vitals_vbox.add_child(_ecg_rhythm_label)

	var ecg_identify_btn := Button.new()
	ecg_identify_btn.text = "Identify Rhythm"
	ecg_identify_btn.custom_minimum_size = Vector2(0, 36)
	ecg_identify_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ecg_identify_btn.focus_mode = Control.FOCUS_NONE
	ecg_identify_btn.pressed.connect(_on_ecg_identify_pressed)
	if tm:
		tm.style_button(ecg_identify_btn)
	vitals_vbox.add_child(ecg_identify_btn)

	# ════════════════════════════════════════════════════════════
	# SUB-TAB: "gcs" — Glasgow Coma Scale
	# ════════════════════════════════════════════════════════════
	var gcs_scroll := ScrollContainer.new()
	gcs_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gcs_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	gcs_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	gcs_scroll.visible = false
	sub_container.add_child(gcs_scroll)
	_exam_sub_tabs["gcs"] = gcs_scroll

	var gcs_vbox := VBoxContainer.new()
	gcs_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gcs_vbox.add_theme_constant_override("separation", 6)
	gcs_scroll.add_child(gcs_vbox)

	var gcs_title_hbox := HBoxContainer.new()
	gcs_vbox.add_child(gcs_title_hbox)

	var gcs_title := Label.new()
	gcs_title.text = "GCS -- Glasgow Coma Scale"
	gcs_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if tm:
		tm.style_label(gcs_title, "subtitle", "accent_yellow")
	else:
		gcs_title.add_theme_font_size_override("font_size", 17)
		gcs_title.add_theme_color_override("font_color", tm.c("accent_yellow") if tm else Color(0.9, 0.7, 0.3))
	gcs_title_hbox.add_child(gcs_title)

	_gcs_total_label = Label.new()
	_gcs_total_label.text = "GCS: --"
	if tm:
		tm.style_label(_gcs_total_label, "subtitle", "text_primary")
	else:
		_gcs_total_label.add_theme_font_size_override("font_size", 17)
	gcs_title_hbox.add_child(_gcs_total_label)

	_gcs_severity_label = Label.new()
	_gcs_severity_label.text = ""
	if tm:
		tm.style_label(_gcs_severity_label, "label", "text_secondary")
	else:
		_gcs_severity_label.add_theme_font_size_override("font_size", 13)
	gcs_vbox.add_child(_gcs_severity_label)

	# GCS sub-sections — Eye, Verbal, Motor
	var gcs_defs := [
		["Eye (E)", "eye",
			["Spontaneous (4)", "To Voice (3)", "To Pain (2)", "None (1)"],
			[4, 3, 2, 1]],
		["Verbal (V)", "verbal",
			["Oriented (5)", "Confused (4)", "Words (3)", "Sounds (2)", "None (1)"],
			[5, 4, 3, 2, 1]],
		["Motor (M)", "motor",
			["Obeys (6)", "Localises (5)", "Withdraws (4)", "Flexion (3)", "Extension (2)", "None (1)"],
			[6, 5, 4, 3, 2, 1]],
	]

	for gcs_comp in gcs_defs:
		var comp_name: String = gcs_comp[0]
		var comp_key: String = gcs_comp[1]
		var comp_labels: Array = gcs_comp[2]
		var comp_values: Array = gcs_comp[3]

		var comp_title := Label.new()
		comp_title.text = comp_name
		if tm:
			tm.style_label(comp_title, "body_small", "text_secondary")
		else:
			comp_title.add_theme_font_size_override("font_size", 14)
		gcs_vbox.add_child(comp_title)

		var comp_hbox := HBoxContainer.new()
		comp_hbox.add_theme_constant_override("separation", 4)
		gcs_vbox.add_child(comp_hbox)

		for i in range(comp_labels.size()):
			var gcs_btn := Button.new()
			gcs_btn.text = comp_labels[i]
			gcs_btn.custom_minimum_size = Vector2(0, 30)
			gcs_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			gcs_btn.focus_mode = Control.FOCUS_NONE
			gcs_btn.pressed.connect(_on_gcs_value_selected.bind(comp_key, comp_values[i]))
			if tm:
				tm.style_button(gcs_btn, "small")
			gcs_btn.add_theme_color_override("font_color", tm.c("text_primary") if tm else Color(0.1, 0.1, 0.2))
			comp_hbox.add_child(gcs_btn)
			_gcs_component_btns[comp_key + "_" + str(comp_values[i])] = gcs_btn

	var gcs_read_btn := Button.new()
	gcs_read_btn.text = "Read from Patient"
	gcs_read_btn.custom_minimum_size = Vector2(160, 32)
	gcs_read_btn.focus_mode = Control.FOCUS_NONE
	gcs_read_btn.pressed.connect(_on_gcs_read_patient)
	if tm:
		tm.style_button(gcs_read_btn, "small")
	gcs_vbox.add_child(gcs_read_btn)

	# ════════════════════════════════════════════════════════════
	# SUB-TAB: "head_to_toe" — Secondary Survey
	# ════════════════════════════════════════════════════════════
	var ss_scroll := ScrollContainer.new()
	ss_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ss_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ss_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ss_scroll.visible = false
	sub_container.add_child(ss_scroll)
	_exam_sub_tabs["head_to_toe"] = ss_scroll

	var ss_vbox := VBoxContainer.new()
	ss_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ss_vbox.add_theme_constant_override("separation", 6)
	ss_scroll.add_child(ss_vbox)

	var ss_title_hbox := HBoxContainer.new()
	ss_vbox.add_child(ss_title_hbox)

	var ss_title := Label.new()
	ss_title.text = tr("SECONDARY_SURVEY_TITLE") if tr("SECONDARY_SURVEY_TITLE") != "SECONDARY_SURVEY_TITLE" else "Secondary Survey -- Head-to-Toe"
	ss_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if tm:
		tm.style_label(ss_title, "subtitle", "accent_purple")
	else:
		ss_title.add_theme_font_size_override("font_size", 17)
		ss_title.add_theme_color_override("font_color", tm.c("accent_purple") if tm else Color(0.7, 0.5, 1.0))
	ss_title_hbox.add_child(ss_title)

	_secondary_counter_label = Label.new()
	_secondary_counter_label.text = "0/7"
	if tm:
		tm.style_label(_secondary_counter_label, "body_small", "accent_blue")
	else:
		_secondary_counter_label.add_theme_font_size_override("font_size", 14)
	ss_title_hbox.add_child(_secondary_counter_label)

	var ss_grid := GridContainer.new()
	ss_grid.columns = 2
	ss_grid.add_theme_constant_override("h_separation", 6)
	ss_grid.add_theme_constant_override("v_separation", 4)
	ss_vbox.add_child(ss_grid)

	var ss_regions := ["head", "neck", "chest", "abdomen", "pelvis", "back", "extremities"]
	var ss_tr_keys := {
		"head": "SECONDARY_HEAD", "neck": "SECONDARY_NECK", "chest": "SECONDARY_CHEST",
		"abdomen": "SECONDARY_ABDOMEN", "pelvis": "SECONDARY_PELVIS",
		"back": "SECONDARY_BACK", "extremities": "SECONDARY_EXTREMITIES",
	}

	for region in ss_regions:
		var r_panel := PanelContainer.new()
		r_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if tm:
			tm.style_panel(r_panel)
		ss_grid.add_child(r_panel)

		var r_vbox := VBoxContainer.new()
		r_vbox.add_theme_constant_override("separation", 4)
		r_panel.add_child(r_vbox)

		var r_btn := Button.new()
		r_btn.text = tr(ss_tr_keys.get(region, region.capitalize()))
		r_btn.custom_minimum_size = Vector2(0, 40)
		r_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		r_btn.focus_mode = Control.FOCUS_NONE
		r_btn.pressed.connect(_on_secondary_region_pressed.bind(region))
		if tm:
			tm.style_button(r_btn)
		r_btn.add_theme_color_override("font_color", tm.c("text_primary") if tm else Color(0.1, 0.1, 0.2))
		r_vbox.add_child(r_btn)
		_secondary_buttons[region] = r_btn

		var r_result := Label.new()
		r_result.text = ""
		r_result.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if tm:
			tm.style_label(r_result, "body_small", "text_secondary")
		else:
			r_result.add_theme_font_size_override("font_size", 12)
		r_vbox.add_child(r_result)
		_secondary_results[region] = r_result

	return root


# ==============================================================================
# TAB BUILD — Stabilize
# ==============================================================================

func _build_stabilize_tab() -> Control:
	var tm := _get_theme_medical()

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)

	# ── Sub-tab pill strip ──
	var pill_strip := HBoxContainer.new()
	pill_strip.add_theme_constant_override("separation", 4)
	root.add_child(pill_strip)

	var stab_sub_defs: Array = [
		["equipment", tr("SUB_EQUIPMENT")],
		["drug_admin", tr("SUB_DRUG_ADMIN")],
		["triage", tr("SUB_TRIAGE")],
	]

	for sub_def in stab_sub_defs:
		var sub_key: String = sub_def[0]
		var sub_label: String = sub_def[1]
		var pill_btn := Button.new()
		pill_btn.text = sub_label
		pill_btn.custom_minimum_size = Vector2(80, 32)
		pill_btn.focus_mode = Control.FOCUS_NONE
		pill_btn.pressed.connect(_switch_stab_sub.bind(sub_key))
		if tm:
			tm.style_button(pill_btn, "small")
			if sub_key == _current_stab_sub:
				pill_btn.add_theme_stylebox_override("normal", tm.make_tab_active())
			else:
				pill_btn.add_theme_stylebox_override("normal", tm.make_tab_inactive())
		pill_strip.add_child(pill_btn)
		_stab_sub_tab_btns[sub_key] = pill_btn

	# ── Sub-tab content panels (only one visible at a time) ──
	var sub_container := Control.new()
	sub_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(sub_container)

	# ════════════════════════════════════════════════════════════
	# SUB-TAB: "equipment" — CPR + Diagnostic + Treatment
	# ════════════════════════════════════════════════════════════
	var equip_scroll := ScrollContainer.new()
	equip_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equip_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	equip_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sub_container.add_child(equip_scroll)
	_stab_sub_tabs["equipment"] = equip_scroll

	var equip_vbox := VBoxContainer.new()
	equip_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equip_vbox.add_theme_constant_override("separation", 12)
	equip_scroll.add_child(equip_vbox)

	# CPR action — visible only during cardiac arrest, prominent red button
	_cpr_button = Button.new()
	_cpr_button.text = "Start CPR (Chest Compressions)"
	_cpr_button.custom_minimum_size = Vector2(0, 56)
	_cpr_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_cpr_button.focus_mode = Control.FOCUS_NONE
	_cpr_button.pressed.connect(_on_cpr_pressed)
	_cpr_button.visible = false  # Shown only when patient is in cardiac arrest
	if tm:
		tm.style_button(_cpr_button, "large")
		var cpr_normal: StyleBoxFlat = tm.make_btn_normal()
		cpr_normal.bg_color = tm.c("accent_red")
		_cpr_button.add_theme_stylebox_override("normal", cpr_normal)
		var cpr_hover: StyleBoxFlat = tm.make_btn_hover()
		cpr_hover.bg_color = tm.c("accent_red").lightened(0.15)
		_cpr_button.add_theme_stylebox_override("hover", cpr_hover)
		_cpr_button.add_theme_color_override("font_color", Color.WHITE)
		_cpr_button.add_theme_color_override("font_hover_color", Color.WHITE)
	else:
		_cpr_button.add_theme_font_size_override("font_size", 18)
		_cpr_button.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	equip_vbox.add_child(_cpr_button)

	_cpr_status_label = Label.new()
	_cpr_status_label.text = ""
	_cpr_status_label.visible = false
	if tm:
		tm.style_label(_cpr_status_label, "body_small", "text_secondary")
	else:
		_cpr_status_label.add_theme_font_size_override("font_size", 14)
	equip_vbox.add_child(_cpr_status_label)

	## ARC-18: Medical Bag Tier Indicator
	var tier_hbox := HBoxContainer.new()
	tier_hbox.add_theme_constant_override("separation", 8)
	equip_vbox.add_child(tier_hbox)

	var tier_label_title := Label.new()
	tier_label_title.text = "Medical Bag Tier: "
	if tm:
		tm.style_label(tier_label_title, "body", "text_secondary")
	else:
		tier_label_title.add_theme_font_size_override("font_size", 15)
	tier_hbox.add_child(tier_label_title)

	_bag_tier_label = Label.new()
	_bag_tier_label.text = "BLS"
	if tm:
		tm.style_label(_bag_tier_label, "body", "accent_green")
	else:
		_bag_tier_label.add_theme_font_size_override("font_size", 15)
		_bag_tier_label.add_theme_color_override("font_color", tm.c("accent_green") if tm else Color(0.3, 0.9, 0.4))
	tier_hbox.add_child(_bag_tier_label)

	# ── Equipment Row: Diagnostic (left) | Treatment (right) ──
	var equip_row := HBoxContainer.new()
	equip_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equip_row.add_theme_constant_override("separation", 12)
	equip_vbox.add_child(equip_row)

	# Left: Diagnostic Equipment
	var diag_col := VBoxContainer.new()
	diag_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diag_col.add_theme_constant_override("separation", 6)
	equip_row.add_child(diag_col)

	var diag_title := Label.new()
	diag_title.text = "Diagnostic"
	if tm:
		tm.style_label(diag_title, "subtitle", "accent_blue")
	else:
		diag_title.add_theme_font_size_override("font_size", 17)
	diag_col.add_child(diag_title)

	var diag_grid := GridContainer.new()
	diag_grid.columns = 2
	diag_grid.add_theme_constant_override("h_separation", 6)
	diag_grid.add_theme_constant_override("v_separation", 4)
	diag_col.add_child(diag_grid)

	var diagnostic_defs := [
		[tr("EQUIP_PULSE_OXIMETER"), "pulse_oximeter"],
		[tr("EQUIP_BP_CUFF"), "bp_cuff"],
		[tr("EQUIP_PENLIGHT"), "penlight"],
		[tr("EQUIP_THERMOMETER"), "thermometer"],
		[tr("EQUIP_GLUCOMETER"), "glucometer"],
	]

	for eq in diagnostic_defs:
		var eq_panel := PanelContainer.new()
		eq_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if tm:
			tm.style_panel(eq_panel)
		diag_grid.add_child(eq_panel)
		var eq_btn := Button.new()
		eq_btn.text = eq[0]
		eq_btn.custom_minimum_size = Vector2(0, 40)
		eq_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		eq_btn.focus_mode = Control.FOCUS_NONE
		eq_btn.pressed.connect(_on_equipment_pressed.bind(eq[1]))
		if tm:
			tm.style_button(eq_btn, "small")
		eq_btn.add_theme_color_override("font_color", tm.c("text_primary") if tm else Color(0.1, 0.1, 0.2))
		eq_panel.add_child(eq_btn)
		_equipment_buttons[eq[1]] = eq_btn

	# Right: Treatment Equipment
	var treat_col := VBoxContainer.new()
	treat_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	treat_col.add_theme_constant_override("separation", 6)
	equip_row.add_child(treat_col)

	var treat_title := Label.new()
	treat_title.text = "Treatment"
	if tm:
		tm.style_label(treat_title, "subtitle", "accent_green")
	else:
		treat_title.add_theme_font_size_override("font_size", 17)
	treat_col.add_child(treat_title)

	var treat_grid := GridContainer.new()
	treat_grid.columns = 2
	treat_grid.add_theme_constant_override("h_separation", 6)
	treat_grid.add_theme_constant_override("v_separation", 4)
	treat_col.add_child(treat_grid)

	var treatment_defs := [
		[tr("EQUIP_OXYGEN_MASK"), "oxygen_mask"],
		[tr("EQUIP_BVM"), "bvm"],
		[tr("EQUIP_AED"), "aed"],
		[tr("EQUIP_IV_ACCESS"), "iv_access"],
		[tr("EQUIP_C_COLLAR"), "c_collar"],
		[tr("EQUIP_TOURNIQUET"), "tourniquet"],
		[tr("EQUIP_BANDAGE"), "bandage"],
		[tr("EQUIP_SPLINT"), "splint"],
		[tr("EQUIP_STRETCHER"), "stretcher"],
	]

	for eq in treatment_defs:
		var eq_panel := PanelContainer.new()
		eq_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if tm:
			tm.style_panel(eq_panel)
		treat_grid.add_child(eq_panel)
		var eq_btn := Button.new()
		eq_btn.text = eq[0]
		eq_btn.custom_minimum_size = Vector2(0, 40)
		eq_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		eq_btn.focus_mode = Control.FOCUS_NONE
		eq_btn.pressed.connect(_on_equipment_pressed.bind(eq[1]))
		if tm:
			tm.style_button(eq_btn, "small")
		eq_btn.add_theme_color_override("font_color", tm.c("text_primary") if tm else Color(0.1, 0.1, 0.2))
		eq_panel.add_child(eq_btn)
		_equipment_buttons[eq[1]] = eq_btn

	## Bag Contents — hidden container (populate functions still write to _bag_items_vbox)
	_bag_items_vbox = VBoxContainer.new()
	_bag_items_vbox.visible = false
	equip_vbox.add_child(_bag_items_vbox)

	# ════════════════════════════════════════════════════════════
	# SUB-TAB: "drug_admin" — Drug Administration
	# ════════════════════════════════════════════════════════════
	var drug_scroll := ScrollContainer.new()
	drug_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drug_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	drug_scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	drug_scroll.visible = false
	sub_container.add_child(drug_scroll)
	_stab_sub_tabs["drug_admin"] = drug_scroll

	var drug_outer := VBoxContainer.new()
	drug_outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drug_outer.add_theme_constant_override("separation", 8)
	drug_scroll.add_child(drug_outer)

	var drug_title := Label.new()
	drug_title.text = tr("STABILIZE_DRUG_ADMIN")
	if tm:
		tm.style_label(drug_title, "subtitle", "accent_blue")
	else:
		drug_title.add_theme_font_size_override("font_size", 18)
	drug_outer.add_child(drug_title)

	var drug_row := HBoxContainer.new()
	drug_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drug_row.add_theme_constant_override("separation", 16)
	drug_outer.add_child(drug_row)

	# Left: Drug selection + Administer (1/4)
	var drug_left := VBoxContainer.new()
	drug_left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drug_left.size_flags_stretch_ratio = 1.0
	drug_left.add_theme_constant_override("separation", 8)
	drug_row.add_child(drug_left)

	var drug_name_label := Label.new()
	drug_name_label.text = tr("STABILIZE_DRUG") + ":"
	if tm:
		tm.style_label(drug_name_label, "body_small", "text_secondary")
	drug_left.add_child(drug_name_label)

	_drug_name_btn = OptionButton.new()
	_drug_name_btn.custom_minimum_size = Vector2(0, 38)
	_drug_name_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_drug_name_btn.focus_mode = Control.FOCUS_NONE
	_drug_name_btn.item_selected.connect(_on_drug_name_changed)
	if tm:
		tm.style_option_button(_drug_name_btn)
	drug_left.add_child(_drug_name_btn)

	var drug_route_label := Label.new()
	drug_route_label.text = tr("STABILIZE_ROUTE") + ":"
	if tm:
		tm.style_label(drug_route_label, "body_small", "text_secondary")
	drug_left.add_child(drug_route_label)

	_drug_route_btn = OptionButton.new()
	_drug_route_btn.custom_minimum_size = Vector2(0, 38)
	_drug_route_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_drug_route_btn.focus_mode = Control.FOCUS_NONE
	if tm:
		tm.style_option_button(_drug_route_btn)
	drug_left.add_child(_drug_route_btn)

	var drug_dose_label := Label.new()
	drug_dose_label.text = tr("STABILIZE_DOSE") + ":"
	if tm:
		tm.style_label(drug_dose_label, "body_small", "text_secondary")
	drug_left.add_child(drug_dose_label)

	_drug_dose_btn = OptionButton.new()
	_drug_dose_btn.custom_minimum_size = Vector2(0, 38)
	_drug_dose_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_drug_dose_btn.focus_mode = Control.FOCUS_NONE
	if tm:
		tm.style_option_button(_drug_dose_btn)
	drug_left.add_child(_drug_dose_btn)

	_drug_admin_btn = Button.new()
	var admin_btn := _drug_admin_btn
	admin_btn.text = tr("STABILIZE_ADMINISTER")
	admin_btn.custom_minimum_size = Vector2(0, 44)
	admin_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	admin_btn.focus_mode = Control.FOCUS_NONE
	admin_btn.pressed.connect(_on_administer_drug_pressed)
	if tm:
		tm.style_button(admin_btn)
	drug_left.add_child(admin_btn)

	_drug_feedback_label = Label.new()
	_drug_feedback_label.text = ""
	_drug_feedback_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if tm:
		tm.style_label(_drug_feedback_label, "label", "text_secondary")
	else:
		_drug_feedback_label.add_theme_font_size_override("font_size", 13)
	drug_left.add_child(_drug_feedback_label)

	# Right: Administration Log (3/4)
	var drug_right := VBoxContainer.new()
	drug_right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drug_right.size_flags_stretch_ratio = 3.0
	drug_right.add_theme_constant_override("separation", 4)
	drug_row.add_child(drug_right)

	var drug_log_title := Label.new()
	drug_log_title.text = tr("ADMIN_LOG_TITLE")
	if tm:
		tm.style_label(drug_log_title, "body", "text_primary")
	else:
		drug_log_title.add_theme_font_size_override("font_size", 14)
	drug_right.add_child(drug_log_title)

	var log_scroll := ScrollContainer.new()
	log_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_scroll.custom_minimum_size = Vector2(0, 150)
	drug_right.add_child(log_scroll)

	_drug_log_vbox = VBoxContainer.new()
	_drug_log_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_drug_log_vbox.add_theme_constant_override("separation", 4)
	log_scroll.add_child(_drug_log_vbox)

	# ════════════════════════════════════════════════════════════
	# SUB-TAB: "triage" — Triage Tags
	# ════════════════════════════════════════════════════════════
	var triage_panel := VBoxContainer.new()
	triage_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	triage_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	triage_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	triage_panel.visible = false
	triage_panel.add_theme_constant_override("separation", 16)
	sub_container.add_child(triage_panel)
	_stab_sub_tabs["triage"] = triage_panel

	var triage_title := Label.new()
	triage_title.text = "Assign Triage Tag"
	if tm:
		tm.style_label(triage_title, "subtitle", "accent_purple")
	triage_panel.add_child(triage_title)

	var triage_row := HBoxContainer.new()
	triage_row.add_theme_constant_override("separation", 8)
	triage_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	triage_panel.add_child(triage_row)

	var triage_defs := [
		["GREEN", "Minor", Color(0.2, 0.7, 0.2)],
		["YELLOW", "Delayed", Color(0.9, 0.8, 0.1)],
		["RED", "Immediate", Color(0.8, 0.2, 0.2)],
		["BLACK", "Deceased", Color(0.15, 0.15, 0.15)],
	]

	for td in triage_defs:
		var t_btn := Button.new()
		t_btn.text = td[0]
		t_btn.tooltip_text = td[1]
		t_btn.custom_minimum_size = Vector2(0, 64)
		t_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		t_btn.focus_mode = Control.FOCUS_NONE
		t_btn.pressed.connect(_on_triage_direct_pressed.bind(td[0]))
		if tm:
			tm.style_button(t_btn, "large")
		# Apply background color to the button
		var t_style: StyleBoxFlat = tm.make_btn_normal() if tm else StyleBoxFlat.new()
		t_style.bg_color = td[2]
		t_style.corner_radius_top_left = 8
		t_style.corner_radius_top_right = 8
		t_style.corner_radius_bottom_left = 8
		t_style.corner_radius_bottom_right = 8
		t_btn.add_theme_stylebox_override("normal", t_style)
		var t_hover: StyleBoxFlat = t_style.duplicate()
		t_hover.bg_color = td[2].lightened(0.15)
		t_btn.add_theme_stylebox_override("hover", t_hover)
		# WHITE text for all triage buttons (BLACK tag needs white text for contrast)
		t_btn.add_theme_color_override("font_color", Color.WHITE)
		t_btn.add_theme_color_override("font_hover_color", Color.WHITE)
		triage_row.add_child(t_btn)

	_triage_feedback_label = Label.new()
	_triage_feedback_label.text = ""
	if tm:
		tm.style_label(_triage_feedback_label, "body", "text_secondary")
	triage_panel.add_child(_triage_feedback_label)

	return root


# ==============================================================================
# TAB BUILD — Differential
# ==============================================================================

func _build_differential_tab() -> Control:
	var tm := _get_theme_medical()

	var root := VBoxContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_theme_constant_override("separation", 8)

	# Title
	var title := Label.new()
	title.text = tr("TAB_DIFFERENTIAL")
	if tm:
		tm.style_label(title, "title", "text_primary")
	else:
		title.add_theme_font_size_override("font_size", 22)
	root.add_child(title)

	# Search bar
	_ddx_search_input = LineEdit.new()
	_ddx_search_input.placeholder_text = "Search diagnoses..."
	_ddx_search_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_ddx_search_input.text_changed.connect(_on_ddx_search_changed)
	if tm:
		tm.style_input(_ddx_search_input)
	root.add_child(_ddx_search_input)

	# Scrollable area for categories
	var diag_scroll := ScrollContainer.new()
	diag_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(diag_scroll)

	var diag_vbox := VBoxContainer.new()
	diag_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	diag_vbox.name = "DiagVBox"
	diag_vbox.add_theme_constant_override("separation", 6)
	diag_scroll.add_child(diag_vbox)

	# Selected diagnoses display
	_diagnosis_rank_label = Label.new()
	_diagnosis_rank_label.text = "Selected: (none)"
	if tm:
		tm.style_label(_diagnosis_rank_label, "body", "text_primary")
	else:
		_diagnosis_rank_label.add_theme_font_size_override("font_size", 13)
	root.add_child(_diagnosis_rank_label)

	# Submit button — full width, accent blue
	_submit_diagnosis_btn = Button.new()
	_submit_diagnosis_btn.text = tr("DDX_SUBMIT")
	_submit_diagnosis_btn.custom_minimum_size = Vector2(0, 52)
	_submit_diagnosis_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_submit_diagnosis_btn.focus_mode = Control.FOCUS_NONE
	_submit_diagnosis_btn.pressed.connect(_on_submit_diagnosis_pressed)
	_submit_diagnosis_btn.disabled = true
	if tm:
		tm.style_button(_submit_diagnosis_btn, "large")
		var submit_normal: StyleBoxFlat = tm.make_btn_normal()
		submit_normal.bg_color = tm.c("accent_blue")
		_submit_diagnosis_btn.add_theme_stylebox_override("normal", submit_normal)
		var submit_hover: StyleBoxFlat = tm.make_btn_hover()
		submit_hover.bg_color = tm.c("accent_blue").lightened(0.15)
		_submit_diagnosis_btn.add_theme_stylebox_override("hover", submit_hover)
		_submit_diagnosis_btn.add_theme_color_override("font_color", Color.WHITE)
		_submit_diagnosis_btn.add_theme_color_override("font_hover_color", Color.WHITE)
	root.add_child(_submit_diagnosis_btn)

	return root


## Toggle a DDx category open/closed.
func _on_ddx_category_toggle(cat_name: String, header_btn: Button) -> void:
	var is_collapsed: bool = _ddx_category_collapsed.get(cat_name, false)
	_ddx_category_collapsed[cat_name] = not is_collapsed
	var grid: GridContainer = _ddx_category_grids.get(cat_name)
	if grid:
		grid.visible = is_collapsed  # Was collapsed → now open
	header_btn.text = ("▼ " if is_collapsed else "▶ ") + cat_name


## Search filter for differential diagnoses.
func _on_ddx_search_changed(text: String) -> void:
	var query := text.strip_edges().to_lower()
	for btn in _diagnosis_buttons:
		if is_instance_valid(btn):
			btn.visible = query == "" or query in btn.text.to_lower()
	# Show/hide category headers based on whether they have visible buttons
	for cat_name in _ddx_category_containers:
		var cat_wrapper: Control = _ddx_category_containers[cat_name]
		if not is_instance_valid(cat_wrapper):
			continue
		var has_visible := false
		var grid: GridContainer = _ddx_category_grids.get(cat_name)
		if grid:
			for child in grid.get_children():
				if child is Button and child.visible:
					has_visible = true
					break
		cat_wrapper.visible = has_visible or query == ""


# ==============================================================================
# THEME APPLICATION — re-applies all styles when theme changes
# ==============================================================================

func _apply_theme() -> void:
	var tm := _get_theme_medical()
	if not tm:
		return

	# Overlay background
	var bg_node := get_node_or_null("OverlayBg")
	if bg_node and bg_node is ColorRect:
		bg_node.color = tm.c("overlay")

	# Left panel
	if _left_panel:
		tm.style_panel(_left_panel)

	# Tab buttons
	for tab_id in _tab_buttons:
		var btn: Button = _tab_buttons[tab_id]
		tm.style_button(btn)
		if tab_id == _current_tab:
			btn.add_theme_stylebox_override("normal", tm.make_tab_active())
			btn.add_theme_stylebox_override("disabled", tm.make_tab_active())
		else:
			btn.add_theme_stylebox_override("normal", tm.make_tab_inactive())
			btn.add_theme_stylebox_override("disabled", tm.make_tab_inactive())

	# Close button
	if _close_btn:
		tm.style_button(_close_btn)
		_close_btn.add_theme_color_override("font_color", tm.c("accent_red"))
		_close_btn.add_theme_color_override("font_hover_color", tm.c("accent_red"))

	# Patient tab elements
	if _patient_info_label:
		tm.style_rich_label(_patient_info_label, "body")
	if _ai_status_label:
		tm.style_label(_ai_status_label, "caption", "text_secondary")
	if _chat_input:
		tm.style_input(_chat_input)
	if _talk_button:
		tm.style_button(_talk_button)

	# Exam sub-tab pills
	for key in _exam_sub_tab_btns:
		tm.style_button(_exam_sub_tab_btns[key], "small")
		if key == _current_exam_sub:
			_exam_sub_tab_btns[key].add_theme_stylebox_override("normal", tm.make_tab_active())
		else:
			_exam_sub_tab_btns[key].add_theme_stylebox_override("normal", tm.make_tab_inactive())

	# Stabilize sub-tab pills
	for key in _stab_sub_tab_btns:
		tm.style_button(_stab_sub_tab_btns[key], "small")
		if key == _current_stab_sub:
			_stab_sub_tab_btns[key].add_theme_stylebox_override("normal", tm.make_tab_active())
		else:
			_stab_sub_tab_btns[key].add_theme_stylebox_override("normal", tm.make_tab_inactive())

	# Exam tab — DRSABCDE buttons
	for key in _exam_buttons:
		tm.style_button(_exam_buttons[key])
	for key in _exam_results:
		tm.style_label(_exam_results[key], "body_small", "text_secondary")

	# Vital buttons
	for key in _vital_buttons:
		tm.style_button(_vital_buttons[key], "small")
	for key in _vital_results:
		tm.style_label(_vital_results[key], "body_small", "text_secondary")

	# ECG panel
	if _ecg_panel:
		tm.style_panel(_ecg_panel, "info")
	if _ecg_rhythm_label:
		tm.style_label(_ecg_rhythm_label, "label", "text_secondary")
	if _ecg_mode_label:
		tm.style_label(_ecg_mode_label, "label", "text_muted")

	# GCS buttons
	for btn_key in _gcs_component_btns:
		tm.style_button(_gcs_component_btns[btn_key], "small")
	if _gcs_total_label:
		tm.style_label(_gcs_total_label, "subtitle", "text_primary")
	if _gcs_severity_label:
		tm.style_label(_gcs_severity_label, "label", "text_secondary")

	# Secondary survey buttons
	for region in _secondary_buttons:
		tm.style_button(_secondary_buttons[region])
	for region in _secondary_results:
		tm.style_label(_secondary_results[region], "body_small", "text_secondary")

	# Stabilize tab — equipment buttons
	for key in _equipment_buttons:
		tm.style_button(_equipment_buttons[key], "small")

	# CPR button
	if _cpr_button:
		tm.style_button(_cpr_button, "large")
		var cpr_normal: StyleBoxFlat = tm.make_btn_normal()
		cpr_normal.bg_color = tm.c("accent_red")
		_cpr_button.add_theme_stylebox_override("normal", cpr_normal)
		var cpr_hover: StyleBoxFlat = tm.make_btn_hover()
		cpr_hover.bg_color = tm.c("accent_red").lightened(0.15)
		_cpr_button.add_theme_stylebox_override("hover", cpr_hover)
		_cpr_button.add_theme_color_override("font_color", Color.WHITE)
		_cpr_button.add_theme_color_override("font_hover_color", Color.WHITE)

	# Drug admin option buttons
	if _drug_name_btn:
		tm.style_option_button(_drug_name_btn)
	if _drug_route_btn:
		tm.style_option_button(_drug_route_btn)
	if _drug_dose_btn:
		tm.style_option_button(_drug_dose_btn)
	if _drug_feedback_label:
		tm.style_label(_drug_feedback_label, "label", "text_secondary")

	# Bag tier label
	if _bag_tier_label:
		tm.style_label(_bag_tier_label, "body", "accent_green")

	# Submit diagnosis button
	if _submit_diagnosis_btn:
		tm.style_button(_submit_diagnosis_btn, "large")
		var submit_normal: StyleBoxFlat = tm.make_btn_normal()
		submit_normal.bg_color = tm.c("accent_blue")
		_submit_diagnosis_btn.add_theme_stylebox_override("normal", submit_normal)
		var submit_hover: StyleBoxFlat = tm.make_btn_hover()
		submit_hover.bg_color = tm.c("accent_blue").lightened(0.15)
		_submit_diagnosis_btn.add_theme_stylebox_override("hover", submit_hover)
		_submit_diagnosis_btn.add_theme_color_override("font_color", Color.WHITE)
		_submit_diagnosis_btn.add_theme_color_override("font_hover_color", Color.WHITE)

	if _diagnosis_rank_label:
		tm.style_label(_diagnosis_rank_label, "body", "text_primary")

	# Diagnosis buttons (dynamically created — may be empty at init)
	for btn in _diagnosis_buttons:
		if is_instance_valid(btn):
			tm.style_button(btn, "small")


# ==============================================================================
# POPULATE — Patient tab
# ==============================================================================

func _populate_patient_tab() -> void:
	if not _patient:
		return

	var info_text := "[b]Patient:[/b] Unknown\n"

	var persona: Node = null
	var medical_state: Node = null

	if _patient.has_node("PatientPersona"):
		persona = _patient.get_node("PatientPersona")
	if _patient.has_node("MedicalStateComponent"):
		medical_state = _patient.get_node("MedicalStateComponent")

	if persona:
		var name_val: String = persona.get("patient_name") if persona.get("patient_name") else "Unknown"
		var age_val = persona.get("age") if persona.get("age") else "?"
		var gender_val: String = persona.get("gender") if persona.get("gender") else "?"
		info_text = "[b]%s[/b], %s, %s\n" % [name_val, str(age_val), gender_val]

		var chief_complaint: String = persona.get("chief_complaint") if persona.get("chief_complaint") else ""
		if chief_complaint != "":
			info_text += "[color=yellow]CC:[/color] %s\n" % chief_complaint

	if medical_state:
		var consciousness: String = medical_state.get("consciousness_level") if medical_state.get("consciousness_level") else ""
		if consciousness != "":
			var c_color := "white"
			if consciousness == "UNRESPONSIVE":
				c_color = "red"
			elif consciousness == "VERBAL":
				c_color = "yellow"
			info_text += "[color=%s]Consciousness: %s[/color]\n" % [c_color, consciousness]

	if _patient_info_label:
		_patient_info_label.text = info_text

	# ARC-12: gate OPQRST button visibility and styling
	if _opqrst_btn:
		var consciousness_level := ""
		if medical_state:
			consciousness_level = medical_state.get("consciousness_level") if medical_state.get("consciousness_level") else ""

		if consciousness_level == "UNRESPONSIVE":
			_opqrst_btn.disabled = true
			_opqrst_btn.tooltip_text = "Patient is unresponsive — cannot describe pain"
			# Disabled color handled by theme (text_muted)
		else:
			_opqrst_btn.disabled = false
			_opqrst_btn.tooltip_text = ""
			var _tmo := _get_theme_medical()

			var pain_level: int = 0
			if medical_state:
				pain_level = medical_state.get("pain_level") if medical_state.get("pain_level") else 0

			if pain_level > 0:
				_opqrst_btn.add_theme_color_override("font_color", _tmo.c("accent_yellow") if _tmo else Color(1.0, 0.85, 0.0))
				_opqrst_btn.text = "O - OPQRST (Pain %d/10)" % pain_level
			else:
				_opqrst_btn.add_theme_color_override("font_color", _tmo.c("accent_yellow") if _tmo else Color(1.0, 0.75, 0.2))
				_opqrst_btn.text = "O - OPQRST (Pain)"

	# Clear chat on open
	if _chat_container:
		for child in _chat_container.get_children():
			child.queue_free()


# ==============================================================================
# POPULATE — Exam tab
# ==============================================================================

func _populate_exam_tab() -> void:
	# Reset DRSABCDE
	_exam_completed = 0
	var _tm := _get_theme_medical()
	for key in _exam_results:
		_exam_results[key].text = ""
		if _tm:
			_exam_results[key].add_theme_color_override("font_color", _tm.c("text_secondary"))
	for key in _exam_buttons:
		_exam_buttons[key].disabled = false
		if _tm:
			_tm.style_button(_exam_buttons[key])

	if _exam_counter_label:
		_exam_counter_label.text = "0/%d" % _exam_total

	# Reset vitals
	for key in _vital_results:
		_vital_results[key].text = ""
		if _vital_results[key].has_theme_color_override("font_color"):
			_vital_results[key].remove_theme_color_override("font_color")
	for key in _vital_buttons:
		_vital_buttons[key].disabled = false

	# Reset ECG — clear texture so previous patient's strip doesn't bleed through
	if _ecg_mode_label:
		_ecg_mode_label.text = ""
		var _tm2 := _get_theme_medical()
		if _tm2:
			_ecg_mode_label.add_theme_color_override("font_color", _tm2.c("text_muted"))
	if _ecg_panel:
		_ecg_panel.visible = false
	if _ecg_texture_rect:
		_ecg_texture_rect.texture = null
		_ecg_texture_rect.visible = false
	if _ecg_rhythm_label:
		_ecg_rhythm_label.text = ""

	# Reset GCS
	_gcs_component_selection = {}
	if _gcs_total_label:
		_gcs_total_label.text = "GCS: --"
		if _gcs_total_label.has_theme_color_override("font_color"):
			_gcs_total_label.remove_theme_color_override("font_color")
	if _gcs_severity_label:
		_gcs_severity_label.text = ""
	for btn_key in _gcs_component_btns:
		var b: Button = _gcs_component_btns[btn_key]
		if b.has_theme_color_override("font_color"):
			b.remove_theme_color_override("font_color")

	# Reset secondary survey
	_secondary_completed_count = 0
	for region in _secondary_results:
		_secondary_results[region].text = ""
		if _secondary_results[region].has_theme_color_override("font_color"):
			_secondary_results[region].remove_theme_color_override("font_color")
	for region in _secondary_buttons:
		_secondary_buttons[region].disabled = false
		if _secondary_buttons[region].has_theme_color_override("font_color"):
			_secondary_buttons[region].remove_theme_color_override("font_color")
	if _secondary_counter_label:
		_secondary_counter_label.text = "0/7"


# ==============================================================================
# POPULATE — Stabilize tab
# ==============================================================================

func _populate_stabilize_tab() -> void:
	# CPR button: hidden by default. Only revealed after player assesses pulse/HR
	# and the patient is actually in cardiac arrest. Call _check_cpr_visibility()
	# after each assessment action to update.
	_cpr_active = false
	if _cpr_button:
		_cpr_button.visible = false
		_cpr_button.disabled = false
		_cpr_button.text = "Start CPR (Chest Compressions)"
	if _cpr_status_label:
		_cpr_status_label.visible = false
		_cpr_status_label.text = ""

	# Reset all equipment buttons to available state
	for key in _equipment_buttons:
		var btn: Button = _equipment_buttons[key]
		btn.text = btn.text.trim_suffix(" ✓")
		btn.disabled = false
		if btn.has_theme_color_override("font_color"):
			btn.remove_theme_color_override("font_color")

	# Disable equipment buttons for items no longer available in bag
	if _bag_tier_manager and _bag_tier_manager.has_method("is_available"):
		for key in _equipment_buttons:
			var bag_key: String = EQUIP_TO_BAG_KEY.get(key, key.to_upper())
			if not _bag_tier_manager.is_available(bag_key):
				_equipment_buttons[key].disabled = true

	# Re-mark already applied equipment with checkmarks
	for eq in _applied_equipment:
		if _equipment_buttons.has(eq):
			_equipment_buttons[eq].text = _equipment_buttons[eq].text.trim_suffix(" ✓") + " ✓"
			_equipment_buttons[eq].disabled = true


# ==============================================================================
# POPULATE — Differential tab
# ==============================================================================

func _populate_differential_tab() -> void:
	# Find the diag vbox via name lookup
	var diag_vbox: VBoxContainer = null
	var tab_root: Control = _tab_contents.get(Tab.DIFFERENTIAL)
	if tab_root:
		diag_vbox = tab_root.find_child("DiagVBox", true, false)

	if not diag_vbox:
		return

	# Clear existing buttons AND category containers
	for b in _diagnosis_buttons:
		if is_instance_valid(b):
			b.queue_free()
	_diagnosis_buttons.clear()

	# Clear old category containers from the tree
	for cat_name in _ddx_category_containers:
		var cat_wrapper: Control = _ddx_category_containers[cat_name]
		if is_instance_valid(cat_wrapper):
			cat_wrapper.queue_free()
	_ddx_category_containers.clear()
	_ddx_category_grids.clear()
	_ddx_category_collapsed.clear()

	var tm := _get_theme_medical()

	# If already diagnosed, show locked state
	if _diagnosis_submitted:
		if _diagnosis_rank_label:
			var parts: PackedStringArray = PackedStringArray()
			for d in _selected_diagnoses:
				parts.append(d)
			_diagnosis_rank_label.text = "Submitted: " + ", ".join(parts)
			var _tm_rank := _get_theme_medical()
			_diagnosis_rank_label.add_theme_color_override("font_color", _tm_rank.c("accent_green") if _tm_rank else Color(0.3, 0.9, 0.4))
		if _submit_diagnosis_btn:
			_submit_diagnosis_btn.disabled = true
			_submit_diagnosis_btn.text = "Diagnosis Submitted"
	else:
		if _diagnosis_rank_label:
			_diagnosis_rank_label.text = "Selected: (none)"
		if _submit_diagnosis_btn:
			_submit_diagnosis_btn.disabled = true
			_submit_diagnosis_btn.text = "Submit Diagnosis"

	# Categorized differential diagnosis list
	var ddx_categories := {
		"Cardiac": [
			"Cardiac Arrest", "Myocardial Infarction (STEMI)", "Myocardial Infarction (NSTEMI)",
			"Unstable Angina", "Ventricular Fibrillation", "Ventricular Tachycardia",
			"Bradycardia", "SVT / Tachyarrhythmia", "Heart Failure / Pulmonary Oedema",
			"Cardiac Tamponade", "Aortic Dissection",
		],
		"Respiratory": [
			"Pneumothorax", "Tension Pneumothorax", "Asthma (Acute)",
			"COPD Exacerbation", "Pulmonary Embolism", "Respiratory Failure",
			"Smoke Inhalation", "Upper Airway Obstruction",
		],
		"Trauma": [
			"Trauma -- Multi-system", "Haemorrhagic Shock", "Internal Bleeding",
			"Crush Injury / Rhabdomyolysis", "Burns (Thermal)", "Blast Injury",
			"Penetrating Trauma", "Fracture -- Open", "Fracture -- Closed",
		],
		"Neurological": [
			"Stroke (Ischaemic)", "Stroke (Haemorrhagic)", "Seizure / Status Epilepticus",
			"Head Injury / TBI", "Spinal Injury",
		],
		"Medical": [
			"Anaphylaxis", "Hypoglycaemia", "Diabetic Ketoacidosis",
			"Sepsis / Septic Shock", "Opioid Overdose", "Drug Overdose (Other)",
			"Poisoning / Toxic Exposure", "CO Poisoning",
			"Hypothermia", "Hyperthermia / Heat Stroke",
		],
		"Other": [
			"Minor Bleeding / Laceration", "Soft Tissue Injury",
			"Acute Abdomen", "Ectopic Pregnancy",
		],
	}

	_ddx_category_containers.clear()
	_ddx_category_grids.clear()
	_ddx_category_collapsed.clear()

	var cat_index := 0
	for cat_name in ddx_categories:
		var cat_wrapper := VBoxContainer.new()
		cat_wrapper.add_theme_constant_override("separation", 4)
		diag_vbox.add_child(cat_wrapper)
		_ddx_category_containers[cat_name] = cat_wrapper

		# Category header — collapsible toggle
		var header_btn := Button.new()
		var is_open: bool = cat_index < 2  # First 2 categories open by default
		header_btn.text = ("▼ " if is_open else "▶ ") + cat_name
		header_btn.custom_minimum_size = Vector2(0, 32)
		header_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		header_btn.focus_mode = Control.FOCUS_NONE
		header_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		if tm:
			tm.style_button(header_btn, "small")
			header_btn.add_theme_color_override("font_color", tm.c("accent_blue"))
		header_btn.pressed.connect(_on_ddx_category_toggle.bind(cat_name, header_btn))
		cat_wrapper.add_child(header_btn)

		# Category grid
		var cat_grid := GridContainer.new()
		cat_grid.columns = 3
		cat_grid.add_theme_constant_override("h_separation", 6)
		cat_grid.add_theme_constant_override("v_separation", 4)
		cat_grid.visible = is_open
		cat_wrapper.add_child(cat_grid)
		_ddx_category_grids[cat_name] = cat_grid
		_ddx_category_collapsed[cat_name] = not is_open

		for diag in ddx_categories[cat_name]:
			var btn := Button.new()
			btn.text = diag
			btn.custom_minimum_size = Vector2(0, 36)
			btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			btn.focus_mode = Control.FOCUS_NONE
			btn.pressed.connect(_on_diagnosis_button_pressed.bind(diag))
			if tm:
				tm.style_button(btn, "small")
			if _diagnosis_submitted:
				btn.disabled = true
				if diag in _selected_diagnoses:
					var _tm_d := _get_theme_medical()
					btn.add_theme_color_override("font_color", _tm_d.c("accent_green") if _tm_d else Color(0.2, 1.0, 0.3))
			cat_grid.add_child(btn)
			_diagnosis_buttons.append(btn)

		cat_index += 1


# ==============================================================================
# ARC-13: POPULATE — Vital Signs
# ==============================================================================

func _populate_vitals_section() -> void:
	# Vitals reset is handled in _populate_exam_tab
	pass


# ==============================================================================
# ARC-14: POPULATE — ECG section
# ==============================================================================

func _populate_ecg_section() -> void:
	if not _patient:
		return

	var medical_state: Node = _patient.get_node_or_null("MedicalStateComponent")
	if not medical_state:
		return

	var deployed: Array = []
	if medical_state.get("deployed_equipment") != null:
		deployed = medical_state.get("deployed_equipment")

	var has_aed := "AED" in deployed or "aed" in deployed
	var has_cardiac_monitor := "CARDIAC_MONITOR" in deployed or "cardiac_monitor" in deployed

	if has_aed or has_cardiac_monitor:
		var mode_text := "AED (Auto Analysis)" if has_aed else "Cardiac Monitor (Manual)"
		if _ecg_mode_label:
			_ecg_mode_label.text = mode_text
			_ecg_mode_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.6))

		if _ecg_panel:
			_ecg_panel.visible = true

		# Attempt to load ECG texture
		var rhythm_key: String = ""
		if medical_state.get("ecg_rhythm") != null:
			rhythm_key = str(medical_state.get("ecg_rhythm"))

		if _ecg_rhythm_manager and rhythm_key != "":
			var tex = null
			if _ecg_rhythm_manager.has_method("get_rhythm_texture"):
				tex = _ecg_rhythm_manager.get_rhythm_texture(rhythm_key)
			if tex and _ecg_texture_rect:
				_ecg_texture_rect.texture = tex
				_ecg_texture_rect.visible = true
			else:
				# Placeholder — texture not yet placed, hide TextureRect
				if _ecg_texture_rect:
					_ecg_texture_rect.visible = false
	else:
		if _ecg_mode_label:
			_ecg_mode_label.text = "No monitor deployed"
			_ecg_mode_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		if _ecg_panel:
			_ecg_panel.visible = false


# ==============================================================================
# ARC-15: POPULATE — GCS section
# ==============================================================================

func _populate_gcs_section() -> void:
	# GCS reset already done in _populate_exam_tab
	pass


# ==============================================================================
# ARC-16: POPULATE — Secondary Survey
# ==============================================================================

func _populate_secondary_section() -> void:
	# Secondary survey reset already done in _populate_exam_tab
	pass


# ==============================================================================
# ARC-17: POPULATE — Drug section
# ==============================================================================

func _populate_drug_section() -> void:
	if not _drug_name_btn:
		return

	_drug_name_btn.clear()
	_drug_route_btn.clear()
	_drug_dose_btn.clear()

	if _current_drug_data.is_empty():
		if _drug_feedback_label:
			_drug_feedback_label.text = "Drug data unavailable."
			_drug_feedback_label.add_theme_color_override("font_color", Color(0.8, 0.4, 0.4))
		_drug_name_btn.disabled = true
		_drug_route_btn.disabled = true
		_drug_dose_btn.disabled = true
		return

	_drug_name_btn.disabled = false
	_drug_route_btn.disabled = false
	_drug_dose_btn.disabled = false

	# Maps bag inventory keys → drugs.json keys (different naming conventions)
	var bag_to_drug_map := {
		"EPIPEN": "EPINEPHRINE_IM",
		"ASPIRIN_TABLET": "ASPIRIN",
		"GTN_SPRAY": "GTN",
		"ORAL_GLUCOSE": "GLUCOSE_ORAL",
		"EPINEPHRINE_IV_AMP": "EPINEPHRINE_IV",
		"AMIODARONE_AMP": "AMIODARONE",
		"ATROPINE_AMP": "ATROPINE",
		"MORPHINE_AMP": "MORPHINE",
		"KETAMINE_VIAL": "KETAMINE",
		"NALOXONE_AMP": "NALOXONE",
		"DEXTROSE_50": "DEXTROSE_50",
		"NORMAL_SALINE_500": "NORMAL_SALINE",
		"NORMAL_SALINE_1000": "NORMAL_SALINE",
		"GLUCAGON_KIT": "GLUCOSE_ORAL",
	}

	# drugs.json is a flat dict: { "DRUG_KEY": { "display_name": "...", ... }, ... }
	# Filter by bag tier — only show drugs the player has in their bag
	var available_drug_keys: Array = []
	if _bag_tier_manager and _bag_tier_manager.has_method("get_all_items"):
		var bag_items: Dictionary = _bag_tier_manager.get_all_items()
		for bag_key in bag_items:
			if not bag_items[bag_key].get("available", false):
				continue
			# Try direct match first, then mapped key
			var drug_key: String = bag_to_drug_map.get(bag_key, bag_key)
			if _current_drug_data.has(drug_key) and drug_key not in available_drug_keys:
				available_drug_keys.append(drug_key)
	# Fallback: if no bag manager or no matches, show all drugs from JSON
	if available_drug_keys.is_empty():
		for key in _current_drug_data:
			var drug: Dictionary = _current_drug_data[key]
			if drug is Dictionary and drug.has("display_name"):
				available_drug_keys.append(key)

	for key in available_drug_keys:
		var drug: Dictionary = _current_drug_data[key]
		var dname: String = drug.get("display_name", key)
		_drug_name_btn.add_item(dname)
		_drug_name_btn.set_item_metadata(_drug_name_btn.item_count - 1, key)

	if available_drug_keys.size() > 0:
		_on_drug_name_changed(0)

	# Clear drug log
	if _drug_log_vbox:
		for child in _drug_log_vbox.get_children():
			child.queue_free()

	if _drug_feedback_label:
		_drug_feedback_label.text = ""


# ==============================================================================
# ARC-18: POPULATE — Bag section
# ==============================================================================

func _populate_bag_section() -> void:
	if not _bag_items_vbox:
		return

	# Clear existing
	for child in _bag_items_vbox.get_children():
		child.queue_free()

	# Determine tier from manager or default
	var tier_name := "BLS"

	if _bag_tier_manager and _bag_tier_manager.has_method("get_current_tier"):
		tier_name = _bag_tier_manager.get_current_tier()
	elif _bag_tier_manager and _bag_tier_manager.get("current_tier") != null:
		tier_name = str(_bag_tier_manager.get("current_tier"))

	if _bag_tier_label:
		_bag_tier_label.text = tier_name
		var tier_color := Color(0.3, 0.9, 0.4)  # BLS = green
		if tier_name == "ALS" or tier_name == "ADVANCED":
			tier_color = Color(0.3, 0.6, 1.0)
		elif tier_name == "CRITICAL" or tier_name == "HEMS":
			tier_color = Color(1.0, 0.4, 0.4)
		_bag_tier_label.add_theme_color_override("font_color", tier_color)

	# Pull live items from MedicalBagTierManager (primary source)
	var live_items: Dictionary = {}
	if _bag_tier_manager and _bag_tier_manager.has_method("get_all_items"):
		live_items = _bag_tier_manager.get_all_items()

	# Fallback: read from raw JSON if manager not available
	if live_items.is_empty() and not _current_bag_data.is_empty():
		var bls_items: Array = _current_bag_data.get("BLS", {}).get("items", [])
		var als_items: Array = _current_bag_data.get("ALS", {}).get("additional_items", [])
		var raw_items: Array = bls_items
		if tier_name == "ALS":
			raw_items = bls_items + als_items
		for item in raw_items:
			var k: String = item.get("key", "")
			if k != "":
				live_items[k] = {
					"display": item.get("display", k),
					"category": item.get("category", ""),
					"quantity": item.get("quantity", 1),
					"consumable": item.get("consumable", true),
					"available": item.get("quantity", 1) > 0,
				}

	var tm := _get_theme_medical()

	if live_items.is_empty():
		var empty_lbl := Label.new()
		empty_lbl.text = "No items in bag for tier: %s" % tier_name
		if tm:
			tm.style_label(empty_lbl, "body_small", "text_muted")
		else:
			empty_lbl.add_theme_font_size_override("font_size", 12)
		_bag_items_vbox.add_child(empty_lbl)
		return

	for itype in live_items:
		var item: Dictionary = live_items[itype]
		var iname: String = item.get("display", itype.capitalize())
		var qty: int = item.get("quantity", 0)
		var available: bool = item.get("available", qty > 0)

		var item_card := PanelContainer.new()
		if tm:
			tm.style_panel(item_card)
		_bag_items_vbox.add_child(item_card)

		var item_hbox := HBoxContainer.new()
		item_hbox.add_theme_constant_override("separation", 8)
		item_card.add_child(item_hbox)

		var item_name_lbl := Label.new()
		item_name_lbl.text = iname
		item_name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if tm:
			tm.style_label(item_name_lbl, "label", "text_primary")
		else:
			item_name_lbl.add_theme_font_size_override("font_size", 13)
		item_hbox.add_child(item_name_lbl)

		var qty_lbl := Label.new()
		qty_lbl.text = "x%d" % qty
		qty_lbl.custom_minimum_size = Vector2(40, 0)
		if tm:
			tm.style_label(qty_lbl, "label", "accent_blue")
		else:
			qty_lbl.add_theme_font_size_override("font_size", 13)
		item_hbox.add_child(qty_lbl)

		var deploy_btn := Button.new()
		deploy_btn.text = "Deploy"
		deploy_btn.custom_minimum_size = Vector2(70, 28)
		deploy_btn.focus_mode = Control.FOCUS_NONE
		deploy_btn.disabled = not available
		deploy_btn.pressed.connect(_on_bag_item_deploy.bind(itype, iname, qty_lbl, deploy_btn))
		if tm:
			tm.style_button(deploy_btn, "small")
		item_hbox.add_child(deploy_btn)


# ==============================================================================
# HANDLERS — Patient tab
# ==============================================================================

func _on_sample_category_pressed(category: String) -> void:
	if not _patient:
		return

	var question_text := _get_sample_question(category)
	_add_chat_bubble(question_text, true)

	if _history_manager and _history_manager.has_method("query_category"):
		var result: String = _history_manager.query_category(category)
		if result != "":
			_add_chat_bubble(result, false)
			return

	# Fallback to Ollama
	if _dialogue_client and _dialogue_client.ollama_available:
		if _ai_status_label:
			_ai_status_label.text = "Waiting for response..."
		_dialogue_client.ask_patient(question_text)
	else:
		var scripted := _get_scripted_response(category)
		_add_chat_bubble(scripted, false)


func _on_chat_submitted(text: String) -> void:
	if text.strip_edges() == "":
		return
	_chat_input.clear()
	_add_chat_bubble(text, true)
	if _dialogue_client and _dialogue_client.ollama_available:
		if _ai_status_label:
			_ai_status_label.text = "Waiting for response..."
		_dialogue_client.ask_patient(text)
	else:
		# Without AI, pull a contextual response from persona symptoms/events
		var fallback_text := "..."
		if _patient and "persona" in _patient and _patient.persona:
			var persona: PatientPersona = _patient.persona
			if not persona.history_symptoms.is_empty():
				var first_key: String = persona.history_symptoms.keys()[0]
				fallback_text = str(persona.history_symptoms[first_key])
			elif not persona.history_events.is_empty():
				var first_key: String = persona.history_events.keys()[0]
				fallback_text = str(persona.history_events[first_key])
		_add_chat_bubble(fallback_text, false)


func _on_talk_button_pressed() -> void:
	if _chat_input:
		_on_chat_submitted(_chat_input.text)


func _on_ai_response(response: String) -> void:
	if _ai_status_label:
		_ai_status_label.text = tr("PATIENT_AI_ACTIVE")
	_add_chat_bubble(response, false)


func _on_ai_failed(error: String) -> void:
	if _ai_status_label:
		_ai_status_label.text = "AI Error: " + error
		_ai_status_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))


func _add_chat_bubble(text: String, is_player: bool) -> void:
	if not _chat_container:
		return

	var tm := _get_theme_medical()

	# Create a card-style panel for each chat bubble
	var bubble_panel := PanelContainer.new()
	if tm:
		if is_player:
			# Player bubble: accent_blue tinted card
			var player_style: StyleBoxFlat = tm.make_card()
			if tm.current_mode == "dark":
				player_style.bg_color = tm.c("accent_blue").darkened(0.6)
				player_style.border_color = tm.c("accent_blue").darkened(0.3)
			else:
				player_style.bg_color = tm.c("accent_blue").lightened(0.8)
				player_style.border_color = tm.c("accent_blue").lightened(0.4)
			bubble_panel.add_theme_stylebox_override("panel", player_style)
		else:
			# Patient bubble: standard bg_card
			tm.style_panel(bubble_panel)

	var lbl := Label.new()
	lbl.text = ("[Player] " if is_player else "[Patient] ") + text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	if tm:
		if is_player:
			lbl.add_theme_color_override("font_color", tm.c("accent_blue").lightened(0.3))
		else:
			lbl.add_theme_color_override("font_color", tm.c("text_primary"))
		lbl.add_theme_font_size_override("font_size", tm.FONT_SIZES.body)
	else:
		if is_player:
			lbl.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
		else:
			lbl.add_theme_color_override("font_color", Color(1.0, 0.9, 0.7))

	bubble_panel.add_child(lbl)
	_chat_container.add_child(bubble_panel)

	# Scroll to bottom
	await get_tree().process_frame
	if _chat_scroll:
		_chat_scroll.scroll_vertical = int(_chat_scroll.get_v_scroll_bar().max_value)


# ==============================================================================
# HANDLERS — Exam tab (DRSABCDE)
# ==============================================================================

func _on_exam_action_pressed(action_name: String) -> void:
	if not _assessment_manager:
		_exam_results[action_name].text = "No assessment manager."
		return
	# Cooldown: DRS = 0.5s, ABCDE = 2s. Result appears AFTER delay.
	var drs_actions := ["check_danger", "check_response", "send_help"]
	var group := "drs" if action_name in drs_actions else "abcde"
	var btn: Button = _exam_buttons.get(action_name)
	if not btn:
		return
	if not _start_cooldown(btn, group, _do_exam_action.bind(action_name)):
		return


## Deferred exam action — runs after cooldown completes.
func _do_exam_action(action_name: String) -> void:
	if not _assessment_manager:
		return
	var result: Dictionary = {}
	if _assessment_manager.has_method("perform_assessment_by_name"):
		result = _assessment_manager.perform_assessment_by_name(action_name)
	elif _assessment_manager.has_method("perform_assessment"):
		result = _assessment_manager.perform_assessment(action_name)

	if result.is_empty():
		result = _build_drsabcde_finding(action_name)

	var result_text := _format_assessment_result(result, action_name)
	if _exam_results.has(action_name):
		_exam_results[action_name].text = result_text
		var tm := _get_theme_medical()
		if tm:
			_exam_results[action_name].add_theme_color_override("font_color", tm.c("text_primary"))
	if _exam_buttons.has(action_name):
		var tm2 := _get_theme_medical()
		if tm2:
			_exam_buttons[action_name].add_theme_color_override("font_color", tm2.c("accent_green"))

	_exam_completed += 1
	if _exam_counter_label:
		_exam_counter_label.text = "%d/%d" % [_exam_completed, _exam_total]

	_check_cpr_visibility()
	assessment_action.emit(action_name)

	# Log to telemetry — map UI action names to protocol-standard names
	var telemetry_name: String = _map_exam_to_telemetry(action_name)
	if telemetry_name != "":
		var telemetry: Node = get_node_or_null("/root/TelemetryCollector")
		if telemetry and telemetry.has_method("record_event"):
			var ts: float = 0.0
			if telemetry.get("_session_start_msec") != null and telemetry._session_start_msec > 0:
				ts = (Time.get_ticks_msec() - telemetry._session_start_msec) / 1000.0
			var patient_name: String = _patient.name if _patient else ""
			telemetry.record_event({
				"type": telemetry_name,
				"target": patient_name,
				"timestamp": ts,
				"player_position": {"x": 0, "y": 0, "z": 0},
				"details": result,
			})


# ==============================================================================
# ARC-13: HANDLERS — Vital Signs
# ==============================================================================

func _on_vital_pressed(key: String, action_id: int) -> void:
	var result_lbl: Label = _vital_results.get(key)
	if not result_lbl:
		return
	var v_btn: Button = _vital_buttons.get(key)
	if not v_btn:
		return
	# Cooldown: 1.5s, 2 concurrent. Result appears AFTER delay.
	if not _start_cooldown(v_btn, "vitals", _do_vital_action.bind(key, action_id)):
		return


## Deferred vital action — runs after cooldown completes.
func _do_vital_action(key: String, action_id: int) -> void:
	var result_lbl: Label = _vital_results.get(key)
	if not result_lbl:
		return

	if not _assessment_manager:
		result_lbl.text = "No assessment manager."
		var fallback := _read_vital_from_patient(key)
		if not fallback.is_empty():
			_display_vital_result(key, fallback, result_lbl)
		return

	var result: Dictionary = {}
	if _assessment_manager.has_method("perform_assessment"):
		result = _assessment_manager.perform_assessment(action_id)

	if result.has("error"):
		result_lbl.text = result["error"]
		var tm := _get_theme_medical()
		if tm:
			result_lbl.add_theme_color_override("font_color", tm.c("accent_yellow"))
		return

	if result.is_empty():
		result = _read_vital_from_patient(key)

	_display_vital_result(key, result, result_lbl)

	if _vital_buttons.has(key):
		var tm := _get_theme_medical()
		if tm:
			_vital_buttons[key].add_theme_color_override("font_color", tm.c("accent_green"))

	_check_cpr_visibility()
	assessment_action.emit(key)


func _display_vital_result(key: String, result: Dictionary, result_lbl: Label) -> void:
	var display_text := ""
	var tm := _get_theme_medical()
	var severity_color: Color = tm.c("accent_green") if tm else Color(0.3, 0.9, 0.4)

	match key:
		"check_heart_rate":
			var hr: float = result.get("value", result.get("heart_rate", -1.0))
			if hr >= 0:
				display_text = "HR: %.0f bpm" % hr
				severity_color = _color_for_hr(hr)
		"check_blood_pressure":
			var sys: float = result.get("systolic", result.get("value", -1.0))
			var dia: float = result.get("diastolic", -1.0)
			if sys >= 0:
				display_text = "BP: %.0f/%.0f mmHg" % [sys, dia] if dia >= 0 else "BP: %.0f mmHg" % sys
				severity_color = _color_for_bp(sys)
		"check_spo2":
			var spo2: float = result.get("value", result.get("spo2", -1.0))
			if spo2 >= 0:
				display_text = "SpO2: %.0f%%" % spo2
				severity_color = _color_for_spo2(spo2)
		"check_temperature":
			var temp: float = result.get("value", result.get("temperature", -1.0))
			if temp >= 0:
				display_text = "Temp: %.1f C" % temp
				severity_color = _color_for_temp(temp)
		"check_blood_glucose":
			# AssessmentManager returns "glucose" key
			var bg: float = result.get("glucose", result.get("value", -1.0))
			if bg >= 0:
				display_text = "BGL: %.0f mg/dL" % bg
				severity_color = _color_for_bgl(bg)
		"check_capillary_refill":
			# AssessmentManager returns "refill_seconds" key
			var crt: float = result.get("refill_seconds", result.get("value", -1.0))
			if crt >= 0:
				display_text = "CRT: %.1f sec" % crt
				severity_color = Color(0.3, 0.9, 0.4) if crt <= 2.0 else (Color(0.9, 0.8, 0.2) if crt <= 3.0 else Color(0.9, 0.3, 0.3))
		"check_pupils":
			# AssessmentManager returns left_size, left_reactive, right_size, right_reactive, equal
			if result.has("left_size"):
				var ls: int = result.get("left_size", 4)
				var rs: int = result.get("right_size", 4)
				var lr: bool = result.get("left_reactive", true)
				var rr: bool = result.get("right_reactive", true)
				var eq: bool = result.get("equal", true)
				var react_l := "reactive" if lr else "fixed"
				var react_r := "reactive" if rr else "fixed"
				display_text = "L: %dmm %s  R: %dmm %s%s" % [ls, react_l, rs, react_r, "  ! Unequal" if not eq else ""]
				severity_color = Color(0.9, 0.3, 0.3) if (not lr or not rr or not eq or ls >= 6 or rs >= 6) else Color(0.3, 0.9, 0.4)
			else:
				display_text = "Pupils: assessed"
		"check_skin":
			# AssessmentManager returns color, temperature, moisture, shock_signs
			if result.has("color"):
				var c: String = result.get("color", "NORMAL")
				var t: String = result.get("temperature", "WARM")
				var m: String = result.get("moisture", "DRY")
				var shock: bool = result.get("shock_signs", false)
				display_text = "%s / %s / %s%s" % [c, t, m, "  ! SHOCK SIGNS" if shock else ""]
				severity_color = Color(0.9, 0.3, 0.3) if shock else Color(0.3, 0.9, 0.4)
			else:
				display_text = "Skin: assessed"

	if display_text == "":
		display_text = result.get("description", result.get("text", "Assessed"))

	result_lbl.text = display_text
	result_lbl.add_theme_color_override("font_color", severity_color)


func _read_vital_from_patient(key: String) -> Dictionary:
	if not _patient:
		return {}
	var ms: Node = _patient.get_node_or_null("MedicalStateComponent")
	if not ms:
		return {}
	match key:
		"check_heart_rate":
			var hr = ms.get("heart_rate")
			return {"value": float(hr) if hr != null else -1.0}
		"check_blood_pressure":
			var sys = ms.get("blood_pressure_systolic")
			var dia = ms.get("blood_pressure_diastolic")
			return {"systolic": float(sys) if sys != null else -1.0, "diastolic": float(dia) if dia != null else -1.0}
		"check_spo2":
			var s = ms.get("spo2")
			return {"value": float(s) if s != null else -1.0}
		"check_temperature":
			var t = ms.get("temperature")
			return {"value": float(t) if t != null else -1.0}
		"check_blood_glucose":
			var bg = ms.get("blood_glucose")
			return {"glucose": float(bg) if bg != null else -1.0}
		"check_capillary_refill":
			var crt = ms.get("capillary_refill")
			return {"refill_seconds": float(crt) if crt != null else -1.0}
		"check_pupils":
			return {
				"left_size": ms.get("pupil_left_size") if ms.get("pupil_left_size") != null else 4,
				"right_size": ms.get("pupil_right_size") if ms.get("pupil_right_size") != null else 4,
				"left_reactive": ms.get("pupil_left_reactive") if ms.get("pupil_left_reactive") != null else true,
				"right_reactive": ms.get("pupil_right_reactive") if ms.get("pupil_right_reactive") != null else true,
				"equal": ms.get("pupil_left_size") == ms.get("pupil_right_size"),
			}
		"check_skin":
			return {
				"color": ms.get("skin_color") if ms.get("skin_color") != null else "NORMAL",
				"temperature": ms.get("skin_temperature") if ms.get("skin_temperature") != null else "WARM",
				"moisture": ms.get("skin_moisture") if ms.get("skin_moisture") != null else "DRY",
				"shock_signs": ms.get("skin_color") in ["PALE","CYANOTIC","MOTTLED"] or ms.get("skin_temperature") in ["COOL","COLD"] or ms.get("skin_moisture") == "DIAPHORETIC",
			}
	return {}


# Vital sign colour helpers (ARC-13)

func _severity_green() -> Color:
	var tm := _get_theme_medical()
	return tm.c("accent_green") if tm else Color(0.3, 0.9, 0.4)

func _severity_yellow() -> Color:
	var tm := _get_theme_medical()
	return tm.c("accent_yellow") if tm else Color(0.9, 0.8, 0.2)

func _severity_red() -> Color:
	var tm := _get_theme_medical()
	return tm.c("accent_red") if tm else Color(0.9, 0.3, 0.3)

func _color_for_hr(hr: float) -> Color:
	if hr >= 60.0 and hr <= 100.0:
		return _severity_green()
	elif (hr >= 50.0 and hr < 60.0) or (hr > 100.0 and hr <= 120.0):
		return _severity_yellow()
	return _severity_red()


func _color_for_bp(sys: float) -> Color:
	if sys >= 90.0 and sys <= 139.0:
		return _severity_green()
	elif (sys >= 70.0 and sys < 90.0) or (sys >= 140.0 and sys < 180.0):
		return _severity_yellow()
	return _severity_red()


func _color_for_spo2(spo2: float) -> Color:
	if spo2 >= 95.0:
		return _severity_green()
	elif spo2 >= 90.0:
		return _severity_yellow()
	return _severity_red()


func _color_for_temp(temp: float) -> Color:
	if temp >= 36.1 and temp <= 37.5:
		return _severity_green()
	elif (temp >= 35.0 and temp < 36.1) or (temp > 37.5 and temp <= 38.5):
		return _severity_yellow()
	return _severity_red()


func _color_for_bgl(bgl: float) -> Color:
	if bgl >= 4.0 and bgl <= 8.0:
		return _severity_green()
	elif (bgl >= 3.0 and bgl < 4.0) or (bgl > 8.0 and bgl <= 11.0):
		return _severity_yellow()
	return _severity_red()


# ==============================================================================
# ARC-14: HANDLERS — ECG
# ==============================================================================

func _on_ecg_identify_pressed() -> void:
	if not _patient:
		return

	var medical_state: Node = _patient.get_node_or_null("MedicalStateComponent")
	if not medical_state:
		if _ecg_rhythm_label:
			_ecg_rhythm_label.text = "No medical state data available."
		return

	var rhythm_key: String = ""
	if medical_state.get("ecg_rhythm") != null:
		rhythm_key = str(medical_state.get("ecg_rhythm"))

	if rhythm_key == "":
		if _ecg_rhythm_label:
			_ecg_rhythm_label.text = "No ECG rhythm data on patient."
		return

	var rhythm_display := rhythm_key.replace("_", " ").capitalize()
	var clinical_note := ""
	var rhythm_color := Color(0.9, 0.8, 0.2)  # default yellow

	var critical_shockable := ["VENTRICULAR_FIBRILLATION", "VENTRICULAR_TACHYCARDIA", "VF", "VT"]
	var critical_non_shockable := ["ASYSTOLE", "PEA", "PULSELESS_ELECTRICAL_ACTIVITY"]
	var normal_rhythms := ["NORMAL_SINUS", "NSR", "SINUS_RHYTHM"]

	if rhythm_key in critical_shockable:
		rhythm_color = Color(0.9, 0.2, 0.2)
		clinical_note = "SHOCKABLE -- Defibrillate immediately. CPR between shocks."
	elif rhythm_key in critical_non_shockable:
		rhythm_color = Color(0.6, 0.1, 0.1)
		clinical_note = "NON-SHOCKABLE -- Continue CPR. Identify and treat reversible causes."
	elif rhythm_key in normal_rhythms:
		rhythm_color = Color(0.3, 0.9, 0.4)
		clinical_note = "Normal sinus rhythm identified."
	else:
		clinical_note = "Interpret clinically -- consult guidelines."

	# Try to get detailed data from ECGRhythmManager
	if _ecg_rhythm_manager and _ecg_rhythm_manager.has_method("get_rhythm_data"):
		var rhythm_data: Dictionary = _ecg_rhythm_manager.get_rhythm_data(rhythm_key)
		if rhythm_data.has("display_name"):
			rhythm_display = rhythm_data["display_name"]
		if rhythm_data.has("clinical_note"):
			clinical_note = rhythm_data["clinical_note"]

	if _ecg_rhythm_label:
		_ecg_rhythm_label.text = "%s\n%s" % [rhythm_display, clinical_note]
		_ecg_rhythm_label.add_theme_color_override("font_color", rhythm_color)

	# Always refresh the ECG texture to match the current rhythm (may have changed after treatment)
	if _ecg_panel:
		_ecg_panel.visible = true
	if _ecg_rhythm_manager and _ecg_rhythm_manager.has_method("get_rhythm_texture"):
		var tex = _ecg_rhythm_manager.get_rhythm_texture(rhythm_key)
		if tex and _ecg_texture_rect:
			_ecg_texture_rect.texture = tex
			_ecg_texture_rect.visible = true


# ==============================================================================
# ARC-15: HANDLERS — GCS
# ==============================================================================

func _on_gcs_value_selected(component: String, value: int) -> void:
	_gcs_component_selection[component] = value

	# Un-highlight all buttons in this component, highlight the selected one
	var all_values := {
		"eye":    [4, 3, 2, 1],
		"verbal": [5, 4, 3, 2, 1],
		"motor":  [6, 5, 4, 3, 2, 1],
	}

	if all_values.has(component):
		for v in all_values[component]:
			var btn_key := component + "_" + str(v)
			if _gcs_component_btns.has(btn_key):
				var b: Button = _gcs_component_btns[btn_key]
				if v == value:
					b.add_theme_color_override("font_color", Color(0.3, 0.7, 1.0))
				else:
					if b.has_theme_color_override("font_color"):
						b.remove_theme_color_override("font_color")

	# Compute total when all 3 components are selected
	if _gcs_component_selection.has("eye") and _gcs_component_selection.has("verbal") and _gcs_component_selection.has("motor"):
		var eye_val: int = _gcs_component_selection["eye"]
		var verbal_val: int = _gcs_component_selection["verbal"]
		var motor_val: int = _gcs_component_selection["motor"]
		var total: int = eye_val + verbal_val + motor_val

		var severity_text := ""
		var severity_color := Color(0.3, 0.9, 0.4)

		if total >= 13:
			severity_text = "MILD (13-15)"
			severity_color = Color(0.3, 0.9, 0.4)
		elif total >= 9:
			severity_text = "MODERATE (9-12)"
			severity_color = Color(0.9, 0.8, 0.2)
		else:
			severity_text = "SEVERE (3-8)"
			severity_color = Color(0.9, 0.3, 0.3)

		if _gcs_total_label:
			_gcs_total_label.text = "GCS: %d/15 (E%dV%dM%d)" % [total, eye_val, verbal_val, motor_val]
			_gcs_total_label.add_theme_color_override("font_color", severity_color)

		var severity_display := severity_text
		if total <= 8:
			severity_display += "  ! AIRWAY AT RISK -- Consider advanced airway"
		if _gcs_severity_label:
			_gcs_severity_label.text = severity_display
			_gcs_severity_label.add_theme_color_override("font_color", severity_color)

		# Report to GCS manager if available
		if _gcs_manager and _gcs_manager.has_method("record_gcs"):
			_gcs_manager.record_gcs(_patient, eye_val, verbal_val, motor_val)


func _on_gcs_read_patient() -> void:
	if not _patient:
		return

	var ms: Node = _patient.get_node_or_null("MedicalStateComponent")
	if not ms:
		return

	var eye_val: int = 1
	var verbal_val: int = 1
	var motor_val: int = 1

	if ms.get("gcs_eye") != null:
		eye_val = int(ms.get("gcs_eye"))
	if ms.get("gcs_verbal") != null:
		verbal_val = int(ms.get("gcs_verbal"))
	if ms.get("gcs_motor") != null:
		motor_val = int(ms.get("gcs_motor"))

	# Clamp to valid GCS ranges
	eye_val = clampi(eye_val, 1, 4)
	verbal_val = clampi(verbal_val, 1, 5)
	motor_val = clampi(motor_val, 1, 6)

	# Simulate button presses to trigger highlighting and total calculation
	_on_gcs_value_selected("eye", eye_val)
	_on_gcs_value_selected("verbal", verbal_val)
	_on_gcs_value_selected("motor", motor_val)


# ==============================================================================
# ARC-16: HANDLERS — Secondary Survey
# ==============================================================================

func _on_secondary_region_pressed(region: String) -> void:
	if not _patient:
		return

	var result_lbl: Label = _secondary_results.get(region)
	var region_btn: Button = _secondary_buttons.get(region)
	if not result_lbl or not region_btn:
		return
	# Cooldown: 2s, 1 at a time. Result appears AFTER delay.
	if not _start_cooldown(region_btn, "secondary", _do_secondary_action.bind(region)):
		return
	return  # Action deferred to callback


## Deferred secondary survey action — runs after cooldown completes.
func _do_secondary_action(region: String) -> void:
	if not _patient:
		return
	var result_lbl: Label = _secondary_results.get(region)
	var region_btn: Button = _secondary_buttons.get(region)
	if not result_lbl or not region_btn:
		return

	# Get findings through SecondarySurveyManager.get_region_findings (locale-aware)
	var finding_text := "No abnormalities found."

	if _secondary_survey_manager and _secondary_survey_manager.has_method("get_region_findings"):
		finding_text = _secondary_survey_manager.get_region_findings(_patient, region)

	# Three-tier severity detection from markers in the English source:
	#   ⚠ = RED (life-threatening, immediate action)
	#   ⚡ = YELLOW (significant, needs attention)
	#   No marker = GREEN (normal/negative finding)
	var severity := "green"
	var ms: Node = _patient.get_node_or_null("MedicalStateComponent") if _patient else null
	if ms:
		var en_text: String = str(ms.examination_findings.get(region, ""))
		if "⚠" in en_text:
			severity = "red"
		elif "⚡" in en_text:
			severity = "yellow"

	var tm := _get_theme_medical()
	match severity:
		"red":
			result_lbl.text = "! CRITICAL: " + finding_text
			result_lbl.add_theme_color_override("font_color", tm.c("accent_red") if tm else Color(0.9, 0.3, 0.3))
			region_btn.add_theme_color_override("font_color", tm.c("accent_red") if tm else Color(0.9, 0.3, 0.3))
		"yellow":
			result_lbl.text = "! CAUTION: " + finding_text
			result_lbl.add_theme_color_override("font_color", tm.c("accent_yellow") if tm else Color(0.9, 0.8, 0.2))
			region_btn.add_theme_color_override("font_color", tm.c("accent_yellow") if tm else Color(0.9, 0.8, 0.2))
		_:
			result_lbl.text = finding_text
			result_lbl.add_theme_color_override("font_color", tm.c("accent_green") if tm else Color(0.3, 0.9, 0.4))
			region_btn.add_theme_color_override("font_color", tm.c("accent_green") if tm else Color(0.4, 0.8, 0.4))

	_secondary_completed_count += 1
	if _secondary_counter_label:
		_secondary_counter_label.text = "%d/7" % _secondary_completed_count

	assessment_action.emit("secondary_" + region)


# ==============================================================================
# ARC-17: HANDLERS — Drug Administration
# ==============================================================================

func _on_drug_name_changed(index: int) -> void:
	if not _drug_name_btn or not _drug_route_btn or not _drug_dose_btn:
		return

	_drug_route_btn.clear()
	_drug_dose_btn.clear()

	if index < 0 or index >= _drug_name_btn.get_item_count():
		return

	# Retrieve the drug key stored as metadata during population
	var drug_key = _drug_name_btn.get_item_metadata(index)
	if drug_key == null or not _current_drug_data.has(str(drug_key)):
		return

	var drug: Dictionary = _current_drug_data[str(drug_key)]

	# Populate routes from drugs.json "valid_routes" field
	var routes: Array = drug.get("valid_routes", [])
	if routes.is_empty():
		_drug_route_btn.add_item("IV")
		_drug_route_btn.add_item("IM")
		_drug_route_btn.add_item("PO")
	else:
		for route in routes:
			_drug_route_btn.add_item(str(route))

	# Populate doses from drugs.json "dose_options" field
	var doses: Array = drug.get("dose_options", [])
	if doses.is_empty():
		_drug_dose_btn.add_item("Standard")
	else:
		for dose in doses:
			_drug_dose_btn.add_item(str(dose))


## Check if CPR button should become visible after an assessment reveals cardiac arrest.
## Called after each exam/vital assessment action.
func _check_cpr_visibility() -> void:
	if not _cpr_button or not _patient:
		return
	if _cpr_active:
		return  # Already performing CPR
	var medical: Node = _patient.get_node_or_null("MedicalStateComponent")
	if not medical or medical.current_state != medical.PatientState.CARDIAC_ARREST:
		_cpr_button.visible = false
		return
	# Only show if the player has assessed pulse or heart rate (discovered the arrest)
	var assessed: Dictionary = {}
	if _patient.has_meta("assessed_conditions"):
		assessed = _patient.get_meta("assessed_conditions")
	var pulse_checked := assessed.has("assess_pulse") or assessed.has("check_pulse")
	var hr_checked := assessed.has("assess_heart_rate") or assessed.has("check_heart_rate")
	var consciousness_checked := assessed.has("assess_consciousness") or assessed.has("check_consciousness")
	if pulse_checked or hr_checked or consciousness_checked:
		_cpr_button.visible = true
	else:
		_cpr_button.visible = false


func _on_cpr_pressed() -> void:
	if not _patient:
		return
	var medical: Node = _patient.get_node_or_null("MedicalStateComponent")
	if not medical or medical.current_state != medical.PatientState.CARDIAC_ARREST:
		return

	_cpr_active = true
	medical.apply_treatment("cpr")

	# Update button to show CPR is active
	if _cpr_button:
		_cpr_button.text = "CPR In Progress"
		_cpr_button.disabled = true
	if _cpr_status_label:
		_cpr_status_label.visible = true
		var rhythm: String = medical.ecg_rhythm if "ecg_rhythm" in medical else ""
		var shockable := rhythm in ["VENTRICULAR_FIBRILLATION", "VENTRICULAR_TACHYCARDIA"]
		if shockable:
			_cpr_status_label.text = "Rhythm is shockable (%s) -- deploy AED for defibrillation!" % rhythm.replace("_", " ").capitalize()
			_cpr_status_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.2))
		else:
			_cpr_status_label.text = "Rhythm is non-shockable (%s) -- continue CPR. AED will not help." % rhythm.replace("_", " ").capitalize()
			_cpr_status_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4))

	# Log to telemetry
	var telemetry: Node = _player.get_node_or_null("TelemetryEmitter") if _player else null
	if telemetry and telemetry.has_method("emit_action"):
		telemetry.emit_action("cpr", _patient.name, {"rhythm": medical.ecg_rhythm if "ecg_rhythm" in medical else ""})

	assessment_action.emit("cpr")


func _on_administer_drug_pressed() -> void:
	if not _drug_name_btn or not _drug_route_btn or not _drug_dose_btn:
		return
	if not _patient:
		return
	# Cooldown: 5s, 1 at a time — with circular progress
	if not _drug_admin_btn:
		return
	if not _start_cooldown(_drug_admin_btn, "drug", _do_drug_admin):
		return
	return  # Deferred to callback


## Deferred drug administration — runs after 5s cooldown.
func _do_drug_admin() -> void:
	if not _drug_name_btn or not _drug_route_btn or not _drug_dose_btn:
		return
	if not _patient:
		return

	var drug_display: String = _drug_name_btn.get_item_text(_drug_name_btn.selected) if _drug_name_btn.get_item_count() > 0 else ""
	var drug_key = _drug_name_btn.get_item_metadata(_drug_name_btn.selected) if _drug_name_btn.get_item_count() > 0 else ""
	var route: String = _drug_route_btn.get_item_text(_drug_route_btn.selected) if _drug_route_btn.get_item_count() > 0 else ""
	var dose_text: String = _drug_dose_btn.get_item_text(_drug_dose_btn.selected) if _drug_dose_btn.get_item_count() > 0 else ""

	if drug_display == "" or drug_key == null:
		if _drug_feedback_label:
			_drug_feedback_label.text = "No drug selected."
			_drug_feedback_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4))
		return

	# Deplete from bag if it's a consumable bag item
	if _bag_tier_manager and _bag_tier_manager.has_method("deploy_item"):
		var bag_key := str(drug_key)
		if _bag_tier_manager.is_available(bag_key):
			_bag_tier_manager.deploy_item(_patient, bag_key)

	var result_text := ""
	var success := false

	if _drug_admin_manager and _drug_admin_manager.has_method("administer"):
		# administer(patient, drug_key, dose_string, route) — 4 args
		var admin_result: Dictionary = _drug_admin_manager.administer(_patient, str(drug_key), dose_text, route)
		success = admin_result.get("success", false)
		result_text = admin_result.get("message", "Administered." if success else "Administration failed.")
	else:
		# Simulate basic administration
		success = true
		result_text = "Administered: %s %s via %s" % [dose_text, drug_display, route]

	if _drug_feedback_label:
		_drug_feedback_label.text = result_text
		_drug_feedback_label.add_theme_color_override("font_color",
			Color(0.3, 0.9, 0.4) if success else Color(0.9, 0.3, 0.3))

	_add_drug_log_entry(drug_display, route, dose_text, success)


func _add_drug_log_entry(drug_name: String, route: String, dose: String, success: bool) -> void:
	if not _drug_log_vbox:
		return

	# Keep last 5 entries — remove oldest when at capacity
	while _drug_log_vbox.get_child_count() >= 5:
		_drug_log_vbox.get_child(0).queue_free()

	var tm := _get_theme_medical()

	var entry_lbl := Label.new()
	var status_icon := "[OK]" if success else "[X]"
	entry_lbl.text = "%s %s %s via %s" % [status_icon, dose, drug_name, route]
	if tm:
		tm.style_label(entry_lbl, "caption", "accent_green" if success else "accent_red")
	else:
		entry_lbl.add_theme_font_size_override("font_size", 12)
		entry_lbl.add_theme_color_override("font_color",
			Color(0.3, 0.9, 0.4) if success else Color(0.9, 0.3, 0.3))
	_drug_log_vbox.add_child(entry_lbl)


func _on_drug_administered_signal(drug_name: String, route: String, dose_amount: float, dose_unit: String, success: bool) -> void:
	_add_drug_log_entry(drug_name, route, "%.1f %s" % [dose_amount, dose_unit], success)


# ==============================================================================
# ARC-18: HANDLERS — Medical Bag
# ==============================================================================

func _on_bag_item_deploy(item_type: String, _item_name: String, qty_label: Label, deploy_btn: Button) -> void:
	if not _patient:
		return

	# Intercept TRIAGE_TAGS — show color picker instead of direct deploy
	if item_type == "TRIAGE_TAGS":
		_show_triage_color_picker(qty_label, deploy_btn)
		return

	var current_qty: int = 0
	if qty_label and qty_label.text.begins_with("x"):
		current_qty = int(qty_label.text.substr(1))

	var success := false

	if _bag_tier_manager and _bag_tier_manager.has_method("deploy_item"):
		var result: Dictionary = _bag_tier_manager.deploy_item(_patient, item_type)
		success = result.get("success", false)
		current_qty = result.get("remaining", maxi(0, current_qty - 1))
	else:
		success = true
		current_qty = maxi(0, current_qty - 1)

	if success:
		if qty_label:
			qty_label.text = "x%d" % current_qty
		if current_qty <= 0 and deploy_btn:
			deploy_btn.disabled = true

		equipment_used.emit(item_type, _patient)

		# Mirror to equipment buttons via key mapping
		var equip_key: String = BAG_TO_EQUIP_KEY.get(item_type, item_type.to_lower())
		if _equipment_buttons.has(equip_key) and equip_key not in _applied_equipment:
			_applied_equipment.append(equip_key)
			var eq_btn: Button = _equipment_buttons[equip_key]
			eq_btn.text = eq_btn.text.trim_suffix(" ✓") + " ✓"
			eq_btn.disabled = true


## Show a triage color picker popup when deploying triage tags from the bag.
func _show_triage_color_picker(qty_label: Label, deploy_btn: Button) -> void:
	var tm := _get_theme_medical()
	var popup := PopupPanel.new()
	popup.title = "Select Triage Tag Colour"
	add_child(popup)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 8)
	popup.add_child(vbox)

	var title_lbl := Label.new()
	title_lbl.text = "Assign Triage Tag:"
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	if tm:
		tm.style_label(title_lbl, "subtitle", "text_primary")
	else:
		title_lbl.add_theme_font_size_override("font_size", 16)
	vbox.add_child(title_lbl)

	var colours := {
		"RED": {"label": "Immediate", "color": Color(1.0, 0.2, 0.2)},
		"YELLOW": {"label": "Delayed", "color": Color(1.0, 0.9, 0.1)},
		"GREEN": {"label": "Minor", "color": Color(0.2, 0.9, 0.2)},
		"BLACK": {"label": "Deceased / Expectant", "color": Color(0.9, 0.9, 0.9)},
	}

	for tag_name in colours:
		var tag_info: Dictionary = colours[tag_name]
		var btn := Button.new()
		btn.text = "%s -- %s" % [tag_name, tag_info["label"]]
		btn.custom_minimum_size = Vector2(220, 48)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_triage_color_selected.bind(tag_name, qty_label, deploy_btn, popup))
		if tm:
			tm.style_button(btn, "large")
			# Color-coded triage card styling
			var triage_style: StyleBoxFlat = tm.make_card()
			triage_style.bg_color = tag_info["color"].darkened(0.6)
			triage_style.border_color = tag_info["color"]
			triage_style.border_width_left = 4
			btn.add_theme_stylebox_override("normal", triage_style)
			btn.add_theme_color_override("font_color", tag_info["color"])
		else:
			btn.add_theme_color_override("font_color", tag_info["color"])
		vbox.add_child(btn)

	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.custom_minimum_size = Vector2(220, 32)
	cancel_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.pressed.connect(func(): popup.queue_free())
	if tm:
		tm.style_button(cancel_btn, "small")
	vbox.add_child(cancel_btn)

	popup.popup_centered(Vector2(260, 320))


func _on_triage_color_selected(tag_name: String, qty_label: Label, deploy_btn: Button, popup: PopupPanel) -> void:
	popup.queue_free()

	# Deplete triage tag from bag
	var current_qty: int = 0
	if qty_label and qty_label.text.begins_with("x"):
		current_qty = int(qty_label.text.substr(1))

	if _bag_tier_manager and _bag_tier_manager.has_method("deploy_item"):
		var result: Dictionary = _bag_tier_manager.deploy_item(_patient, "TRIAGE_TAGS")
		current_qty = result.get("remaining", maxi(0, current_qty - 1))

	if qty_label:
		qty_label.text = "x%d" % current_qty
	if current_qty <= 0 and deploy_btn:
		deploy_btn.disabled = true

	# Assign triage tag via TriageSystem if available
	# Convert string tag name to TriageTag enum int (GREEN=0, YELLOW=1, RED=2, BLACK=3)
	var triage_sys: Node = get_node_or_null("/root/TriageSystem")
	if triage_sys and triage_sys.has_method("assign_tag"):
		var tag_int_map := {"GREEN": 0, "YELLOW": 1, "RED": 2, "BLACK": 3}
		var tag_int: int = tag_int_map.get(tag_name, 0)
		triage_sys.assign_tag(_patient, tag_int)

	if _drug_feedback_label:
		var color_map := {"RED": Color(1, 0.2, 0.2), "YELLOW": Color(1, 0.9, 0.1), "GREEN": Color(0.2, 0.9, 0.2), "BLACK": Color(0.9, 0.9, 0.9)}
		_drug_feedback_label.text = "Triage tag assigned: %s" % tag_name
		_drug_feedback_label.add_theme_color_override("font_color", color_map.get(tag_name, Color.WHITE))


## Direct triage tag assignment from standalone buttons (not bag contents).
func _on_triage_direct_pressed(tag_name: String) -> void:
	if not _patient:
		return
	var triage_sys: Node = get_node_or_null("/root/TriageSystem")
	if triage_sys and triage_sys.has_method("assign_tag"):
		var tag_int_map := {"GREEN": 0, "YELLOW": 1, "RED": 2, "BLACK": 3}
		var tag_int: int = tag_int_map.get(tag_name, 0)
		triage_sys.assign_tag(_patient, tag_int)
	var color_map := {"RED": Color(1, 0.2, 0.2), "YELLOW": Color(1, 0.9, 0.1), "GREEN": Color(0.2, 0.9, 0.2), "BLACK": Color(0.9, 0.9, 0.9)}
	if _triage_feedback_label:
		_triage_feedback_label.text = "Triage tag assigned: %s" % tag_name
		_triage_feedback_label.add_theme_color_override("font_color", color_map.get(tag_name, Color.WHITE))


# ==============================================================================
# HANDLERS — Stabilize tab (equipment)
# ==============================================================================

func _on_equipment_pressed(equip_type: String) -> void:
	if equip_type in _applied_equipment:
		return
	# Cooldown: 3s, 2 concurrent. Deploy happens AFTER delay.
	var eq_btn: Button = _equipment_buttons.get(equip_type)
	if not eq_btn:
		return
	if not _start_cooldown(eq_btn, "equipment", _do_equipment_deploy.bind(equip_type)):
		return
	return  # Deferred to callback


## Deferred equipment deploy — runs after cooldown completes.
func _do_equipment_deploy(equip_type: String) -> void:
	if equip_type in _applied_equipment:
		return

	# Deplete from bag manager via key mapping
	var bag_key: String = EQUIP_TO_BAG_KEY.get(equip_type, equip_type.to_upper())
	if _bag_tier_manager and _bag_tier_manager.has_method("deploy_item") and _patient:
		if _bag_tier_manager.is_available(bag_key):
			var result: Dictionary = _bag_tier_manager.deploy_item(_patient, bag_key)
			if not result.get("success", false):
				# Item unavailable — show feedback
				if _drug_feedback_label:
					_drug_feedback_label.text = result.get("message", "Item unavailable in bag.")
					_drug_feedback_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4))
				return
		else:
			if _drug_feedback_label:
				_drug_feedback_label.text = "%s not available in bag." % equip_type.capitalize()
				_drug_feedback_label.add_theme_color_override("font_color", Color(0.9, 0.4, 0.4))
			return

	_applied_equipment.append(equip_type)
	if _equipment_buttons.has(equip_type):
		var btn: Button = _equipment_buttons[equip_type]
		btn.text = btn.text.trim_suffix(" ✓") + " ✓"
		btn.disabled = true

	# Sync bag contents UI — refresh to show updated quantities
	_populate_bag_section()

	equipment_used.emit(equip_type, _patient)


# ==============================================================================
# HANDLERS — Differential tab
# ==============================================================================

func _on_diagnosis_button_pressed(diagnosis: String) -> void:
	if _diagnosis_submitted:
		return

	if diagnosis in _selected_diagnoses:
		# Deselect
		_selected_diagnoses.erase(diagnosis)
		for btn in _diagnosis_buttons:
			if btn.text == diagnosis:
				if btn.has_theme_color_override("font_color"):
					btn.remove_theme_color_override("font_color")
	else:
		if _selected_diagnoses.size() >= 3:
			return
		_selected_diagnoses.append(diagnosis)
		for btn in _diagnosis_buttons:
			if btn.text == diagnosis:
				btn.add_theme_color_override("font_color", Color(0.3, 0.9, 0.5))

	_update_diagnosis_rank_label()

	if _submit_diagnosis_btn:
		_submit_diagnosis_btn.disabled = _selected_diagnoses.is_empty()


func _update_diagnosis_rank_label() -> void:
	if not _diagnosis_rank_label:
		return
	if _selected_diagnoses.is_empty():
		_diagnosis_rank_label.text = "Selected: (none)"
	else:
		var parts := PackedStringArray()
		for i in range(_selected_diagnoses.size()):
			parts.append("%d. %s" % [i + 1, _selected_diagnoses[i]])
		_diagnosis_rank_label.text = "Selected: " + ", ".join(parts)


func _on_submit_diagnosis_pressed() -> void:
	if _selected_diagnoses.is_empty():
		return
	_diagnosis_submitted = true
	for btn in _diagnosis_buttons:
		btn.disabled = true
	if _submit_diagnosis_btn:
		_submit_diagnosis_btn.disabled = true
		_submit_diagnosis_btn.text = "Diagnosis Submitted"
	for diag in _selected_diagnoses:
		diagnosis_selected.emit(diag)

	# Score against correct diagnoses — per-patient DDx (preferred) with scenario-level fallback
	var correct_list: Array = []
	if _patient and _patient.has_meta("correct_diagnosis"):
		correct_list = _patient.get_meta("correct_diagnosis")
	if correct_list.is_empty():
		var scenario_mgr: Node = get_node_or_null("/root/ScenarioManager")
		if scenario_mgr and scenario_mgr.current_scenario:
			correct_list = scenario_mgr.current_scenario.get("correct_diagnosis", [])

	# Calculate match score
	var matches: int = 0
	var matched_names: Array[String] = []
	for selected in _selected_diagnoses:
		for correct in correct_list:
			if selected.to_lower() == str(correct).to_lower():
				matches += 1
				matched_names.append(selected)
				break

	# Store diagnosis result on patient metadata for debrief
	if _patient:
		_patient.set_meta("player_diagnoses", _selected_diagnoses.duplicate())
		_patient.set_meta("correct_diagnoses", correct_list)
		_patient.set_meta("diagnosis_matches", matches)

	# Log to telemetry with proper timestamp and patient target
	var telemetry: Node = get_node_or_null("/root/TelemetryCollector")
	if telemetry and telemetry.has_method("record_event"):
		var ts: float = 0.0
		if telemetry.get("_session_start_msec") != null and telemetry._session_start_msec > 0:
			ts = (Time.get_ticks_msec() - telemetry._session_start_msec) / 1000.0
		var patient_name: String = ""
		if _patient and "persona" in _patient and _patient.persona:
			patient_name = _patient.persona.patient_name
		telemetry.record_event({
			"type": "diagnosis_submitted",
			"target": patient_name,
			"timestamp": ts,
			"player_position": {"x": 0, "y": 0, "z": 0},
			"details": {
				"diagnoses": _selected_diagnoses.duplicate(),
				"correct": correct_list,
				"matches": matches,
			},
		})

	# Show scoring feedback
	var score_pct: int = 0
	if not correct_list.is_empty():
		score_pct = int(float(matches) / float(correct_list.size()) * 100.0)

	# Build feedback label
	var feedback_text := ""
	if matches == _selected_diagnoses.size() and matches == correct_list.size():
		feedback_text = "PERFECT -- All diagnoses correct!"
	elif matches > 0:
		feedback_text = "%d/%d correct (%d%%)" % [matches, correct_list.size(), score_pct]
	else:
		feedback_text = "No correct diagnoses. Correct: %s" % ", ".join(PackedStringArray(correct_list))

	# Color matched buttons green, missed correct ones orange
	var _tm_diag2 := _get_theme_medical()
	for btn in _diagnosis_buttons:
		if btn.text in matched_names:
			btn.add_theme_color_override("font_color", _tm_diag2.c("accent_green") if _tm_diag2 else Color(0.2, 1.0, 0.3))
		elif btn.text in correct_list:
			btn.add_theme_color_override("font_color", _tm_diag2.c("accent_yellow") if _tm_diag2 else Color(1.0, 0.6, 0.1))

	if _diagnosis_rank_label:
		_diagnosis_rank_label.text = feedback_text
		var _tm_fb := _get_theme_medical()
		var feedback_color: Color = (_tm_fb.c("accent_green") if _tm_fb else Color(0.2, 1.0, 0.3)) if score_pct >= 80 else ((_tm_fb.c("accent_yellow") if _tm_fb else Color(1.0, 0.85, 0.2)) if score_pct >= 40 else (_tm_fb.c("accent_red") if _tm_fb else Color(1.0, 0.3, 0.3)))
		_diagnosis_rank_label.add_theme_color_override("font_color", feedback_color)

	# Auto-close UI and end scenario after a short delay
	var timer := get_tree().create_timer(3.0)
	timer.timeout.connect(_on_diagnosis_timeout)


func _on_diagnosis_timeout() -> void:
	close_ui()
	# Only end scenario if ALL patients in the scenario have been diagnosed,
	# or if it's a single-patient scenario. Multi-patient scenarios continue.
	var scenario_mgr: Node = get_node_or_null("/root/ScenarioManager")
	if not scenario_mgr:
		return

	var patient_defs: Array = scenario_mgr.current_scenario.get("patients", [])
	var total_patients: int = patient_defs.size()

	if total_patients <= 1:
		# Single-patient scenario — end immediately
		scenario_mgr.end_scenario()
		return

	# Multi-patient: count how many patients have been diagnosed
	var diagnosed_count: int = 0
	var all_patients := get_tree().get_nodes_in_group("patients")
	for p in all_patients:
		if p.has_meta("player_diagnoses") and not (p.get_meta("player_diagnoses") as Array).is_empty():
			diagnosed_count += 1

	if diagnosed_count >= total_patients:
		scenario_mgr.end_scenario()


# ==============================================================================
# OLLAMA / AI helpers
# ==============================================================================

func _setup_ollama_context() -> void:
	if not _dialogue_client or not _patient:
		return

	var persona_data := {}
	var medical_data := {}

	if "persona" in _patient and _patient.persona:
		var p: PatientPersona = _patient.persona
		persona_data = {
			"name": p.patient_name,
			"age": p.age,
			"consciousness_level": p.consciousness_level,
			"pain_level": p.pain_level,
			"panic_level": p.panic_level,
		}
		if p.has_method("get_all_history"):
			persona_data["history"] = p.get_all_history()

	var medical_state: Node = _patient.get_node_or_null("MedicalStateComponent")
	if medical_state:
		medical_data = {
			"airway_status": medical_state.airway_status,
			"breathing_rate": medical_state.breathing_rate,
			"pulse_present": medical_state.pulse_present,
			"bleeding_severity": medical_state.bleeding_severity,
		}

	if _dialogue_client.has_method("set_patient_context"):
		_dialogue_client.set_patient_context(persona_data, medical_data)


func _get_sample_question(category: String) -> String:
	match category:
		"signs_symptoms":  return "Can you tell me what symptoms you're experiencing right now?"
		"allergies":       return "Do you have any allergies -- medications, foods, or environmental?"
		"medications":     return "Are you currently taking any medications or supplements?"
		"past_history":    return "Do you have any significant past medical history or conditions?"
		"last_oral_intake": return "When did you last eat or drink anything?"
		"events":          return "Can you walk me through what happened leading up to this?"
		"opqrst":          return "Can you describe your pain -- where is it, when did it start, does anything make it better or worse?"
	return "Can you tell me more about how you're feeling?"


func _get_scripted_response(category: String) -> String:
	# Read per-patient SAMPLE data from PatientPersona (loaded from scenario JSON).
	# Only falls back to generic text if persona has no data for this category.
	if _patient and "persona" in _patient and _patient.persona:
		var persona: PatientPersona = _patient.persona
		var category_map := {
			"signs_symptoms": "symptoms",
			"allergies": "allergies",
			"medications": "medications",
			"past_history": "past_history",
			"last_oral_intake": "last_meal",
			"events": "events",
			"opqrst": "opqrst",
		}
		var persona_category: String = category_map.get(category, "")
		if persona_category != "":
			var history_dict: Dictionary = {}
			match persona_category:
				"symptoms": history_dict = persona.history_symptoms
				"allergies": history_dict = persona.history_allergies
				"medications": history_dict = persona.history_medications
				"past_history": history_dict = persona.history_past
				"last_meal": history_dict = persona.history_last_meal
				"events": history_dict = persona.history_events
				"opqrst": history_dict = persona.history_opqrst
			if not history_dict.is_empty():
				# Concatenate all responses in the category into a natural reply
				var parts: PackedStringArray = []
				for key in history_dict:
					var val: String = str(history_dict[key])
					if val != "":
						parts.append(val)
				if parts.size() > 0:
					return " ".join(parts)
	# Last resort generic fallback (should rarely hit if JSON has SAMPLE data)
	match category:
		"signs_symptoms":  return "I'm not feeling well..."
		"allergies":       return "I don't have any allergies that I know of."
		"medications":     return "I don't take any regular medication."
		"past_history":    return "Nothing significant."
		"last_oral_intake": return "I ate a while ago..."
		"events":          return "I'm not sure what happened..."
		"opqrst":          return "It hurts..."
	return "..."


# ==============================================================================
# DRSABCDE patient-specific findings builder
# ==============================================================================

## Builds a patient-specific finding dict for DRSABCDE primary survey steps.
## Map UI exam action names to protocol-standard telemetry event names.
func _map_exam_to_telemetry(action_name: String) -> String:
	match action_name:
		"check_danger":
			return "scene_safety_check"
		"check_response":
			return "assess_consciousness"
		"send_help":
			return "call_for_help"
		"check_airway":
			return "assess_airway"
		"check_breathing":
			return "assess_breathing"
		"check_circulation":
			return "assess_pulse"
		"check_disability":
			return "assess_disability"
		"check_exposure":
			return "assess_exposure"
	return ""


## AssessmentManager only handles vital sign enums — DRSABCDE steps (check_danger,
## check_response, check_airway, check_breathing, check_circulation, check_disability,
## check_exposure) are resolved here from MedicalStateComponent and PatientPersona.
func _build_drsabcde_finding(action_name: String) -> Dictionary:
	var ms: Node = null
	var persona = null
	if _patient:
		ms = _patient.get_node_or_null("MedicalStateComponent")
		if _patient.get("persona") != null:
			persona = _patient.persona

	# Bilingual status words — medical values stay universal, labels translate
	var _safe := tr("RESULT_SAFE") if tr("RESULT_SAFE") != "RESULT_SAFE" else "Safe"
	var _assessed := tr("RESULT_ASSESSED") if tr("RESULT_ASSESSED") != "RESULT_ASSESSED" else "Assessed"
	var _alerted := tr("RESULT_ALERTED") if tr("RESULT_ALERTED") != "RESULT_ALERTED" else "Alerted"
	var _present := tr("RESULT_PRESENT") if tr("RESULT_PRESENT") != "RESULT_PRESENT" else "PRESENT"
	var _absent := tr("RESULT_ABSENT") if tr("RESULT_ABSENT") != "RESULT_ABSENT" else "ABSENT"
	var _normal := tr("RESULT_NORMAL") if tr("RESULT_NORMAL") != "RESULT_NORMAL" else "NORMAL"
	var _abnormal := tr("RESULT_ABNORMAL") if tr("RESULT_ABNORMAL") != "RESULT_ABNORMAL" else "ABNORMAL"
	var _none := tr("RESULT_NONE") if tr("RESULT_NONE") != "RESULT_NONE" else "None"
	var _minor := tr("RESULT_MINOR") if tr("RESULT_MINOR") != "RESULT_MINOR" else "Minor"
	var _moderate := tr("RESULT_MODERATE") if tr("RESULT_MODERATE") != "RESULT_MODERATE" else "Moderate"
	var _severe := tr("RESULT_SEVERE") if tr("RESULT_SEVERE") != "RESULT_SEVERE" else "Severe"
	var _proceed_secondary := tr("RESULT_PROCEED_SECONDARY") if tr("RESULT_PROCEED_SECONDARY") != "RESULT_PROCEED_SECONDARY" else "Proceed with secondary survey"

	match action_name:
		"check_danger":
			return {"description": "%s: %s — %s" % [tr("EXAM_DANGER"), _safe, _assessed]}

		"check_response":
			var cl := "ALERT"
			if persona and persona.get("consciousness_level") != null:
				cl = str(persona.consciousness_level)
			return {"description": "%s: %s" % [tr("EXAM_RESPONSE"), cl]}

		"send_help":
			return {"description": "%s: %s" % [tr("EXAM_SEND_HELP"), _alerted]}

		"check_airway":
			if ms and ms.get("airway_status") != null:
				var status: String = str(ms.airway_status)
				return {"description": "%s: %s" % [tr("EXAM_AIRWAY"), status]}
			return {"description": "%s: %s" % [tr("EXAM_AIRWAY"), _assessed]}

		"check_breathing":
			if ms and ms.get("breathing_rate") != null:
				var rr: float = float(ms.breathing_rate)
				var status: String
				if rr <= 0.0:
					status = _absent
				elif rr < 12.0 or rr > 20.0:
					status = _abnormal
				else:
					status = _normal
				return {"description": "%s: RR %.0f/min — %s" % [tr("EXAM_BREATHING"), rr, status]}
			return {"description": "%s: %s" % [tr("EXAM_BREATHING"), _assessed]}

		"check_circulation":
			if ms:
				var pulse := _present
				if ms.get("pulse_present") != null and not bool(ms.pulse_present):
					pulse = _absent
				var bleed := 0
				if ms.get("bleeding_severity") != null:
					bleed = int(ms.bleeding_severity)
				var bleed_text := _none if bleed == 0 else (_minor if bleed == 1 else (_moderate if bleed == 2 else _severe))
				return {"description": "%s: Pulse %s — Bleeding: %s" % [tr("EXAM_CIRCULATION"), pulse, bleed_text]}
			return {"description": "%s: %s" % [tr("EXAM_CIRCULATION"), _assessed]}

		"check_disability":
			if ms and ms.get("gcs_eye") != null:
				var eye := int(ms.gcs_eye)
				var verbal := int(ms.gcs_verbal)
				var motor := int(ms.gcs_motor)
				var total := eye + verbal + motor
				var avpu := "ALERT"
				if total <= 8:
					avpu = "UNRESPONSIVE"
				elif total <= 12:
					avpu = "VOICE"
				elif total <= 14:
					avpu = "PAIN"
				var pupils_txt := ""
				if ms.get("pupil_left_reactive") != null and ms.get("pupil_right_reactive") != null:
					var lr: bool = bool(ms.pupil_left_reactive)
					var rr_p: bool = bool(ms.pupil_right_reactive)
					var ls: int = int(ms.pupil_left_size) if ms.get("pupil_left_size") != null else 4
					var rs: int = int(ms.pupil_right_size) if ms.get("pupil_right_size") != null else 4
					pupils_txt = " | Pupils: L%dmm%s R%dmm%s" % [
						ls, ("" if lr else " fixed"),
						rs, ("" if rr_p else " fixed"),
					]
				return {"description": "%s: GCS %d/15 (E%dV%dM%d) — AVPU: %s%s" % [tr("EXAM_DISABILITY"), total, eye, verbal, motor, avpu, pupils_txt]}
			if persona and persona.get("consciousness_level") != null:
				return {"description": "%s: AVPU %s" % [tr("EXAM_DISABILITY"), str(persona.consciousness_level)]}
			return {"description": "%s: %s" % [tr("EXAM_DISABILITY"), _assessed]}

		"check_exposure":
			return {"description": "%s: %s" % [tr("EXAM_EXPOSURE"), _proceed_secondary]}

	return {}


# ==============================================================================
# ASSESSMENT result formatter
# ==============================================================================

func _format_assessment_result(result: Dictionary, action_name: String) -> String:
	if result.is_empty():
		# Fallback messages if no manager
		match action_name:
			"check_danger":     return "Scene assessed -- no immediate danger."
			"check_response":   return "Response level checked."
			"send_help":        return "Help requested."
			"check_airway":     return "Airway assessed."
			"check_breathing":  return "Breathing assessed."
			"check_circulation": return "Circulation checked."
			"check_disability": return "Disability (AVPU) assessed."
			"check_exposure":   return "Patient exposed and examined."
		return "Assessed."

	if result.has("description"):
		return str(result["description"])
	if result.has("text"):
		return str(result["text"])
	if result.has("finding"):
		return str(result["finding"])
	return "Assessed."


# ==============================================================================
# DATA LOADING — ARC-17 & ARC-18
# ==============================================================================

func _load_drugs_json() -> void:
	var path := "res://data/drugs.json"
	if not FileAccess.file_exists(path):
		_current_drug_data = {}
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		_current_drug_data = {}
		return
	var content := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(content)
	if err != OK:
		_current_drug_data = {}
		return
	var parsed = json.get_data()
	if parsed is Dictionary:
		_current_drug_data = parsed
	else:
		_current_drug_data = {}


func _load_bag_json() -> void:
	var path := "res://data/medical_bag_tiers.json"
	if not FileAccess.file_exists(path):
		_current_bag_data = {}
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		_current_bag_data = {}
		return
	var content := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(content)
	if err != OK:
		_current_bag_data = {}
		return
	var parsed = json.get_data()
	if parsed is Dictionary:
		_current_bag_data = parsed
	else:
		_current_bag_data = {}
