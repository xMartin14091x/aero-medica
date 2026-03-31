## HUDController — Wires gameplay managers to UI elements.
## InteractionManager → InteractionPrompt, AssessmentManager → ActionMenu,
## TriageSystem → TriageTagVisual on patients. Includes pause menu.
extends CanvasLayer

## UI element references.
@onready var interaction_prompt: Control = $InteractionPrompt
@onready var action_menu: Control = $ActionMenu

## Player and manager references.
var _player: Node = null
var _interaction_mgr: Node = null
var _assessment_mgr: Node = null

## Pause menu.
var _paused: bool = false
var _pause_overlay: Control = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Capture mouse immediately so PlayerController's MOUSE_MODE guard allows movement.
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_build_pause_overlay()
	_wire_managers.call_deferred()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		# Don't pause if the PatientInteractionUI is open — let it close first
		var interaction_ui: Control = get_node_or_null("PatientInteractionUI")
		if interaction_ui and interaction_ui.visible:
			return
		_toggle_pause()


func _wire_managers() -> void:
	# Wait one frame for scene to be fully ready
	await get_tree().process_frame

	_player = _find_player()
	if _player == null:
		push_warning("HUDController: Player not found.")
		return

	# Find Syndicate's managers on the Player node
	_interaction_mgr = _player.get_node_or_null("InteractionManager")
	_assessment_mgr = _player.get_node_or_null("AssessmentManager")

	# Wire InteractionManager → InteractionPrompt
	if _interaction_mgr:
		_interaction_mgr.interaction_target_changed.connect(_on_target_changed)
	else:
		push_warning("HUDController: InteractionManager not found on Player.")

	# Wire AssessmentManager → ActionMenu
	if _assessment_mgr:
		_assessment_mgr.assessment_started.connect(_on_assessment_started)
		_assessment_mgr.assessment_ended.connect(_on_assessment_ended)
		# Wire ActionMenu selection back to AssessmentManager
		action_menu.action_selected.connect(_on_action_selected)
	else:
		push_warning("HUDController: AssessmentManager not found on Player.")

	# Wire TriageSystem → TriageTagVisual on patients
	_wire_triage_system()


## InteractionManager.interaction_target_changed(old_target, new_target) → update prompt.
func _on_target_changed(old_target: Node, new_target: Node) -> void:
	# Hide prompt when action menu or patient interaction UI is open
	if action_menu.visible:
		return
	var interaction_ui: Control = get_node_or_null("PatientInteractionUI")
	if interaction_ui and interaction_ui.visible:
		return
	interaction_prompt.on_target_changed(new_target)


## AssessmentManager.assessment_started(patient) → open action menu.
## NOTE: With the new PatientInteractionUI, assessment is managed inside the UI.
## This handler is kept for backwards compatibility if the old ActionMenu is still in use.
func _on_assessment_started(patient: Node) -> void:
	# Check if PatientInteractionUI is handling this instead
	var interaction_ui: Control = get_node_or_null("PatientInteractionUI")
	if interaction_ui and interaction_ui.visible:
		return  # PatientInteractionUI is handling assessment
	interaction_prompt.on_target_changed(null)
	action_menu.open_menu(patient)


## AssessmentManager.assessment_ended(patient) → close action menu.
func _on_assessment_ended(_patient: Node) -> void:
	action_menu.close_menu()
	# Restore prompt if there's still a target in range
	if _interaction_mgr and _interaction_mgr.current_target:
		var interaction_ui: Control = get_node_or_null("PatientInteractionUI")
		if interaction_ui and interaction_ui.visible:
			return  # PatientInteractionUI still open
		interaction_prompt.on_target_changed(_interaction_mgr.current_target)


## ActionMenu.action_selected(action_name) → route to AssessmentManager.
func _on_action_selected(action_name: String) -> void:
	if _assessment_mgr:
		_assessment_mgr.perform_assessment_by_name(action_name)


## Wire TriageSystem.triage_assigned signal to update patient TriageTagVisual nodes.
func _wire_triage_system() -> void:
	var root := get_tree().current_scene
	if not root:
		return

	# Search for TriageSystem in the scene tree
	var triage: Node = _find_node_with_signal(root, "triage_assigned")
	if triage:
		if not triage.triage_assigned.is_connected(_on_triage_assigned):
			triage.triage_assigned.connect(_on_triage_assigned)
		# Disconnect on scene exit
		var _triage_ref := triage
		tree_exiting.connect(func():
			if is_instance_valid(_triage_ref) and _triage_ref.triage_assigned.is_connected(_on_triage_assigned):
				_triage_ref.triage_assigned.disconnect(_on_triage_assigned)
		)


## TriageSystem.triage_assigned(patient, assigned_tag, correct_tag, is_correct) → update visual.
func _on_triage_assigned(patient: Node, assigned_tag: int, _correct_tag: int, is_correct: bool) -> void:
	if not is_instance_valid(patient):
		return

	# Map enum int to label string (TriageSystem.TAG_LABELS)
	var tag_labels := {0: "GREEN", 1: "YELLOW", 2: "RED", 3: "BLACK"}
	var tag_label: String = tag_labels.get(assigned_tag, "GREEN")

	# Find TriageTagVisual on the patient
	var tag_visual: Node = patient.get_node_or_null("TriageTagVisual")
	if tag_visual and tag_visual.has_method("set_triage_tag"):
		tag_visual.set_triage_tag(tag_label, is_correct)


