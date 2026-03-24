## InteractionPrompt — Floating "[E] {label}" prompt above interactable objects.
## Shows when player is near an interactable, hides when out of range.
## Wired via HUDController to InteractionManager.interaction_target_changed.
extends Control

## Fade duration in seconds.
const FADE_DURATION := 0.15

## Vertical offset above the target in screen space (pixels).
const SCREEN_OFFSET_Y := -60.0

## Reference to the prompt label.
@onready var label: Label = $PanelContainer/Label

## Currently tracked interaction target (or null).
var _current_target: Node3D = null

## Reference to the camera (found at runtime).
var _camera: Camera3D = null


func _ready() -> void:
	modulate.a = 0.0
	visible = false
	_find_camera.call_deferred()


func _find_camera() -> void:
	_camera = get_viewport().get_camera_3d()


func _process(_delta: float) -> void:
	if _current_target == null or _camera == null:
		return
	if not is_instance_valid(_current_target):
		_clear_target()
		return
	# Reposition prompt to follow target's screen position
	var world_pos := _current_target.global_position + Vector3(0.0, 1.5, 0.0)
	if _camera.is_position_behind(world_pos):
		visible = false
		return
	visible = true
	var screen_pos := _camera.unproject_position(world_pos)
	global_position = screen_pos + Vector2(0.0, SCREEN_OFFSET_Y) - size / 2.0


## Called by HUD when the player's nearest interactable changes.
func on_target_changed(target: Node3D) -> void:
	if target == _current_target:
		return

	if target == null:
		_clear_target()
	else:
		var interactable: Node = target.get_node_or_null("InteractableComponent")
		var lbl := "Interact"
		if interactable:
			lbl = interactable.interaction_label
		_set_target(target, lbl)


## Show prompt for a target with given label.
func _set_target(target: Node3D, interaction_label: String) -> void:
	_current_target = target
	label.text = "[E] %s" % interaction_label
	visible = true
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)


## Hide prompt and clear target.
func _clear_target() -> void:
	_current_target = null
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	tween.tween_callback(func(): visible = false)
