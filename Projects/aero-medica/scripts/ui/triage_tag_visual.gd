## TriageTagVisual — Colour-coded 3D tag above patient after triage assignment.
## Hidden until tag assigned. Incorrect tags pulse subtly (stealth assessment).
## Called via set_triage_tag() — wired by HUDController from TriageSystem.triage_assigned.
extends MeshInstance3D

## Triage tag colour mapping.
const TAG_COLOURS := {
	"GREEN": Color(0.0, 1.0, 0.0),
	"YELLOW": Color(1.0, 1.0, 0.0),
	"RED": Color(1.0, 0.0, 0.0),
	"BLACK": Color(0.9, 0.9, 0.9),
}

## Pulse speed for incorrect tags (cycles per second).
const PULSE_SPEED := 2.0

## Pulse alpha range for incorrect tags.
const PULSE_ALPHA_MIN := 0.5
const PULSE_ALPHA_MAX := 1.0

## Whether this tag has been assigned.
var _is_assigned: bool = false

## Whether the assigned tag is correct (stealth — no explicit "WRONG").
var _is_correct: bool = true

## Active pulse tween (null if not pulsing).
var _pulse_tween: Tween = null


func _ready() -> void:
	visible = false
	# Ensure we have our own material instance to avoid sharing across patients
	if mesh and mesh.surface_get_material(0):
		var mat := mesh.surface_get_material(0).duplicate() as StandardMaterial3D
		set_surface_override_material(0, mat)


## Show the triage tag with the given colour. Called externally after assignment.
func set_triage_tag(tag_label: String, is_correct: bool) -> void:
	_is_assigned = true
	_is_correct = is_correct

	# Set colour
	var colour: Color = TAG_COLOURS.get(tag_label, Color.WHITE)
	var mat := get_surface_override_material(0) as StandardMaterial3D
	if mat == null:
		mat = StandardMaterial3D.new()
		set_surface_override_material(0, mat)
	mat.albedo_color = colour
	mat.emission_enabled = true
	mat.emission = colour * 0.5
	mat.emission_energy_multiplier = 0.8

	# Show the tag
	visible = true

	# If incorrect, start subtle pulse (player notices something is off)
	if not is_correct:
		_start_pulse()
	else:
		_stop_pulse()


## Start subtle pulsing for incorrect tags.
func _start_pulse() -> void:
	_stop_pulse()
	_pulse_tween = create_tween()
	_pulse_tween.set_loops()
	_pulse_tween.tween_method(_set_alpha, PULSE_ALPHA_MAX, PULSE_ALPHA_MIN, 0.5 / PULSE_SPEED)
	_pulse_tween.tween_method(_set_alpha, PULSE_ALPHA_MIN, PULSE_ALPHA_MAX, 0.5 / PULSE_SPEED)


## Stop pulsing.
func _stop_pulse() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
		_pulse_tween = null
	_set_alpha(1.0)


## Set the alpha via transparency on the material.
func _set_alpha(alpha: float) -> void:
	var mat := get_surface_override_material(0) as StandardMaterial3D
	if mat:
		mat.albedo_color.a = alpha
		if alpha < 1.0:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		else:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED


## Reset the tag visual (for new scenario).
func reset() -> void:
	_is_assigned = false
	_is_correct = true
	_stop_pulse()
	visible = false
