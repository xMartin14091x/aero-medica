## GameManager — Global state, scene transitions, session lifecycle.
## Autoload singleton registered in project.godot.
extends Node

## Game state machine
enum GameState { MENU, PLAYING, PAUSED, DEBRIEF }

## Emitted when the game state transitions.
signal state_changed(old_state: GameState, new_state: GameState)

## Current game state.
var current_state: GameState = GameState.MENU


## Transition to a new game state with signal emission.
func change_state(new_state: GameState) -> void:
	if new_state == current_state:
		return
	var old_state := current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)


## Change the active scene by path. Deferred to avoid mid-frame issues.
func change_scene(scene_path: String) -> void:
	get_tree().call_deferred("change_scene_to_file", scene_path)
