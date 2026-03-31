## BuildingFireLevel — Interior rooms + exterior staging area.
## Fire effects, collapse zones, smoke obscuring visibility.
## 3 patients requiring extraction (rescue order matters).
extends Node3D

const TILE_SIZE := 2.0
const GRID_WIDTH := 14
const GRID_HEIGHT := 18

## Scene references for asset replacement.
var _floor_scene: PackedScene = null
var _grass_scene: PackedScene = null
var _sidewalk_scene: PackedScene = null

## Wall construction data.
const WALL_HEIGHT := 2.6
const WALL_THICKNESS := 0.15

## Fire/smoke zones for HazardSystem integration.
var _fire_zones: Array[Vector3] = []
var _collapse_zones: Array[Vector3] = []


func _ready() -> void:
	_floor_scene = load("res://scenes/environments/Sidewalk.tscn")
	_grass_scene = load("res://scenes/environments/Grass.tscn")
	_sidewalk_scene = load("res://scenes/environments/Sidewalk.tscn")

	#_generate_grid()  # Tiles already placed in BuildingFire.tscn — disabled to prevent overlap
	#_create_building_shell()  # [MANUAL] Team places Kenney building assets via Godot editor
	#_create_interior_walls()  # [MANUAL] Team places Kenney building assets via Godot editor
	#_place_furniture()  # [MANUAL] Team places assets via Godot editor
	#_place_fire_effects()  # Replaced by marker-based particle system below
	_spawn_fire_particles()
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


func _pick_tile(x: int, _z: int) -> PackedScene:
	# Interior floor (building spans x=2..11, z=0..11)
	# Exterior staging area (z=12..17)
	if _z >= 12:
		if x == 0 or x == GRID_WIDTH - 1:
			return _grass_scene
		return _sidewalk_scene  # Staging area pavement
	# Building interior
	if x >= 2 and x <= 11 and _z >= 0 and _z <= 11:
		return _floor_scene
	return _grass_scene


func _create_building_shell() -> void:
	# Building footprint: x=2..11, z=0..11 (10x12 tiles)
	var bx := 2.0 * TILE_SIZE
	var bw := 10.0 * TILE_SIZE
	var bh := 12.0 * TILE_SIZE

	# North wall (z=0)
	_create_wall_segment(
		Vector3(bx + bw / 2.0, WALL_HEIGHT / 2.0, -WALL_THICKNESS / 2.0),
		Vector3(bw, WALL_HEIGHT, WALL_THICKNESS)
	)
	# West wall (x=2)
	_create_wall_segment(
		Vector3(bx - WALL_THICKNESS / 2.0, WALL_HEIGHT / 2.0, bh / 2.0),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, bh)
	)
	# East wall (x=12)
	_create_wall_segment(
		Vector3(bx + bw + WALL_THICKNESS / 2.0, WALL_HEIGHT / 2.0, bh / 2.0),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, bh)
	)
	# South wall — with main entrance gap (z=12, gap at x=5..8)
	_create_wall_segment(
		Vector3(bx + 1.0 * TILE_SIZE, WALL_HEIGHT / 2.0, bh + WALL_THICKNESS / 2.0),
		Vector3(3.0 * TILE_SIZE, WALL_HEIGHT, WALL_THICKNESS),
		Color(0.5, 0.45, 0.4)  # Smoke-darkened
	)
	_create_wall_segment(
		Vector3(bx + bw - 1.0 * TILE_SIZE, WALL_HEIGHT / 2.0, bh + WALL_THICKNESS / 2.0),
		Vector3(3.0 * TILE_SIZE, WALL_HEIGHT, WALL_THICKNESS),
		Color(0.5, 0.45, 0.4)
	)


