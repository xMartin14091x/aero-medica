## Player Controller — EMT character with isometric 8-directional movement.
## Attached to a CharacterBody3D. Input is rotated -45° to match isometric camera.
## Interaction detection is handled by InteractionManager (sibling node).
extends CharacterBody3D

## Movement speed in units per second.
@export var move_speed: float = 5.0

## Interaction detection radius (Area3D sphere collider).
@export var interaction_radius: float = 2.0

## Pre-calculated isometric rotation: -45° around Y axis.
## Rotates screen-relative WASD input to world-space isometric directions.
const ISO_ROTATION := -PI / 4.0

## Animation player reference (found on the doctor model).
var _anim_player: AnimationPlayer = null

## Skeleton reference for root motion stripping.
var _skeleton: Skeleton3D = null
var _root_bone_idx: int = -1
var _root_bone_rest_pos: Vector3 = Vector3.ZERO

## Available animation names from the model.
var _anim_idle: String = ""
var _anim_walk: String = ""


func _ready() -> void:
	add_to_group("player")
	# Reset any editor-placed rotation on the CharacterBody3D itself.
	# Movement math assumes the body starts at identity rotation — the model
	# child handles facing direction via lerp_angle in _physics_process.
	rotation = Vector3.ZERO
	_find_animation_player.call_deferred()


func _find_animation_player() -> void:
	# Search DoctorModel for an AnimationPlayer
	var model: Node = get_node_or_null("DoctorModel")
	if not model:
		return

	_anim_player = _find_child_of_type(model, "AnimationPlayer") as AnimationPlayer
	if not _anim_player:
		return

	# List all animations and pick idle/walk
	var anims: PackedStringArray = _anim_player.get_animation_list()
	for anim_name in anims:
		var lower := anim_name.to_lower()
		# Prefer exact "idle" match first
		if lower == "idle":
			_anim_idle = anim_name
		elif _anim_idle == "" and ("stand" in lower or "breathe" in lower):
			_anim_idle = anim_name
		if lower == "walk" or lower == "walking":
			_anim_walk = anim_name
		elif _anim_walk == "" and ("run" in lower or "move" in lower):
			_anim_walk = anim_name

	# Fallback: if no named idle found, use the first non-RESET, non-walk animation
	if _anim_idle == "" and anims.size() > 0:
		for anim_name in anims:
			if anim_name != "RESET" and anim_name != _anim_walk:
				_anim_idle = anim_name
				break

	# Find skeleton and strip root motion from all animations
	_skeleton = _find_child_of_type(model, "Skeleton3D") as Skeleton3D
	if _skeleton:
		_root_bone_idx = 0
		var root_bone_name := _skeleton.get_bone_name(0)
		# Remove position tracks for the root bone from all animations
		_strip_root_motion_from_all(root_bone_name)

	# Play idle animation to get out of T-pose
	if _anim_idle != "":
		_anim_player.play(_anim_idle)


func _physics_process(_delta: float) -> void:
	# Block movement when a UI panel is active (cursor visible = modal UI open).
	# PatientInteractionUI sets MOUSE_MODE_VISIBLE on open, CAPTURED on close.
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Read input as a 2D vector (screen-relative)
	var input_dir := Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")
	input_dir = input_dir.normalized()

	# Rotate input vector by -45° to align with isometric camera
	var rotated := input_dir.rotated(ISO_ROTATION)

	# Apply as XZ movement (Y stays 0 — no vertical movement)
	velocity = Vector3(rotated.x, 0.0, rotated.y) * move_speed

	# Rotate model to face movement direction
	var model: Node = get_node_or_null("DoctorModel")
	if model:
		if input_dir.length() > 0.1:
			var target_angle := atan2(velocity.x, velocity.z)
			model.rotation.y = lerp_angle(model.rotation.y, target_angle, 0.15)
		# Lock model node position
		model.position = Vector3.ZERO

	# Switch between walk and idle animations
	if _anim_player:
		var moving := input_dir.length() > 0.1
		if moving and _anim_walk != "":
			if _anim_player.current_animation != _anim_walk:
				_anim_player.play(_anim_walk)
		elif not moving and _anim_idle != "":
			if _anim_player.current_animation != _anim_idle:
				_anim_player.play(_anim_idle)

	move_and_slide()


## Strip root motion position tracks from all animations so the walk anim
## can't translate the skeleton. This modifies the Animation resources directly.
func _strip_root_motion_from_all(root_bone_name: String) -> void:
	if not _anim_player:
		return
	var anim_lib: AnimationLibrary = _anim_player.get_animation_library("")
	if not anim_lib:
		return
	for anim_name in anim_lib.get_animation_list():
		var anim: Animation = anim_lib.get_animation(anim_name)
		if not anim:
			continue
		for track_idx in range(anim.get_track_count() - 1, -1, -1):
			var path: NodePath = anim.track_get_path(track_idx)
			var path_str := str(path)
			# Match position tracks for the root bone (e.g. "Skeleton3D:Hips")
			if root_bone_name in path_str and anim.track_get_type(track_idx) == Animation.TYPE_POSITION_3D:
				anim.remove_track(track_idx)


## Recursively find a child node of a specific class name.
func _find_child_of_type(node: Node, type_name: String) -> Node:
	for child in node.get_children():
		if child.get_class() == type_name:
			return child
		var found: Node = _find_child_of_type(child, type_name)
		if found:
			return found
	return null
