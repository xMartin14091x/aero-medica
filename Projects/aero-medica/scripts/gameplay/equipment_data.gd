## EquipmentData — Resource class defining equipment properties.
## Saved as .tres and attached to equipment entity scenes.
extends Resource
class_name EquipmentData

## Equipment type identifiers.
enum EquipmentType { AED, BANDAGE, SPLINT, OXYGEN_MASK, STRETCHER }

## Display name for UI and telemetry.
@export var equipment_name: String = "Unknown Equipment"

## Type enum for logic branching.
@export var equipment_type: EquipmentType = EquipmentType.BANDAGE

## Label shown when the player can use this equipment (e.g., "Apply Bandage").
@export var use_label: String = "Use"