func _create_interior_walls() -> void:
	var bx := 2.0 * TILE_SIZE

	# Room 1 — front left (z=8..11, x=2..5): storage room
	_create_wall_segment(
		Vector3(bx + 4.0 * TILE_SIZE, WALL_HEIGHT / 2.0, 8.0 * TILE_SIZE),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, 4.0 * TILE_SIZE)
	)
	# Door gap in south partition for room 1
	_create_wall_segment(
		Vector3(bx + 1.0 * TILE_SIZE, WALL_HEIGHT / 2.0, 8.0 * TILE_SIZE - WALL_THICKNESS / 2.0),
		Vector3(2.0 * TILE_SIZE, WALL_HEIGHT, WALL_THICKNESS)
	)

	# Room 2 — front right (z=8..11, x=8..11): office
	_create_wall_segment(
		Vector3(bx + 6.0 * TILE_SIZE, WALL_HEIGHT / 2.0, 8.0 * TILE_SIZE),
		Vector3(WALL_THICKNESS, WALL_HEIGHT, 4.0 * TILE_SIZE)
	)

	# Corridor partition (z=4, runs across building with gaps)
	_create_wall_segment(
		Vector3(bx + 2.0 * TILE_SIZE, WALL_HEIGHT / 2.0, 4.0 * TILE_SIZE - WALL_THICKNESS / 2.0),
		Vector3(4.0 * TILE_SIZE, WALL_HEIGHT, WALL_THICKNESS)
	)
	_create_wall_segment(
		Vector3(bx + 8.0 * TILE_SIZE, WALL_HEIGHT / 2.0, 4.0 * TILE_SIZE - WALL_THICKNESS / 2.0),
		Vector3(4.0 * TILE_SIZE, WALL_HEIGHT, WALL_THICKNESS)
	)

	# Room 3 — back left (z=0..4, x=2..5): collapsed ceiling zone
	# Room 4 — back right (z=0..4, x=7..11): fire origin


func _create_wall_segment(pos: Vector3, wall_size: Vector3, color: Color = Color(0.75, 0.72, 0.68)) -> void:
	var body := StaticBody3D.new()
	body.position = pos
	add_child(body)

	var mesh_inst := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = wall_size
	mesh_inst.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mesh_inst.material_override = mat
	body.add_child(mesh_inst)

	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = wall_size
	col.shape = shape
	body.add_child(col)


## DISABLED -- team places Kenney assets manually in Godot editor
func _place_furniture() -> void:
	var bx := 2.0 * TILE_SIZE

	# Room 1 — storage shelves
	_create_prop(Vector3(bx + 0.5 * TILE_SIZE, 0.6, 9.0 * TILE_SIZE), Vector3(0.5, 1.2, 2.0), Color(0.5, 0.5, 0.5))
	_create_prop(Vector3(bx + 2.5 * TILE_SIZE, 0.6, 10.0 * TILE_SIZE), Vector3(0.5, 1.2, 1.0), Color(0.5, 0.5, 0.5))

	# Room 2 — office desks
	_create_prop(Vector3(bx + 7.0 * TILE_SIZE, 0.4, 9.5 * TILE_SIZE), Vector3(1.4, 0.8, 0.7), Color(0.5, 0.35, 0.2))
	_create_prop(Vector3(bx + 9.0 * TILE_SIZE, 0.4, 10.0 * TILE_SIZE), Vector3(1.4, 0.8, 0.7), Color(0.5, 0.35, 0.2))

	# Corridor — collapsed beam (hazard obstacle)
	_create_prop(Vector3(bx + 5.0 * TILE_SIZE, 0.15, 6.0 * TILE_SIZE), Vector3(4.0, 0.3, 0.25), Color(0.4, 0.35, 0.3))

	# Room 3 — collapsed ceiling debris
	_create_prop(Vector3(bx + 1.0 * TILE_SIZE, 0.3, 2.0 * TILE_SIZE), Vector3(2.0, 0.6, 1.5), Color(0.55, 0.5, 0.45))
	_create_prop(Vector3(bx + 2.0 * TILE_SIZE, 0.15, 1.0 * TILE_SIZE), Vector3(1.0, 0.3, 0.8), Color(0.6, 0.55, 0.5))

	# Room 4 — fire origin (charred furniture)
	_create_prop(Vector3(bx + 8.0 * TILE_SIZE, 0.3, 2.0 * TILE_SIZE), Vector3(1.0, 0.6, 0.8), Color(0.2, 0.15, 0.1))
	_create_prop(Vector3(bx + 9.0 * TILE_SIZE, 0.2, 1.0 * TILE_SIZE), Vector3(0.8, 0.4, 0.6), Color(0.25, 0.2, 0.1))

	# Staging area — ambulance placeholder (large white box)
	_create_prop(Vector3(3.0 * TILE_SIZE, 0.7, 15.0 * TILE_SIZE), Vector3(2.0, 1.4, 3.0), Color(0.95, 0.95, 0.95))
	# Triage tarps
	_create_prop(Vector3(8.0 * TILE_SIZE, 0.02, 14.0 * TILE_SIZE), Vector3(3.0, 0.04, 2.0), Color(0.2, 0.5, 0.8))


