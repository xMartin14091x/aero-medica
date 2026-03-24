## TutorialLevel — Guided learning environment with sequential UI hints.
## Small park/sidewalk area, 1 conscious patient, all equipment, no time pressure.
extends Node3D

const TILE_SIZE := 2.0
const GRID_WIDTH := 10
const GRID_HEIGHT := 10

## Hint system state.
var _hints_shown: Dictionary = {}
var _hint_label: Label = null
var _hint_panel: PanelContainer = null

## Scene references for asset replacement.
var _road_scene: PackedScene = null
var _sidewalk_scene: PackedScene = null
var _grass_scene: PackedScene = null


func _ready() -> void:
	_road_scene = load("res://scenes/environments/Road.tscn")
	_sidewalk_scene = load("res://scenes/environments/Sidewalk.tscn")
	_grass_scene = load("res://scenes/environments/Grass.tscn")

	#_generate_grid()  # Tiles already placed in Tutorial.tscn — disabled to prevent overlap
	_place_spawn_markers()
	_setup_navigation()
	_create_hint_ui()
	_wire_camera()
	_set_ambient_audio()

	# Load scenario data to spawn patients and equipment
	_load_scenario.call_deferred()

	# Show first hint after a short delay
	_show_hint.call_deferred("move", "Press W/A/S/D to move around")


func _generate_grid() -> void:
	for x in GRID_WIDTH:
		for z in GRID_HEIGHT:
			var tile: Node3D = _pick_tile(x, z).instantiate()
			tile.position = Vector3(x * TILE_SIZE, 0, z * TILE_SIZE)
			add_child(tile)


func _pick_tile(x: int, z: int) -> PackedScene:
	# Simple layout: grass border, sidewalk path, small park area
	if x == 0 or x == GRID_WIDTH - 1 or z == 0 or z == GRID_HEIGHT - 1:
		return _grass_scene
	if x == 1 or x == GRID_WIDTH - 2 or z == 1 or z == GRID_HEIGHT - 2:
		return _grass_scene
	if x >= 3 and x <= 6 and z == 5:
		return _sidewalk_scene  # Path to patient
	if x >= 3 and x <= 6 and z >= 3 and z <= 7:
		return _grass_scene  # Park area
	return _sidewalk_scene


func _place_spawn_markers() -> void:
	# Player spawn — entrance area
	var player_spawn := Marker3D.new()
	player_spawn.name = "PlayerSpawn"
	player_spawn.position = Vector3(2 * TILE_SIZE, 0.1, 5 * TILE_SIZE)
	add_child(player_spawn)

	# Patient spawn — in the park area
	var patient_spawn := Marker3D.new()
	patient_spawn.name = "PatientSpawn_01"
	patient_spawn.position = Vector3(6 * TILE_SIZE, 0.1, 5 * TILE_SIZE)
	add_child(patient_spawn)

	# Equipment spawns — all types nearby
	var equip_positions := [
		Vector3(5 * TILE_SIZE, 0.1, 3 * TILE_SIZE),
		Vector3(5 * TILE_SIZE, 0.1, 7 * TILE_SIZE),
		Vector3(7 * TILE_SIZE, 0.1, 4 * TILE_SIZE),
		Vector3(7 * TILE_SIZE, 0.1, 6 * TILE_SIZE),
		Vector3(4 * TILE_SIZE, 0.1, 4 * TILE_SIZE),
	]

	for i in equip_positions.size():
		var equip_spawn := Marker3D.new()
		equip_spawn.name = "EquipmentSpawn_%02d" % (i + 1)
		equip_spawn.position = equip_positions[i]
		add_child(equip_spawn)

	# Park benches (placeholder boxes)
	_create_prop(Vector3(3 * TILE_SIZE, 0.25, 3 * TILE_SIZE), Vector3(1.2, 0.5, 0.4), Color(0.45, 0.3, 0.15))
	_create_prop(Vector3(3 * TILE_SIZE, 0.25, 7 * TILE_SIZE), Vector3(1.2, 0.5, 0.4), Color(0.45, 0.3, 0.15))

	# Lighting — outdoor daylight
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-45, 30, 0)
	light.light_energy = 1.0
	light.shadow_enabled = true
	add_child(light)


func _setup_navigation() -> void:
	var nav_region := NavigationRegion3D.new()
	nav_region.name = "NavigationRegion3D"
	var nav_mesh := NavigationMesh.new()
	nav_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav_region.navigation_mesh = nav_mesh
	add_child(nav_region)
	nav_region.bake_navigation_mesh.call_deferred()


func _create_hint_ui() -> void:
	# Hint panel added to HUD via CanvasLayer
	var canvas := CanvasLayer.new()
	canvas.name = "HintLayer"
	add_child(canvas)

	_hint_panel = PanelContainer.new()
	_hint_panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_hint_panel.offset_top = -80
	_hint_panel.offset_bottom = -40
	_hint_panel.offset_left = -200
	_hint_panel.offset_right = 200
	_hint_panel.visible = false
	canvas.add_child(_hint_panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	_hint_panel.add_child(margin)

	_hint_label = Label.new()
	_hint_label.add_theme_font_size_override("font_size", 18)
	_hint_label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	margin.add_child(_hint_label)


func _show_hint(hint_id: String, text: String) -> void:
	if hint_id in _hints_shown:
		return
	_hints_shown[hint_id] = true

	_hint_label.text = text
	_hint_panel.visible = true

	# Auto-hide after 5 seconds
	await get_tree().create_timer(5.0).timeout
	if _hint_panel and _hint_panel.visible and _hint_label.text == text:
		_hint_panel.visible = false


func _wire_camera() -> void:
	var player: Node = _find_player()
	if not player:
		return

	for child in get_children():
		if child is Camera3D:
			if "target" in child:
				child.target = player
			break


func _set_ambient_audio() -> void:
	var root: Node = get_tree().current_scene
	if root:
		var audio_sys: Node = _find_node_by_method(root, "set_ambient")
		if audio_sys:
			# AudioSystem.AmbientType.TUTORIAL_PARK = 1
			audio_sys.set_ambient(1)


func _create_prop(pos: Vector3, box_size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)

	var mesh_inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = box_size
	mesh_inst.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_inst.material_override = mat
	body.add_child(mesh_inst)

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	col.shape = shape
	body.add_child(col)


func _find_player() -> Node:
	var players := get_tree().get_nodes_in_group("player")
	return players[0] if not players.is_empty() else null


func _load_scenario() -> void:
	var sm: Node = get_node_or_null("/root/ScenarioManager")
	if sm and sm.has_method("load_scenario"):
		sm.load_scenario("res://data/scenarios/scenario_tutorial.json")
		sm.start_scenario()


func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null
