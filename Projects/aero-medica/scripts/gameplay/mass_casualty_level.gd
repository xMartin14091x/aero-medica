## MassCasualtyLevel — Large outdoor area with multiple patients.
## Park/plaza layout requiring triage prioritisation and movement strategy.
## 5+ patient spawn points, limited equipment, open layout.
extends Node3D

const TILE_SIZE := 2.0
const GRID_WIDTH := 20
const GRID_HEIGHT := 20

## Scene references for asset replacement.
var _road_scene: PackedScene = null
var _sidewalk_scene: PackedScene = null
var _grass_scene: PackedScene = null


func _ready() -> void:
	_road_scene = load("res://scenes/environments/Road.tscn")
	_sidewalk_scene = load("res://scenes/environments/Sidewalk.tscn")
	_grass_scene = load("res://scenes/environments/Grass.tscn")

	#_generate_grid()  # Tiles already placed in MassCasualty.tscn — disabled to prevent overlap
	#_place_props()  # [MANUAL] Team places assets via Godot editor
	_place_spawn_markers()
	_setup_navigation()
	_setup_lighting()
	_wire_camera()
	_set_ambient_audio()
	_load_scenario.call_deferred()


func _generate_grid() -> void:
	for x in GRID_WIDTH:
		for z in GRID_HEIGHT:
			var tile: Node3D = _pick_tile(x, z).instantiate()
			tile.position = Vector3(x * TILE_SIZE, 0, z * TILE_SIZE)
			add_child(tile)


func _pick_tile(x: int, z: int) -> PackedScene:
	# Layout: road perimeter, sidewalk ring, large open grass/park center
	# Road on edges (simulating surrounding streets)
	if x == 0 or x == GRID_WIDTH - 1 or z == 0 or z == GRID_HEIGHT - 1:
		return _road_scene
	# Sidewalk just inside the road
	if x == 1 or x == GRID_WIDTH - 2 or z == 1 or z == GRID_HEIGHT - 2:
		return _sidewalk_scene
	# Cross-paths through the park
	if x == GRID_WIDTH / 2 or z == GRID_HEIGHT / 2:
		return _sidewalk_scene
	# Diagonal paths (approximate)
	if absi(x - z) <= 1 and x >= 4 and x <= 16:
		return _sidewalk_scene
	return _grass_scene


## DISABLED -- team places Kenney assets manually in Godot editor
func _place_props() -> void:
	# Park benches along paths
	_create_prop(Vector3(5 * TILE_SIZE, 0.25, 10 * TILE_SIZE), Vector3(1.2, 0.5, 0.4), Color(0.45, 0.3, 0.15))
	_create_prop(Vector3(15 * TILE_SIZE, 0.25, 10 * TILE_SIZE), Vector3(1.2, 0.5, 0.4), Color(0.45, 0.3, 0.15))
	_create_prop(Vector3(10 * TILE_SIZE, 0.25, 5 * TILE_SIZE), Vector3(1.2, 0.5, 0.4), Color(0.45, 0.3, 0.15))
	_create_prop(Vector3(10 * TILE_SIZE, 0.25, 15 * TILE_SIZE), Vector3(1.2, 0.5, 0.4), Color(0.45, 0.3, 0.15))

	# Fountain in center (large cylinder placeholder)
	var fountain := StaticBody3D.new()
	fountain.position = Vector3(10 * TILE_SIZE, 0.0, 10 * TILE_SIZE)
	add_child(fountain)

	var mesh_inst := MeshInstance3D.new()
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = 1.5
	cylinder.bottom_radius = 1.8
	cylinder.height = 0.8
	mesh_inst.mesh = cylinder
	mesh_inst.position.y = 0.4
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.65, 0.65, 0.7)
	mesh_inst.material_override = mat
	fountain.add_child(mesh_inst)

	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 1.8
	shape.height = 0.8
	col.shape = shape
	col.position.y = 0.4
	fountain.add_child(col)

	# Trees (tall green cylinders)
	var tree_positions := [
		Vector3(4 * TILE_SIZE, 0, 4 * TILE_SIZE),
		Vector3(16 * TILE_SIZE, 0, 4 * TILE_SIZE),
		Vector3(4 * TILE_SIZE, 0, 16 * TILE_SIZE),
		Vector3(16 * TILE_SIZE, 0, 16 * TILE_SIZE),
		Vector3(7 * TILE_SIZE, 0, 7 * TILE_SIZE),
		Vector3(13 * TILE_SIZE, 0, 13 * TILE_SIZE),
	]
	for pos in tree_positions:
		_create_tree(pos)

	# Overturned vendor cart (incident cause)
	_create_prop(Vector3(11 * TILE_SIZE, 0.3, 9 * TILE_SIZE), Vector3(1.5, 0.6, 0.8), Color(0.6, 0.3, 0.2))

	# Debris scatter near center
	_create_prop(Vector3(9 * TILE_SIZE, 0.1, 11 * TILE_SIZE), Vector3(0.5, 0.2, 0.3), Color(0.5, 0.5, 0.5))
	_create_prop(Vector3(12 * TILE_SIZE, 0.1, 8 * TILE_SIZE), Vector3(0.4, 0.2, 0.6), Color(0.5, 0.5, 0.5))


