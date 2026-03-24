## InteractableComponent — Attach as child to any entity the player can interact with.
## Defines the interaction interface and signal contract.
extends Node

## Label displayed in the UI interaction prompt (e.g., "Check Pulse", "Pick Up AED").
@export var interaction_label: String = "Interact"

## Whether this entity supports F12 live dialogue (Ollama NPC conversation).
@export var dialogue_capable: bool = false

## Emitted when the player triggers an interaction with this entity.
signal interacted(interactor: Node)


## Returns whether the interaction is currently available.
## Override in derived scripts for conditional interactions.
func can_interact() -> bool:
	return true
