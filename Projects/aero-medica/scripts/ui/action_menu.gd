## ActionMenu — Contextual assessment menu near patient.
## Shows 5 assessment actions when player interacts with a patient.
## Supports keyboard (1-5) and mouse click selection.
## HUDController routes selections to AssessmentManager.perform_assessment_by_name().
extends Control

## Emitted when an assessment action is selected. Payload: action name string.
## HUDController connects this to AssessmentManager.
signal action_selected(action_name: String)

## Distance threshold — menu auto-closes if player walks further than this.
const CLOSE_DISTANCE := 3.5

## Vertical screen offset from patient position (pixels).
const SCREEN_OFFSET_Y := -80.0

## Available assessment actions (matches AssessmentManager.ACTION_LABELS values).
## "Talk to Patient" opens the history dialogue panel (handled by HUDController).
const ACTIONS := [
	"Check Airway",
	"Check Breathing",
	"Check Pulse",
	"Check Consciousness",
	"Check Bleeding",
	"Talk to Patient",
]

## Physical keycodes for 1-6.
const KEY_CODES := [
	KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6,
]

## UI references.
@onready var panel: PanelContainer = $PanelContainer
@onready var button_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer

## The patient being assessed.
var _target_patient: Node = null

## Player reference (for distance check).
var _player: Node = null

## Camera reference (for screen positioning).
var _camera: Camera3D = null

## Button nodes for the 5 actions.
var _buttons: Array[Button] = []


func _ready() -> void:
	visible = false
	_build_buttons()
	_find_references.call_deferred()


func _find_references() -> void:
	await get_tree().process_frame
	_player = _find_player()
	_camera = get_viewport().get_camera_3d()


func _process(_delta: float) -> void:
	if not visible or _target_patient == null or _camera == null:
		return

	# Auto-close if player walks away
	if _player and is_instance_valid(_target_patient):
		var dist: float = _player.global_position.distance_to(_target_patient.global_position)
		if dist > CLOSE_DISTANCE:
			close_menu()
			# Also end assessment mode in AssessmentManager
			var assessment: Node = _player.get_node_or_null("AssessmentManager")
			if assessment:
				assessment.end_assessment()
			return

	# Reposition menu near patient's screen position
	if is_instance_valid(_target_patient):
		var world_pos: Vector3 = _target_patient.global_position + Vector3(0.0, 1.8, 0.0)
		if _camera.is_position_behind(world_pos):
			return
		var screen_pos := _camera.unproject_position(world_pos)
		global_position = screen_pos + Vector2(0.0, SCREEN_OFFSET_Y) - size / 2.0


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	# Handle keyboard number keys 1-5
	if event is InputEventKey and event.pressed and not event.echo:
		for i in range(KEY_CODES.size()):
			if event.physical_keycode == KEY_CODES[i]:
				_select_action(i)
				get_viewport().set_input_as_handled()
				return

	# Handle Escape to close menu
	if event is InputEventKey and event.pressed:
		if event.physical_keycode == KEY_ESCAPE:
			close_menu()
			var assessment: Node = _player.get_node_or_null("AssessmentManager") if _player else null
			if assessment:
				assessment.end_assessment()
			get_viewport().set_input_as_handled()


## Build the 5 assessment action buttons.
func _build_buttons() -> void:
	for i in range(ACTIONS.size()):
		var btn := Button.new()
		btn.text = "%d. %s" % [i + 1, ACTIONS[i]]
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(_on_button_pressed.bind(i))
		btn.focus_mode = Control.FOCUS_NONE
		button_container.add_child(btn)
		_buttons.append(btn)


## Open the menu for a specific patient target.
func open_menu(patient: Node) -> void:
	_target_patient = patient
	visible = true
	if _buttons.size() > 0:
		_buttons[0].grab_focus()


## Close the menu and clear target.
func close_menu() -> void:
	_target_patient = null
	visible = false


## Handle button press by index.
func _on_button_pressed(index: int) -> void:
	_select_action(index)


## Emit the selected action name — HUDController routes to AssessmentManager.
## Menu stays open so the player can perform multiple assessments in sequence.
func _select_action(index: int) -> void:
	if index < 0 or index >= ACTIONS.size():
		return
	action_selected.emit(ACTIONS[index])


## Find the player node in the scene tree.
func _find_player() -> Node:
	var players := get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		return players[0]
	var root := get_tree().current_scene
	if root:
		var player: Node = root.get_node_or_null("Player")
		if player:
			return player
	return null