func _place_spawn_markers() -> void:
	# Player spawn — at park entrance (south side)
	var player_spawn := Marker3D.new()
	player_spawn.name = "PlayerSpawn"
	player_spawn.position = Vector3(10 * TILE_SIZE, 0.1, 18 * TILE_SIZE)
	add_child(player_spawn)

	# 6 patient spawns — scattered across the park
	var patient_positions := [
		Vector3(9 * TILE_SIZE, 0.1, 9 * TILE_SIZE),    # Near fountain
		Vector3(12 * TILE_SIZE, 0.1, 8 * TILE_SIZE),    # Near debris
		Vector3(6 * TILE_SIZE, 0.1, 12 * TILE_SIZE),    # On path
		Vector3(14 * TILE_SIZE, 0.1, 6 * TILE_SIZE),    # Near bench
		Vector3(8 * TILE_SIZE, 0.1, 15 * TILE_SIZE),    # South area
		Vector3(15 * TILE_SIZE, 0.1, 14 * TILE_SIZE),   # East area
	]
	for i in patient_positions.size():
		var spawn := Marker3D.new()
		spawn.name = "PatientSpawn_%02d" % (i + 1)
		spawn.position = patient_positions[i]
		add_child(spawn)

	# Limited equipment spawns — 3 kits for 6 patients (forces prioritisation)
	var equip_positions := [
		Vector3(2 * TILE_SIZE, 0.1, 10 * TILE_SIZE),    # West side
		Vector3(18 * TILE_SIZE, 0.1, 10 * TILE_SIZE),   # East side
		Vector3(10 * TILE_SIZE, 0.1, 2 * TILE_SIZE),    # North side
	]
	for i in equip_positions.size():
		var spawn := Marker3D.new()
		spawn.name = "EquipmentSpawn_%02d" % (i + 1)
		spawn.position = equip_positions[i]
		add_child(spawn)


## DISABLED -- team places Kenney assets manually in Godot editor
func _create_tree(pos: Vector3) -> void:
	var tree := StaticBody3D.new()
	tree.position = pos
	add_child(tree)

	# Trunk
	var trunk_mesh := MeshInstance3D.new()
	var trunk := CylinderMesh.new()
	trunk.top_radius = 0.15
	trunk.bottom_radius = 0.2
	trunk.height = 2.0
	trunk_mesh.mesh = trunk
	trunk_mesh.position.y = 1.0
	var trunk_mat := StandardMaterial3D.new()
	trunk_mat.albedo_color = Color(0.4, 0.25, 0.1)
	trunk_mesh.material_override = trunk_mat
	tree.add_child(trunk_mesh)

	# Canopy (sphere)
	var canopy_mesh := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.2
	sphere.height = 2.0
	canopy_mesh.mesh = sphere
	canopy_mesh.position.y = 2.8
	var canopy_mat := StandardMaterial3D.new()
	canopy_mat.albedo_color = Color(0.2, 0.55, 0.15)
	canopy_mesh.material_override = canopy_mat
	tree.add_child(canopy_mesh)

	# Collision for trunk only
	var col := CollisionShape3D.new()
	var shape := CylinderShape3D.new()
	shape.radius = 0.2
	shape.height = 2.0
	col.shape = shape
	col.position.y = 1.0
	tree.add_child(col)


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
	# Outdoor sunlight
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-50, 25, 0)
	sun.light_energy = 1.3
	sun.shadow_enabled = true
	add_child(sun)

	# Emergency vehicle lights (red/blue rotating effect — placeholder omni lights)
	var red_light := OmniLight3D.new()
	red_light.position = Vector3(1 * TILE_SIZE, 2.0, 10 * TILE_SIZE)
	red_light.light_color = Color(1.0, 0.1, 0.1)
	red_light.light_energy = 2.0
	red_light.omni_range = 8.0
	add_child(red_light)

	var blue_light := OmniLight3D.new()
	blue_light.position = Vector3(1 * TILE_SIZE, 2.0, 11 * TILE_SIZE)
	blue_light.light_color = Color(0.1, 0.2, 1.0)
	blue_light.light_energy = 2.0
	blue_light.omni_range = 8.0
	add_child(blue_light)


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
			# AudioSystem.AmbientType.MCI_CROWD = 4
			audio_sys.set_ambient(4)


## DISABLED -- team places Kenney assets manually in Godot editor
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
		sm.load_scenario("res://data/scenarios/scenario_mci.json")
		sm.start_scenario()


func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null
