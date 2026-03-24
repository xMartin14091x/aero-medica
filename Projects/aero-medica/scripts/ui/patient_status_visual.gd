## PatientStatusVisual — Real-time visual indicators of patient medical state.
## Breathing oscillation, bleeding plane, consciousness posture, cardiac/dead tints.
## Attached as child of PatientBase — reads MedicalStateComponent signals.
extends Node

## Reference to patient's mesh for visual effects.
var _mesh: MeshInstance3D = null

## Reference to MedicalStateComponent.
var _medical: Node = null

## Bleeding indicator plane (created at runtime).
var _bleeding_plane: MeshInstance3D = null

## Breathing tween (looping scale oscillation).
var _breathing_tween: Tween = null

## Base mesh transform (stored for posture changes).
var _base_mesh_transform: Transform3D

## Original material colour (for desaturation effects).
var _original_colour: Color = Color(0.8, 0.3, 0.3, 1.0)

## Patient entity parent.
@onready var _patient: Node3D = get_parent()


func _ready() -> void:
	_setup.call_deferred()


func _setup() -> void:
	if not _patient:
		return

	_mesh = _patient.get_node_or_null("MeshInstance3D")
	_medical = _patient.get_node_or_null("MedicalStateComponent")

	if _mesh:
		_base_mesh_transform = _mesh.transform
		# Store original colour
		var mat: Material = _mesh.get_active_material(0)
		if mat and mat is StandardMaterial3D:
			_original_colour = mat.albedo_color

	if _medical:
		_medical.state_changed.connect(_on_state_changed)
		_medical.modifier_changed.connect(_on_modifier_changed)
		# Apply initial state
		_update_all_visuals()

	# Create bleeding indicator
	_create_bleeding_plane()


## Create the red bleeding plane beneath the patient.
func _create_bleeding_plane() -> void:
	_bleeding_plane = MeshInstance3D.new()
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = Vector2(0.1, 0.1)
	_bleeding_plane.mesh = plane_mesh

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.8, 0.0, 0.0, 0.6)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_bleeding_plane.material_override = mat
	_bleeding_plane.position = Vector3(0.0, 0.02, 0.0)
	_bleeding_plane.visible = false

	_patient.add_child(_bleeding_plane)


## Update all visual indicators based on current medical state.
func _update_all_visuals() -> void:
	if not _medical:
		return
	_update_bleeding_visual()
	_update_consciousness_posture()
	_update_breathing_animation()
	_update_colour_tint()


## MedicalStateComponent.state_changed handler.
func _on_state_changed(_old_state: int, _new_state: int) -> void:
	_update_all_visuals()


## MedicalStateComponent.modifier_changed handler.
func _on_modifier_changed(modifier_name: String, _old_value: Variant, _new_value: Variant) -> void:
	match modifier_name:
		"bleeding_severity":
			_update_bleeding_visual()
		"breathing_rate":
			_update_breathing_animation()
		"airway_status":
			_update_breathing_animation()
		_:
			_update_all_visuals()


## Bleeding: red plane scales with severity (0=hidden, 1=small, 2=medium, 3=large).
func _update_bleeding_visual() -> void:
	if not _bleeding_plane or not _medical:
		return

	var severity: int = _medical.bleeding_severity
	if severity <= 0:
		_bleeding_plane.visible = false
		return

	_bleeding_plane.visible = true
	# Scale the plane based on severity: 0.4, 0.8, 1.2 diameter
	var scale_factor: float = 0.4 * severity
	var plane_mesh := _bleeding_plane.mesh as PlaneMesh
	if plane_mesh:
		plane_mesh.size = Vector2(scale_factor, scale_factor)

	# Darken colour with higher severity
	var mat := _bleeding_plane.material_override as StandardMaterial3D
	if mat:
		var alpha: float = 0.3 + (severity * 0.15)
		mat.albedo_color = Color(0.8, 0.0, 0.0, alpha)