## DISABLED — old hardcoded fire effects replaced by marker-based particle system (_spawn_fire_particles).
## Hazard damage now comes from scenario JSON hazards array matched to FireSpawnSmoke marker positions.
#func _place_fire_effects() -> void:
#	var bx := 2.0 * TILE_SIZE
#	_fire_zones = [
#		Vector3(bx + 8.5 * TILE_SIZE, 0.0, 1.5 * TILE_SIZE),
#		Vector3(bx + 7.0 * TILE_SIZE, 0.0, 3.0 * TILE_SIZE),
#		Vector3(bx + 9.5 * TILE_SIZE, 0.0, 3.0 * TILE_SIZE),
#	]
#	_collapse_zones = [
#		Vector3(bx + 1.5 * TILE_SIZE, 0.0, 2.0 * TILE_SIZE),
#	]
#	for fire_pos in _fire_zones:
#		var fire_light := OmniLight3D.new()
#		fire_light.position = fire_pos + Vector3(0, 1.0, 0)
#		fire_light.light_color = Color(1.0, 0.4, 0.05)
#		fire_light.light_energy = 3.0
#		fire_light.omni_range = 5.0
#		add_child(fire_light)
#		var glow := OmniLight3D.new()
#		glow.position = fire_pos + Vector3(0, 0.3, 0)
#		glow.light_color = Color(1.0, 0.2, 0.0)
#		glow.light_energy = 1.5
#		glow.omni_range = 3.0
#		add_child(glow)
#	for collapse_pos in _collapse_zones:
#		var dark := OmniLight3D.new()
#		dark.position = collapse_pos + Vector3(0, 1.5, 0)
#		dark.light_color = Color(0.3, 0.25, 0.2)
#		dark.light_energy = -0.5
#		dark.omni_range = 4.0
#		add_child(dark)


## Spawn fire and smoke particles at FireSpawnSmoke marker positions.
## FireSpawnSmoke 1-3: fire particles + smoke + fire circle on ground + orange light
## FireSpawnSmoke 4-5: smoke only + dim light
## Also populates _fire_zones for HazardSystem integration.
func _spawn_fire_particles() -> void:
	var spawns_node: Node = get_node_or_null("Spawns")
	if not spawns_node:
		push_warning("BuildingFireLevel: No Spawns node found — skipping fire particles")
		return

	_fire_zones.clear()

	# FireSpawnSmoke 1-3: fire + smoke + fire circle
	for i in range(1, 4):
		var marker_name: String = "FireSpawnSmoke" if i == 1 else "FireSpawnSmoke%d" % i
		var marker: Node3D = spawns_node.get_node_or_null(marker_name)
		if not marker:
			continue
		var pos: Vector3 = marker.global_position
		_fire_zones.append(pos)
		_create_fire_and_smoke(pos)
		_create_fire_circle(pos)

	# FireSpawnSmoke 4-5: smoke only
	for i in range(4, 6):
		var marker_name: String = "FireSpawnSmoke%d" % i
		var marker: Node3D = spawns_node.get_node_or_null(marker_name)
		if not marker:
			continue
		_create_smoke_only(marker.global_position)


## Create fire particles + smoke particles + orange point light at a position.
func _create_fire_and_smoke(pos: Vector3) -> void:
	# Fire particles (orange/yellow, rising)
	var fire := GPUParticles3D.new()
	fire.position = pos + Vector3(0, 0.5, 0)
	fire.amount = 40
	fire.lifetime = 1.2
	fire.explosiveness = 0.1
	fire.randomness = 0.3

	var fire_mat := ParticleProcessMaterial.new()
	fire_mat.direction = Vector3(0, 1, 0)
	fire_mat.spread = 15.0
	fire_mat.initial_velocity_min = 1.0
	fire_mat.initial_velocity_max = 2.5
	fire_mat.gravity = Vector3(0, 1.0, 0)
	fire_mat.scale_min = 0.3
	fire_mat.scale_max = 0.8
	fire_mat.color = Color(1.0, 0.5, 0.05, 0.85)
	var fire_gradient := Gradient.new()
	fire_gradient.add_point(0.0, Color(1.0, 0.8, 0.1, 1.0))
	fire_gradient.add_point(0.4, Color(1.0, 0.35, 0.0, 0.9))
	fire_gradient.add_point(1.0, Color(0.3, 0.1, 0.0, 0.0))
	var fire_color_ramp := GradientTexture1D.new()
	fire_color_ramp.gradient = fire_gradient
	fire_mat.color_ramp = fire_color_ramp
	fire.process_material = fire_mat

	var fire_mesh := QuadMesh.new()
	fire_mesh.size = Vector2(0.4, 0.4)
	fire.draw_pass_1 = fire_mesh
	fire.emitting = true
	add_child(fire)

	# Smoke particles (dark gray, rising higher)
	_create_smoke_particles(pos)

	# Orange point light
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, 1.2, 0)
	light.light_color = Color(1.0, 0.4, 0.05)
	light.light_energy = 3.0
	light.omni_range = 5.0
	add_child(light)

	# Ground glow
	var glow := OmniLight3D.new()
	glow.position = pos + Vector3(0, 0.3, 0)
	glow.light_color = Color(1.0, 0.2, 0.0)
	glow.light_energy = 1.5
	glow.omni_range = 3.0
	add_child(glow)


