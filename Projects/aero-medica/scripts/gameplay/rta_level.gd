## RTALevel — Road Traffic Accident scenario environment.
## Generates a road intersection layout with placeholder vehicles,
## patient spawn points, equipment spawn points, and baked NavMesh.
## Phase 6 upgrade: emergency lights, debris, traffic hazard zone, enhanced visuals.
extends Node3D

## Tile size in world units (must match tile mesh size).
const TILE_SIZE := 2.0

## Grid dimensions — larger than test level for a proper scenario.
const GRID_WIDTH := 16
const GRID_HEIGHT := 16

## Road width in tiles from center (half-width of road band).
const ROAD_HALF_WIDTH := 2

## Tile scene references.
var road_scene := preload("res://scenes/environments/Road.tscn")
var sidewalk_scene := preload("res://scenes/environments/Sidewalk.tscn")
var grass_scene := preload("res://scenes/environments/Grass.tscn")

## Patient scene reference.
var patient_scene := preload("res://scenes/entities/patients/PatientBase.tscn")

## Reference to NavigationRegion3D for runtime navmesh baking.
@onready var nav_region: NavigationRegion3D = $NavigationRegion3D

## Spawn point containers (null-safe for V2 scene compatibility).
@onready var patient_spawns: Node3D = get_node_or_null("PatientSpawns")
@onready var equipment_spawns: Node3D = get_node_or_null("EquipmentSpawns")
@onready var vehicle_props: Node3D = get_node_or_null("VehicleProps")

## Whether the scene has hand-placed V2 content (skip procedural generation).
var _is_v2_scene: bool = false

## Emergency light animation state.
var _emergency_lights: Array[OmniLight3D] = []
var _emergency_timer: float = 0.0


func _ready() -> void:
	# Detect V2 hand-crafted scene by checking for NavigationRegion3D/Props node.
	# If present, all environment props are already placed in the editor — skip procedural generation.
	var props_node: Node3D = nav_region.get_node_or_null("Props") if nav_region else null
	_is_v2_scene = props_node != null

	if _is_v2_scene:
		# V2 scene: collect existing OmniLight3D nodes from Props subtree for emergency light animation.
		_collect_emergency_lights(props_node)
	else:
		# Legacy procedural generation path.
		#_generate_grid()  # Tiles already placed in RoadTrafficAccident.tscn — disabled to prevent overlap
		_place_vehicles()
		_place_debris()
		_place_spawn_markers()
		_place_emergency_vehicles()
		_setup_traffic_hazard_zone()

	# Bake navmesh after all static geometry is placed (both V1 and V2).
	nav_region.bake_navigation_mesh()
	# Wire camera target to player
	var camera: Camera3D = get_node_or_null("IsometricCamera") as Camera3D
	var player: CharacterBody3D = get_node_or_null("Player") as CharacterBody3D
	if camera and player:
		camera.target = player
	_set_ambient_audio()
	_load_scenario.call_deferred()


func _process(delta: float) -> void:
	# Animate emergency vehicle lights (alternating red/blue flash)
	_emergency_timer += delta
	for i in _emergency_lights.size():
		var light := _emergency_lights[i]
		var phase := _emergency_timer * 3.0 + i * PI
		light.light_energy = 1.0 + abs(sin(phase)) * 2.0


## Recursively collect all OmniLight3D nodes under a parent for emergency light animation.
## Used in V2 scenes where lights are already placed in the editor.
func _collect_emergency_lights(parent: Node) -> void:
	if parent is OmniLight3D:
		_emergency_lights.append(parent as OmniLight3D)
	for child in parent.get_children():
		_collect_emergency_lights(child)


## Generate the intersection tile grid.
## Layout: grass border → sidewalk ring → road cross-intersection in center.
func _generate_grid() -> void:
	for x in range(GRID_WIDTH):
		for z in range(GRID_HEIGHT):
			var tile: Node3D = _pick_tile(x, z).instantiate()
			nav_region.add_child(tile)
			tile.position = Vector3(x * TILE_SIZE, 0.0, z * TILE_SIZE)


## Pick tile type based on grid position.
## Creates a cross-shaped intersection: horizontal road band + vertical road band.
## Sidewalk lines the road edges. Everything else is grass.
func _pick_tile(x: int, z: int) -> PackedScene:
	var cx := GRID_WIDTH / 2
	var cz := GRID_HEIGHT / 2

	# Horizontal road band (runs east-west through center)
	var on_h_road := absf(z - cz) < ROAD_HALF_WIDTH
	# Vertical road band (runs north-south through center)
	var on_v_road := absf(x - cx) < ROAD_HALF_WIDTH

	if on_h_road or on_v_road:
		return road_scene

	# Sidewalk: one tile adjacent to road edges
	var near_h_road := absf(z - cz) == ROAD_HALF_WIDTH
	var near_v_road := absf(x - cx) == ROAD_HALF_WIDTH
	if near_h_road or near_v_road:
		return sidewalk_scene

	return grass_scene