## Consciousness posture: rotate/position mesh based on AVPU state.
## CONSCIOUS = upright (rotated 90° standing), UNCONSCIOUS/PAIN = lying flat (default).
func _update_consciousness_posture() -> void:
	if not _mesh or not _medical:
		return

	var state: int = _medical.current_state

	match state:
		0:  # CONSCIOUS — sitting/upright (capsule rotated to vertical)
			_mesh.transform = Transform3D(
				Basis.IDENTITY,
				Vector3(0.0, 0.7, 0.0)
			)
		1:  # UNCONSCIOUS — lying flat (capsule on side, slightly curled)
			_mesh.transform = Transform3D(
				Basis(Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, -1, 0)),
				Vector3(0.0, 0.25, 0.0)
			)
		2:  # CARDIAC_ARREST — lying flat, no movement
			_mesh.transform = Transform3D(
				Basis(Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, -1, 0)),
				Vector3(0.0, 0.25, 0.0)
			)
		3:  # DEAD — lying flat
			_mesh.transform = Transform3D(
				Basis(Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, -1, 0)),
				Vector3(0.0, 0.25, 0.0)
			)


## Breathing: subtle scale oscillation on conscious/breathing patients.
func _update_breathing_animation() -> void:
	if not _mesh or not _medical:
		return

	# Stop existing breathing animation
	if _breathing_tween:
		_breathing_tween.kill()
		_breathing_tween = null
		_mesh.scale = Vector3.ONE

	var state: int = _medical.current_state

	# No breathing for cardiac arrest or dead
	if state >= 2:
		return

	var rate: float = _medical.breathing_rate

	# No breathing if rate is too low
	if rate < 2.0:
		return

	# Breathing speed: normal ~16 breaths/min → ~0.27Hz
	# Scale oscillation: subtle chest expansion
	var cycle_duration: float = 60.0 / maxf(rate, 4.0)
	var breathe_amount := 0.03  # Subtle 3% scale change

	_breathing_tween = create_tween()
	_breathing_tween.set_loops()
	_breathing_tween.tween_property(
		_mesh, "scale",
		Vector3(1.0 + breathe_amount, 1.0 + breathe_amount * 0.5, 1.0 + breathe_amount),
		cycle_duration * 0.4
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	_breathing_tween.tween_property(
		_mesh, "scale",
		Vector3.ONE,
		cycle_duration * 0.6
	).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)


## Colour tint: desaturate for cardiac arrest, grey/black for dead.
func _update_colour_tint() -> void:
	if not _mesh or not _medical:
		return

	var mat: Material = _mesh.get_active_material(0)
	if not mat or not mat is StandardMaterial3D:
		# Create a material override if needed
		mat = StandardMaterial3D.new()
		mat.albedo_color = _original_colour
		_mesh.material_override = mat

	# Use material_override to avoid changing shared sub-resource
	if not _mesh.material_override:
		_mesh.material_override = mat.duplicate()
	mat = _mesh.material_override as StandardMaterial3D

	var state: int = _medical.current_state

	match state:
		0, 1:  # CONSCIOUS, UNCONSCIOUS — normal colour
			mat.albedo_color = _original_colour
		2:  # CARDIAC_ARREST — desaturated
			var desat := _desaturate(_original_colour, 0.6)
			mat.albedo_color = desat
		3:  # DEAD — dark grey
			mat.albedo_color = Color(0.25, 0.25, 0.25, 1.0)


## Desaturate a colour by the given amount (0=original, 1=fully grey).
func _desaturate(colour: Color, amount: float) -> Color:
	var grey: float = colour.r * 0.299 + colour.g * 0.587 + colour.b * 0.114
	return Color(
		lerpf(colour.r, grey, amount),
		lerpf(colour.g, grey, amount),
		lerpf(colour.b, grey, amount),
		colour.a
	)


## Clean up tweens.
func _exit_tree() -> void:
	if _breathing_tween:
		_breathing_tween.kill()
