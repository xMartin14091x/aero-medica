## MedicalBagTierManager — Tiered BLS/ALS equipment management system.
## Phase 6 (MON-17): Tracks inventory, consumable quantities, equipment deployment.
## Scenario-based tier assignment (BLS for tutorials, ALS for advanced scenarios).
extends Node

## Loaded bag tiers from JSON.
var _tiers: Dictionary = {}

## Active bag contents (resolved from tier + quantities).
var _active_bag: Dictionary = {}

## Current tier ("BLS" or "ALS").
var _current_tier: String = "BLS"

## Deployed equipment on current patient.
var _deployed_on_patient: Dictionary = {}  # { patient_name: [equipment_keys] }

## Emitted when equipment is deployed to a patient.
signal equipment_deployed(patient: Node, equipment_key: String)

## Emitted when a consumable is depleted.
signal item_depleted(equipment_key: String)


func _ready() -> void:
	_load_tier_database()


func _load_tier_database() -> void:
	var file := FileAccess.open("res://data/medical_bag_tiers.json", FileAccess.READ)
	if not file:
		push_error("MedicalBagTierManager: Cannot open medical_bag_tiers.json")
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) == OK:
		_tiers = json.data
	file.close()


## Set the active tier for this scenario ("BLS" or "ALS").
## Called by ScenarioManager when loading a scenario.
func set_tier(tier: String) -> void:
	_current_tier = tier
	_build_active_bag()


## Get current tier.
func get_current_tier() -> String:
	return _current_tier


## Build the active bag contents from tier data (with quantities).
func _build_active_bag() -> void:
	_active_bag.clear()
	var bls_items: Array = _tiers.get("BLS", {}).get("items", [])
	for item in bls_items:
		_active_bag[item["key"]] = {
			"display": item["display"],
			"category": item["category"],
			"quantity": item["quantity"],
			"max_quantity": item["quantity"],
			"consumable": item["consumable"],
			"available": true,
		}
	if _current_tier == "ALS":
		var als_items: Array = _tiers.get("ALS", {}).get("additional_items", [])
		for item in als_items:
			_active_bag[item["key"]] = {
				"display": item["display"],
				"category": item["category"],
				"quantity": item["quantity"],
				"max_quantity": item["quantity"],
				"consumable": item["consumable"],
				"available": true,
			}


## Get all items in the active bag.
func get_all_items() -> Dictionary:
	return _active_bag


## Get items filtered by category.
func get_items_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key in _active_bag:
		var item: Dictionary = _active_bag[key]
		if item.get("category", "") == category:
			var entry := item.duplicate()
			entry["key"] = key
			result.append(entry)
	return result


## Get all unique categories in the current bag.
func get_categories() -> Array[String]:
	var cats: Array[String] = []
	for key in _active_bag:
		var cat: String = _active_bag[key].get("category", "")
		if cat not in cats:
			cats.append(cat)
	return cats


## Deploy an item to a patient. Returns success/failure dict.
func deploy_item(patient: Node, item_key: String) -> Dictionary:
	if not _active_bag.has(item_key):
		return {"success": false, "message": "Item not in bag."}

	var item: Dictionary = _active_bag[item_key]
	if not item.get("available", false):
		return {"success": false, "message": "Item depleted."}

	# Decrement quantity for consumables
	if item.get("consumable", false):
		var qty: int = item.get("quantity", 0)
		if qty <= 0:
			item["available"] = false
			item_depleted.emit(item_key)
			return {"success": false, "message": "%s is depleted." % item.get("display", item_key)}
		item["quantity"] = qty - 1
		if item["quantity"] <= 0:
			item["available"] = false
			item_depleted.emit(item_key)

	# Track deployment on patient
	var patient_name: String = patient.name
	if not _deployed_on_patient.has(patient_name):
		_deployed_on_patient[patient_name] = []
	if item_key not in _deployed_on_patient[patient_name]:
		_deployed_on_patient[patient_name].append(item_key)
		# Also mark on patient metadata for assessment gating
		if not patient.has_meta("deployed_equipment"):
			patient.set_meta("deployed_equipment", [])
		var deployed: Array = patient.get_meta("deployed_equipment")
		if item_key not in deployed:
			deployed.append(item_key)
			patient.set_meta("deployed_equipment", deployed)

	equipment_deployed.emit(patient, item_key)
	return {
		"success": true,
		"message": "%s deployed." % item.get("display", item_key),
		"remaining": item.get("quantity", 0),
	}


## Check if an item is available in the active bag.
func is_available(item_key: String) -> bool:
	return _active_bag.get(item_key, {}).get("available", false)


## Get item display data.
func get_item_data(item_key: String) -> Dictionary:
	return _active_bag.get(item_key, {})