## Create a fire circle ring on the ground (glowing orange/red ring at floor level).
## Uses a cylinder mesh flattened into a ring shape — visible from isometric camera.
func _create_fire_circle(pos: Vector3) -> void:
	var radius: float = 3.0

	# Ring — use a CylinderMesh with very small height as a flat disc outline
	# Outer disc (slightly larger, orange)
	var outer := MeshInstance3D.new()
	outer.position = pos + Vector3(0, 0.03, 0)
	var outer_cyl := CylinderMesh.new()
	outer_cyl.top_radius = radius
	outer_cyl.bottom_radius = radius
	outer_cyl.height = 0.05
	outer_cyl.radial_segments = 32
	outer.mesh = outer_cyl
	var outer_mat := StandardMaterial3D.new()
	outer_mat.albedo_color = Color(1.0, 0.25, 0.0, 0.5)
	outer_mat.emission_enabled = true
	outer_mat.emission = Color(1.0, 0.3, 0.0)
	outer_mat.emission_energy_multiplier = 1.5
	outer_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	outer_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	outer_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	outer.material_override = outer_mat
	add_child(outer)

	# Inner cutout (slightly smaller, black transparent to create ring effect)
	var inner := MeshInstance3D.new()
	inner.position = pos + Vector3(0, 0.06, 0)
	var inner_cyl := CylinderMesh.new()
	inner_cyl.top_radius = radius - 0.3
	inner_cyl.bottom_radius = radius - 0.3
	inner_cyl.height = 0.05
	inner_cyl.radial_segments = 32
	inner.mesh = inner_cyl
	var inner_mat := StandardMaterial3D.new()
	inner_mat.albedo_color = Color(0.0, 0.0, 0.0, 0.0)
	inner_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	inner_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	inner_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	inner.material_override = inner_mat
	add_child(inner)


## Create smoke-only particles + dim ambient light at a position.
func _create_smoke_only(pos: Vector3) -> void:
	_create_smoke_particles(pos)

	# Dim warm light (smoke glow, much less intense than fire)
	var light := OmniLight3D.new()
	light.position = pos + Vector3(0, 1.0, 0)
	light.light_color = Color(0.4, 0.3, 0.2)
	light.light_energy = 0.8
	light.omni_range = 3.5
	add_child(light)


## Create smoke particles at a position (shared by fire+smoke and smoke-only).
func _create_smoke_particles(pos: Vector3) -> void:
	var smoke := GPUParticles3D.new()
	smoke.position = pos + Vector3(0, 1.0, 0)
	smoke.amount = 25
	smoke.lifetime = 2.5
	smoke.explosiveness = 0.05
	smoke.randomness = 0.5

	var smoke_mat := ParticleProcessMaterial.new()
	smoke_mat.direction = Vector3(0, 1, 0)
	smoke_mat.spread = 25.0
	smoke_mat.initial_velocity_min = 0.5
	smoke_mat.initial_velocity_max = 1.5
	smoke_mat.gravity = Vector3(0, 0.3, 0)
	smoke_mat.scale_min = 0.5
	smoke_mat.scale_max = 1.5
	smoke_mat.color = Color(0.2, 0.2, 0.2, 0.6)
	var smoke_gradient := Gradient.new()
	smoke_gradient.add_point(0.0, Color(0.3, 0.3, 0.3, 0.7))
	smoke_gradient.add_point(0.5, Color(0.2, 0.2, 0.2, 0.4))
	smoke_gradient.add_point(1.0, Color(0.15, 0.15, 0.15, 0.0))
	var smoke_color_ramp := GradientTexture1D.new()
	smoke_color_ramp.gradient = smoke_gradient
	smoke_mat.color_ramp = smoke_color_ramp
	smoke.process_material = smoke_mat

	var smoke_mesh := QuadMesh.new()
	smoke_mesh.size = Vector2(0.6, 0.6)
	smoke.draw_pass_1 = smoke_mesh
	smoke.emitting = true
	add_child(smoke)


