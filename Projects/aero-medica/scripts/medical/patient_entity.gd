## PatientEntity — Root script for the PatientBase scene.
## Holds the PatientPersona resource and provides access to child components.
extends CharacterBody3D

## Patient persona data — set per-instance via editor or ScenarioManager.
@export var persona: PatientPersona

## Quick accessors for child components.
@onready var medical_state: Node = $MedicalStateComponent
@onready var interactable: Node = $InteractableComponent
@onready var deterioration: Node = $DeteriorationSystem
@onready var triage_tag: MeshInstance3D = $TriageTagVisual
@onready var status_visual: Node = $PatientStatusVisual

## Animation player found on the patient model.
var _anim_player: AnimationPlayer = null


func _ready() -> void:
	add_to_group("patients")
	_setup_animation.call_deferred()


func _setup_animation() -> void:
	var model: Node = get_node_or_null("PatientModel")
	if not model:
		return

	_anim_player = _find_child_of_type(model, "AnimationPlayer") as AnimationPlayer
	if not _anim_player:
		return

	var anims: PackedStringArray = _anim_player.get_animation_list()

	# The patient model is rotated 90° to lie on the ground (via PatientBase.tscn transform).
	# A standing/idle animation looks like lying down when rotated.
	# Priority: idle > breathe > stand > lying > any non-sit non-walk non-RESET
	# AVOID: sit, walk, run — these look wrong when the model is rotated to lie flat.
	var best_anim: String = ""
	var best_priority: int = 99

	for anim_name in anims:
		var lower := anim_name.to_lower()
		var priority := 99

		if lower == "idle":
			priority = 0  # Best — neutral pose → looks like lying flat
		elif "breathe" in lower or "breathing" in lower:
			priority = 1  # Subtle chest movement — great for lying patient
		elif "stand" in lower:
			priority = 2  # Standing → appears as lying straight
		elif "lie" in lower or "lying" in lower or "dead" in lower or "faint" in lower:
			priority = 3  # Actual lying animation
		elif "sit" in lower or "walk" in lower or "run" in lower or "jump" in lower:
			continue  # Skip — these look wrong when model is rotated to lie flat

		if priority < best_priority:
			best_priority = priority
			best_anim = anim_name

	# Fallback: play the first non-RESET, non-walk, non-sit animation to escape T-pose
	if best_anim == "" and anims.size() > 0:
		for anim_name in anims:
			var lower := anim_name.to_lower()
			if anim_name != "RESET" and "sit" not in lower and "walk" not in lower and "run" not in lower:
				best_anim = anim_name
				break

	if best_anim != "":
		_anim_player.play(best_anim)


## Recursively find a child node of a specific class name.
func _find_child_of_type(node: Node, type_name: String) -> Node:
	for child in node.get_children():
		if child.get_class() == type_name:
			return child
		var found: Node = _find_child_of_type(child, type_name)
		if found:
			return found
	return null
