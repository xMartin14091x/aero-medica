## CardiacArrestLevel — Indoor environment with single cardiac arrest patient.
## Office/room layout with AED and first aid kit nearby.
## Intimate lighting, focused single-patient scenario.
extends Node3D

const TILE_SIZE := 2.0
const GRID_WIDTH := 8
const GRID_HEIGHT := 10

## Scene references for asset replacement.
var _floor_scene: PackedScene = null
var _wall_scene: PackedScene = null

## Wall segment data.
const WALL_HEIGHT := 2.4
const WALL_THICKNESS := 0.15


func _ready() -> void:
	_floor_scene = load("res://scenes/environments/Sidewalk.tscn")

	#_generate_floor()  # Floor tiles already placed in CardiacArrest.tscn — disabled to prevent overlap
	_create_walls()
	_place_furniture()
	_place_spawn_markers()
	_setup_navigation()
	_setup_lighting()
	_wire_camera()
	_set_ambient_audio()
	_load_scenario.call_deferred()


func _generate_floor() -> void:
	for x in GRID_WIDTH:
		for z in GRID_HEIGHT:
			var tile: Node3D = _floor_scene.instantiate()
			tile.position = Vector3(x * TILE_SIZE, 0, z * TILE_SIZE)
			add_child(tile)


func _create_walls() -> void:
	# Outer walls — perimeter of the room
	# North wall (z = 0)
	_create_wall_segment(
		Vector3(GRID_WIDTH * TILE_SIZE / 2.0, WALL_HEIGHT / 2.0, -WALL_THICKNESS / 2.0),
		Vector3(GRID_WIDTH * TILE_SIZE, WALL_HEIGHT, WALL_THICKNESS)
	)
	# South wall (z = max)
	_create_wall_segment(
		Vector3(GRID_WIDTH * TILE_SIZE / 2.0, WALL_HEIGHT / 2.0, GRID_HEIGHT * TILE_SIZE + WALL_THICKNESS / 2.0),
		Vector3(GRID_WIDTH * TILE_SIZE, WALL_HEIGHT, WALL_THICKNESS)
	)
	# West wall (x = 0)
	_create_wall_segment(
		Vector3(-WALL_THICKNESS / 2.0, WALL_HEIGHT / 2.0, GRID_HEIGHT * TILE_SIZE / 2.0),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, GRID_HEIGHT * TILE_SIZE)
	)
	# East wall (x = max) — with doorway gap in the middle
	_create_wall_segment(
		Vector3(GRID_WIDTH * TILE_SIZE + WALL_THICKNESS / 2.0, WALL_HEIGHT / 2.0, 3.0 * TILE_SIZE / 2.0),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, 3.0 * TILE_SIZE)
	)
	_create_wall_segment(
		Vector3(GRID_WIDTH * TILE_SIZE + WALL_THICKNESS / 2.0, WALL_HEIGHT / 2.0, (GRID_HEIGHT - 1.5) * TILE_SIZE),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, 5.0 * TILE_SIZE)
	)

	# Internal partition — separates office area from entry hall
	_create_wall_segment(
		Vector3(3.0 * TILE_SIZE, WALL_HEIGHT / 2.0, 6.0 * TILE_SIZE),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, 4.0 * TILE_SIZE)
	)


func _create_wall_segment(pos: Vector3, wall_size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)

	var mesh_inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = wall_size
	mesh_inst.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.85, 0.82, 0.78)
	mesh_inst.material_override = mat
	body.add_child(mesh_inst)

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = wall_size
	col.shape = shape
	body.add_child(col)


func _place_furniture() -> void:
	# Office desk
	_create_prop(Vector3(2.0 * TILE_SIZE, 0.4, 2.0 * TILE_SIZE), Vector3(1.6, 0.8, 0.8), Color(0.5, 0.35, 0.2))
	# Office chair (small box)
	_create_prop(Vector3(2.0 * TILE_SIZE, 0.3, 3.0 * TILE_SIZE), Vector3(0.5, 0.6, 0.5), Color(0.25, 0.25, 0.3))
	# Filing cabinet
	_create_prop(Vector3(0.5 * TILE_SIZE, 0.6, 1.0 * TILE_SIZE), Vector3(0.6, 1.2, 0.5), Color(0.6, 0.6, 0.6))
	# Bookshelf
	_create_prop(Vector3(0.5 * TILE_SIZE, 0.8, 4.0 * TILE_SIZE), Vector3(0.5, 1.6, 1.0), Color(0.55, 0.35, 0.2))
	# Water cooler (entry hall)
	_create_prop(Vector3(5.0 * TILE_SIZE, 0.5, 8.0 * TILE_SIZE), Vector3(0.4, 1.0, 0.4), Color(0.7, 0.85, 0.9))
	# Collapsed patient placeholder (on the floor near desk)
	# Patient will be spawned at PatientSpawn_01 by ScenarioManager