## Find the player node in the scene tree.
func _find_player() -> Node:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	var root := get_tree().current_scene
	if root:
		var p: Node = root.get_node_or_null("Player")
		if p:
			return p
	return null


## Find a node with a specific signal in the tree (recursive search).
func _find_node_with_signal(node: Node, signal_name: String) -> Node:
	if node.has_signal(signal_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_with_signal(child, signal_name)
		if found:
			return found
	return null


## ── Pause Menu ──────────────────────────────────────────────────────

func _build_pause_overlay() -> void:
	_pause_overlay = Control.new()
	_pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.visible = false
	_pause_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_pause_overlay)

	# Dim background
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.65)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.add_child(bg)

	# Center container
	var center := VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.offset_left = -160
	center.offset_right = 160
	center.offset_top = -150
	center.offset_bottom = 150
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 14)
	_pause_overlay.add_child(center)

	# Title
	var title := Label.new()
	title.text = tr("HUD_PAUSED_TITLE")
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	center.add_child(spacer)

	# Resume
	var resume_btn := Button.new()
	resume_btn.text = tr("MENU_RESUME")
	resume_btn.custom_minimum_size = Vector2(260, 48)
	resume_btn.add_theme_font_size_override("font_size", 20)
	resume_btn.pressed.connect(_on_resume)
	center.add_child(resume_btn)

	# Restart
	var restart_btn := Button.new()
	restart_btn.text = tr("MENU_RESTART")
	restart_btn.custom_minimum_size = Vector2(260, 48)
	restart_btn.add_theme_font_size_override("font_size", 20)
	restart_btn.pressed.connect(_on_restart)
	center.add_child(restart_btn)

	# Main Menu
	var menu_btn := Button.new()
	menu_btn.text = tr("MENU_QUIT_TO_MENU")
	menu_btn.custom_minimum_size = Vector2(260, 48)
	menu_btn.add_theme_font_size_override("font_size", 20)
	menu_btn.pressed.connect(_on_quit_to_menu)
	center.add_child(menu_btn)

	# Quit to Desktop
	var quit_btn := Button.new()
	quit_btn.text = tr("MENU_QUIT")
	quit_btn.custom_minimum_size = Vector2(260, 48)
	quit_btn.add_theme_font_size_override("font_size", 20)
	quit_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	quit_btn.pressed.connect(_on_quit_to_desktop)
	center.add_child(quit_btn)


func _toggle_pause() -> void:
	_paused = not _paused
	_pause_overlay.visible = _paused
	get_tree().paused = _paused
	if _paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_resume() -> void:
	_paused = false
	_pause_overlay.visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_restart() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().reload_current_scene()


func _on_quit_to_menu() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene("res://scenes/main/MainMenu.tscn")
	else:
		get_tree().change_scene_to_file("res://scenes/main/MainMenu.tscn")


func _on_quit_to_desktop() -> void:
	# Show confirmation dialog before quitting
	if _quit_confirm_overlay and _quit_confirm_overlay.visible:
		return  # Already showing
	_show_quit_confirmation()


## Quit confirmation overlay — built lazily on first use.
var _quit_confirm_overlay: Control = null


func _show_quit_confirmation() -> void:
	if _quit_confirm_overlay:
		_quit_confirm_overlay.visible = true
		return

	_quit_confirm_overlay = Control.new()
	_quit_confirm_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_quit_confirm_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_quit_confirm_overlay)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.0, 0.0, 0.75)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_quit_confirm_overlay.add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	vbox.offset_left = -160
	vbox.offset_right = 160
	vbox.offset_top = -80
	vbox.offset_bottom = 80
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 16)
	_quit_confirm_overlay.add_child(vbox)

	var label := Label.new()
	label.text = tr("QUIT_CONFIRM_MSG")
	label.add_theme_font_size_override("font_size", 22)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)

	var btn_row := HBoxContainer.new()
	btn_row.alignment = BoxContainer.ALIGNMENT_CENTER
	btn_row.add_theme_constant_override("separation", 20)
	vbox.add_child(btn_row)

	var yes_btn := Button.new()
	yes_btn.text = tr("MENU_QUIT")
	yes_btn.custom_minimum_size = Vector2(120, 44)
	yes_btn.add_theme_font_size_override("font_size", 18)
	yes_btn.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))
	yes_btn.pressed.connect(func(): get_tree().quit())
	btn_row.add_child(yes_btn)

	var no_btn := Button.new()
	no_btn.text = tr("MENU_CANCEL")
	no_btn.custom_minimum_size = Vector2(120, 44)
	no_btn.add_theme_font_size_override("font_size", 18)
	no_btn.pressed.connect(func(): _quit_confirm_overlay.visible = false)
	btn_row.add_child(no_btn)