func _place_spawn_markers() -> void:
	var bx := 2.0 * TILE_SIZE

	# Player spawn — staging area (safe zone)
	var player_spawn := Marker3D.new()
	player_spawn.name = "PlayerSpawn"
	player_spawn.position = Vector3(7 * TILE_SIZE, 0.1, 16 * TILE_SIZE)
	add_child(player_spawn)

	# Patient 1 — Room 2 office (conscious, ambulatory, can be led out)
	var p1 := Marker3D.new()
	p1.name = "PatientSpawn_01"
	p1.position = Vector3(bx + 8.0 * TILE_SIZE, 0.1, 9.0 * TILE_SIZE)
	add_child(p1)

	# Patient 2 — Corridor (unconscious, trapped under beam)
	var p2 := Marker3D.new()
	p2.name = "PatientSpawn_02"
	p2.position = Vector3(bx + 5.0 * TILE_SIZE, 0.1, 5.5 * TILE_SIZE)
	add_child(p2)

	# Patient 3 — Room 3 collapse zone (critical, requires immediate extraction)
	var p3 := Marker3D.new()
	p3.name = "PatientSpawn_03"
	p3.position = Vector3(bx + 2.0 * TILE_SIZE, 0.1, 3.0 * TILE_SIZE)
	add_child(p3)

	# Equipment spawns — staging area (must carry in)
	var equip_positions := [
		Vector3(6 * TILE_SIZE, 0.1, 14 * TILE_SIZE),   # First aid kit
		Vector3(8 * TILE_SIZE, 0.1, 14 * TILE_SIZE),   # Stretcher
		Vector3(10 * TILE_SIZE, 0.1, 15 * TILE_SIZE),  # Oxygen
		Vector3(4 * TILE_SIZE, 0.1, 16 * TILE_SIZE),   # AED
	]
	for i in equip_positions.size():
		var spawn := Marker3D.new()
		spawn.name = "EquipmentSpawn_%02d" % (i + 1)
		spawn.position = equip_positions[i]
		add_child(spawn)


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
	# Dim exterior ambient (overcast / smoke)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-40, 20, 0)
	sun.light_energy = 0.6
	sun.shadow_enabled = true
	sun.light_color = Color(0.9, 0.85, 0.75)  # Warm/smoky tint
	add_child(sun)

	# Staging area floodlight
	var flood := OmniLight3D.new()
	flood.position = Vector3(7 * TILE_SIZE, 4.0, 15 * TILE_SIZE)
	flood.light_energy = 2.0
	flood.light_color = Color(1.0, 0.95, 0.85)
	flood.omni_range = 12.0
	flood.shadow_enabled = true
	add_child(flood)

	# Interior emergency lighting (dim red)
	var bx := 2.0 * TILE_SIZE
	var emergency_positions := [
		Vector3(bx + 3.0 * TILE_SIZE, WALL_HEIGHT - 0.3, 10.0 * TILE_SIZE),
		Vector3(bx + 7.0 * TILE_SIZE, WALL_HEIGHT - 0.3, 10.0 * TILE_SIZE),
		Vector3(bx + 5.0 * TILE_SIZE, WALL_HEIGHT - 0.3, 6.0 * TILE_SIZE),
	]
	for epos in emergency_positions:
		var elight := OmniLight3D.new()
		elight.position = epos
		elight.light_color = Color(1.0, 0.2, 0.1)
		elight.light_energy = 0.8
		elight.omni_range = 5.0
		add_child(elight)


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
			# AudioSystem.AmbientType.FIRE_ALARM = 5
			audio_sys.set_ambient(5)


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
		sm.load_scenario("res://data/scenarios/scenario_fire.json")
		sm.start_scenario()


func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null