func _place_spawn_markers() -> void:
	# Player spawn — at the doorway (east wall gap)
	var player_spawn := Marker3D.new()
	player_spawn.name = "PlayerSpawn"
	player_spawn.position = Vector3(GRID_WIDTH * TILE_SIZE - 0.5, 0.1, 5.0 * TILE_SIZE)
	add_child(player_spawn)

	# Patient spawn — on the floor next to desk (collapsed)
	var patient_spawn := Marker3D.new()
	patient_spawn.name = "PatientSpawn_01"
	patient_spawn.position = Vector3(2.5 * TILE_SIZE, 0.1, 3.5 * TILE_SIZE)
	add_child(patient_spawn)

	# Equipment spawns — AED on the wall, first aid kit nearby
	var aed_spawn := Marker3D.new()
	aed_spawn.name = "EquipmentSpawn_01"
	aed_spawn.position = Vector3(6.0 * TILE_SIZE, 0.1, 2.0 * TILE_SIZE)
	add_child(aed_spawn)

	var fak_spawn := Marker3D.new()
	fak_spawn.name = "EquipmentSpawn_02"
	fak_spawn.position = Vector3(5.0 * TILE_SIZE, 0.1, 1.0 * TILE_SIZE)
	add_child(fak_spawn)

	var oxy_spawn := Marker3D.new()
	oxy_spawn.name = "EquipmentSpawn_03"
	oxy_spawn.position = Vector3(6.5 * TILE_SIZE, 0.1, 8.0 * TILE_SIZE)
	add_child(oxy_spawn)


func _setup_navigation() -> void:
	var nav_region := NavigationRegion3D.new()
	nav_region.name = "NavigationRegion3D"
	var nav_mesh := NavigationMesh.new()
	nav_mesh.geometry_parsed_geometry_type = NavigationMesh.PARSED_GEOMETRY_STATIC_COLLIDERS
	nav_mesh.agent_radius = 0.3
	nav_mesh.agent_height = 1.4
	nav_region.navigation_mesh = nav_mesh
	add_child(nav_region)
	nav_region.bake_navigation_mesh.call_deferred()


func _setup_lighting() -> void:
	# Overhead fluorescent-style light (cool white)
	var ceiling_light := OmniLight3D.new()
	ceiling_light.position = Vector3(2.0 * TILE_SIZE, WALL_HEIGHT - 0.2, 3.0 * TILE_SIZE)
	ceiling_light.light_energy = 1.5
	ceiling_light.light_color = Color(0.95, 0.95, 1.0)
	ceiling_light.omni_range = 8.0
	ceiling_light.shadow_enabled = true
	add_child(ceiling_light)

	# Hallway light
	var hall_light := OmniLight3D.new()
	hall_light.position = Vector3(5.5 * TILE_SIZE, WALL_HEIGHT - 0.2, 7.0 * TILE_SIZE)
	hall_light.light_energy = 1.0
	hall_light.light_color = Color(1.0, 0.95, 0.9)
	hall_light.omni_range = 6.0
	add_child(hall_light)

	# Dim ambient from window (DirectionalLight with low energy)
	var window_light := DirectionalLight3D.new()
	window_light.rotation_degrees = Vector3(-30, 45, 0)
	window_light.light_energy = 0.3
	window_light.shadow_enabled = false
	add_child(window_light)


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
			# AudioSystem.AmbientType.CARDIAC_INDOOR = 3
			audio_sys.set_ambient(3)


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
		sm.load_scenario("res://data/scenarios/scenario_cardiac.json")
		sm.start_scenario()


func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null
