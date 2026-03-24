## Isometric camera rig with smooth follow and optional zoom.
## Orthographic projection at true isometric angle (~35.264° pitch, 45° yaw).
extends Camera3D

## Node to follow. Assign via inspector or script.
@export var target: Node3D

## How quickly the camera catches up to the target (higher = snappier).
@export var follow_speed: float = 5.0

## Camera offset from target position (maintains isometric framing).
@export var offset: Vector3 = Vector3(10.0, 10.0, 10.0)

## Zoom bounds for orthographic size.
@export var zoom_min: float = 5.0
@export var zoom_max: float = 20.0

## Zoom step per scroll tick.
@export var zoom_step: float = 1.0


func _ready() -> void:
	# Orthographic projection
	projection = PROJECTION_ORTHOGONAL
	size = 10.0

	# True isometric angle: pitch = arctan(1/sqrt(2)) ≈ 35.264°, yaw = 45°
	rotation_degrees = Vector3(-35.264, 45.0, 0.0)


func _process(delta: float) -> void:
	if target == null:
		return
	# Smooth follow — lerp position toward target + offset
	var target_pos := target.global_position + offset
	global_position = global_position.lerp(target_pos, follow_speed * delta)


func _unhandled_input(event: InputEvent) -> void:
	# Block zoom when a UI panel is active (cursor visible = modal UI open).
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	# Mouse scroll zoom
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				size = clampf(size - zoom_step, zoom_min, zoom_max)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				size = clampf(size + zoom_step, zoom_min, zoom_max)
