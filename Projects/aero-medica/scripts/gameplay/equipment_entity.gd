## EquipmentEntity — Root script for equipment base scenes.
## Holds the EquipmentData resource and provides access to child components.
extends StaticBody3D

## Equipment data — set per-variant via editor or ScenarioManager.
@export var equipment_data: EquipmentData

## Quick accessor for interaction component.
@onready var interactable: Node = $InteractableComponent


## Accessor for InventoryComponent lookup.
func get_equipment_data() -> EquipmentData:
	return equipment_data