## Place placeholder vehicle props (grey boxes representing crashed cars).
func _place_vehicles() -> void:
	# Vehicle 1: sedan on horizontal road, slightly off-center (as if swerved)
	_create_vehicle_box(
		Vector3(10.0 * TILE_SIZE, 0.0, 8.5 * TILE_SIZE),
		Vector3(2.0, 1.0, 1.0),
		25.0,
		Color(0.45, 0.45, 0.5)
	)
	# Vehicle 2: SUV on vertical road, angled into vehicle 1 (collision)
	_create_vehicle_box(
		Vector3(8.5 * TILE_SIZE, 0.0, 6.5 * TILE_SIZE),
		Vector3(2.4, 1.2, 1.2),
		-35.0,
		Color(0.55, 0.55, 0.6)
	)
	# Vehicle 3: small car stopped further back on horizontal road
	_create_vehicle_box(
		Vector3(5.0 * TILE_SIZE, 0.0, 7.5 * TILE_SIZE),
		Vector3(1.8, 0.9, 0.9),
		0.0,
		Color(0.6, 0.35, 0.35)
	)


## Create a single vehicle placeholder box.
func _create_vehicle_box(pos: Vector3, box_size: Vector3, angle_deg: float, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation_degrees.y = angle_deg

	var mesh_inst := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	box_mesh.material = mat
	mesh_inst.mesh = box_mesh
	mesh_inst.position.y = box_size.y / 2.0

	var col_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	col_shape.shape = shape
	col_shape.position.y = box_size.y / 2.0

	body.add_child(mesh_inst)
	body.add_child(col_shape)
	vehicle_props.add_child(body)


## Place spawn point markers for patients and equipment.
## These are Marker3D nodes at defined positions — ScenarioManager reads them.
func _place_spawn_markers() -> void:
	# Patient spawn points — around the crash site
	_add_marker(patient_spawns, "PatientSpawn_01", Vector3(9.0 * TILE_SIZE, 0.0, 9.0 * TILE_SIZE))
	_add_marker(patient_spawns, "PatientSpawn_02", Vector3(11.0 * TILE_SIZE, 0.0, 7.0 * TILE_SIZE))
	_add_marker(patient_spawns, "PatientSpawn_03", Vector3(7.0 * TILE_SIZE, 0.0, 6.0 * TILE_SIZE))

	# Equipment spawn points
	_add_marker(equipment_spawns, "EquipSpawn_AED", Vector3(4.0 * TILE_SIZE, 0.0, 10.0 * TILE_SIZE))
	_add_marker(equipment_spawns, "EquipSpawn_Bandages", Vector3(10.0 * TILE_SIZE, 0.0, 10.0 * TILE_SIZE))
	_add_marker(equipment_spawns, "EquipSpawn_Stretcher", Vector3(12.0 * TILE_SIZE, 0.0, 11.0 * TILE_SIZE))


## Add a Marker3D to a parent node at the given position.
func _add_marker(parent: Node3D, marker_name: String, pos: Vector3) -> void:
	var marker := Marker3D.new()
	marker.name = marker_name
	marker.position = pos
	parent.add_child(marker)


## Place scattered debris around the crash site.
func _place_debris() -> void:
	var debris_items := [
		[Vector3(9.5 * TILE_SIZE, 0.05, 8.0 * TILE_SIZE), Vector3(0.4, 0.1, 0.3), Color(0.5, 0.5, 0.55)],
		[Vector3(10.5 * TILE_SIZE, 0.05, 9.0 * TILE_SIZE), Vector3(0.3, 0.1, 0.2), Color(0.55, 0.55, 0.6)],
		[Vector3(8.0 * TILE_SIZE, 0.05, 7.0 * TILE_SIZE), Vector3(0.5, 0.15, 0.4), Color(0.4, 0.4, 0.45)],
		[Vector3(11.0 * TILE_SIZE, 0.05, 8.5 * TILE_SIZE), Vector3(0.2, 0.08, 0.5), Color(0.35, 0.35, 0.4)],
		[Vector3(9.0 * TILE_SIZE, 0.05, 6.5 * TILE_SIZE), Vector3(0.6, 0.12, 0.15), Color(0.6, 0.4, 0.3)],
		[Vector3(7.5 * TILE_SIZE, 0.05, 8.0 * TILE_SIZE), Vector3(0.3, 0.08, 0.3), Color(0.3, 0.3, 0.35)],
		[Vector3(10.0 * TILE_SIZE, 0.1, 7.0 * TILE_SIZE), Vector3(0.8, 0.05, 0.15), Color(0.7, 0.3, 0.2)],
	]
	for item in debris_items:
		_create_debris_box(item[0], item[1], item[2])


func _create_debris_box(pos: Vector3, box_size: Vector3, color: Color) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	body.rotation_degrees.y = randf_range(-45.0, 45.0)
	vehicle_props.add_child(body)

	var mesh_inst := MeshInstance3D.new()
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	box_mesh.material = mat
	mesh_inst.mesh = box_mesh
	mesh_inst.position.y = box_size.y / 2.0
	body.add_child(mesh_inst)

	var col_shape := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	col_shape.shape = shape
	col_shape.position.y = box_size.y / 2.0
	body.add_child(col_shape)


## Place emergency vehicles with flashing lights.
func _place_emergency_vehicles() -> void:
	# Ambulance — parked on sidewalk (white box)
	_create_vehicle_box(
		Vector3(3.0 * TILE_SIZE, 0.0, 9.0 * TILE_SIZE),
		Vector3(2.2, 1.5, 1.2),
		15.0,
		Color(0.95, 0.95, 0.95)
	)

	# Ambulance roof lights
	var red_l := OmniLight3D.new()
	red_l.position = Vector3(3.0 * TILE_SIZE, 2.0, 8.5 * TILE_SIZE)
	red_l.light_color = Color(1.0, 0.05, 0.05)
	red_l.light_energy = 2.0
	red_l.omni_range = 8.0
	add_child(red_l)
	_emergency_lights.append(red_l)

	var blue_l := OmniLight3D.new()
	blue_l.position = Vector3(3.0 * TILE_SIZE, 2.0, 9.5 * TILE_SIZE)
	blue_l.light_color = Color(0.1, 0.15, 1.0)
	blue_l.light_energy = 2.0
	blue_l.omni_range = 8.0
	add_child(blue_l)
	_emergency_lights.append(blue_l)

	# Fire truck — parked on road (red box)
	_create_vehicle_box(
		Vector3(13.0 * TILE_SIZE, 0.0, 10.0 * TILE_SIZE),
		Vector3(3.0, 1.8, 1.4),
		-5.0,
		Color(0.85, 0.15, 0.1)
	)

	var red_r := OmniLight3D.new()
	red_r.position = Vector3(13.0 * TILE_SIZE, 2.3, 10.0 * TILE_SIZE)
	red_r.light_color = Color(1.0, 0.1, 0.0)
	red_r.light_energy = 2.5
	red_r.omni_range = 10.0
	add_child(red_r)
	_emergency_lights.append(red_r)


## Create traffic hazard zone (danger area around crash site).
func _setup_traffic_hazard_zone() -> void:
	# Traffic cones marking hazard perimeter (small orange cylinders)
	var cone_positions := [
		Vector3(6.0 * TILE_SIZE, 0, 6.0 * TILE_SIZE),
		Vector3(6.0 * TILE_SIZE, 0, 10.0 * TILE_SIZE),
		Vector3(12.0 * TILE_SIZE, 0, 6.0 * TILE_SIZE),
		Vector3(12.0 * TILE_SIZE, 0, 10.0 * TILE_SIZE),
		Vector3(9.0 * TILE_SIZE, 0, 5.5 * TILE_SIZE),
		Vector3(9.0 * TILE_SIZE, 0, 10.5 * TILE_SIZE),
	]
	for pos in cone_positions:
		_create_traffic_cone(pos)


func _create_traffic_cone(pos: Vector3) -> void:
	var cone := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.05
	mesh.bottom_radius = 0.15
	mesh.height = 0.4
	cone.mesh = mesh
	cone.position = pos + Vector3(0, 0.2, 0)
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.5, 0.0)
	cone.material_override = mat
	add_child(cone)


func _set_ambient_audio() -> void:
	var root: Node = get_tree().current_scene
	if root:
		var audio_sys: Node = _find_node_by_method(root, "set_ambient")
		if audio_sys:
			# AudioSystem.AmbientType.RTA_TRAFFIC = 2
			audio_sys.set_ambient(2)


func _load_scenario() -> void:
	var sm: Node = get_node_or_null("/root/ScenarioManager")
	if sm and sm.has_method("load_scenario"):
		sm.load_scenario("res://data/scenarios/scenario_rta.json")
		sm.start_scenario()


func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null
