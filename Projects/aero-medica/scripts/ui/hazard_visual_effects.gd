## HazardVisualEffects — Visual effects for environmental hazards.
## Fire particles + OmniLight3D, smoke particles, collapse dust + barrier,
## traffic warning flashers, zone boundary rings, screen-edge warning.
## Attaches to HazardZone nodes — created by HazardSystem.
extends Node

## Hazard type constants (matching HazardZone.HazardType enum).
const TYPE_FIRE := 0
const TYPE_COLLAPSE := 1
const TYPE_TRAFFIC := 2

## Zone border colours.
const BORDER_FIRE := Color(1.0, 0.2, 0.0, 0.3)
const BORDER_COLLAPSE := Color(1.0, 1.0, 0.0, 0.3)
const BORDER_TRAFFIC := Color(1.0, 0.5, 0.0, 0.3)

## Max particles per system (performance budget).
const MAX_FIRE_PARTICLES := 64
const MAX_SMOKE_PARTICLES := 32
const MAX_DUST_PARTICLES := 24

## Active visual effect nodes per hazard zone (zone Node → Dictionary of effect nodes).
var _effects: Dictionary = {}

## Screen warning overlay reference.
var _warning_overlay: ColorRect = null

## Whether player is currently inside any hazard.
var _player_in_hazard: bool = false

## Warning pulse tween.
var _warning_tween: Tween = null


func _ready() -> void:
	_wire_hazard_system.call_deferred()


func _wire_hazard_system() -> void:
	await get_tree().process_frame

	var root: Node = get_tree().current_scene
	if not root:
		return

	# Find HazardSystem in scene tree
	var hazard_sys: Node = _find_node_by_method(root, "get_active_hazards")
	if hazard_sys:
		hazard_sys.hazard_activated.connect(_on_hazard_activated)
		hazard_sys.hazard_expanded.connect(_on_hazard_expanded)
		hazard_sys.entity_in_hazard.connect(_on_entity_in_hazard)
		hazard_sys.entity_left_hazard.connect(_on_entity_left_hazard)

		# Apply effects to already-active hazards
		for zone in hazard_sys.get_active_hazards():
			_create_effects_for_zone(zone)

	# Create screen warning overlay on the HUD CanvasLayer
	_create_warning_overlay()


## Create visual effects for a hazard zone.
func _on_hazard_activated(zone: Node) -> void:
	_create_effects_for_zone(zone)


## Update fire effects when hazard expands.
func _on_hazard_expanded(zone: Node) -> void:
	if zone in _effects:
		var fx: Dictionary = _effects[zone]
		var radius: float = zone.radius if "radius" in zone else 3.0
		_update_fire_radius(fx, radius)


## Player enters hazard — flash screen edge.
func _on_entity_in_hazard(entity: Node3D, _hazard_type: String) -> void:
	if entity.is_in_group("player"):
		_player_in_hazard = true
		_start_warning_flash()


## Player exits hazard — stop warning.
func _on_entity_left_hazard(entity: Node3D, _hazard_type: String) -> void:
	if entity.is_in_group("player"):
		_player_in_hazard = false
		_stop_warning_flash()


## Create all visual effect nodes for a hazard zone.
func _create_effects_for_zone(zone: Node) -> void:
	if zone in _effects:
		return  # Already created

	var fx: Dictionary = {}
	var hazard_type: int = zone.hazard_type if "hazard_type" in zone else TYPE_FIRE
	var radius: float = zone.radius if "radius" in zone else 3.0

	match hazard_type:
		TYPE_FIRE:
			fx["fire"] = _create_fire_particles(zone, radius)
			fx["smoke"] = _create_smoke_particles(zone, radius)
			fx["light"] = _create_fire_light(zone, radius)
			fx["border"] = _create_zone_border(zone, radius, BORDER_FIRE)
		TYPE_COLLAPSE:
			fx["dust"] = _create_dust_particles(zone, radius)
			fx["barrier"] = _create_collapse_barrier(zone, radius)
			fx["border"] = _create_zone_border(zone, radius, BORDER_COLLAPSE)
		TYPE_TRAFFIC:
			fx["flasher"] = _create_traffic_flasher(zone, radius)
			fx["border"] = _create_zone_border(zone, radius, BORDER_TRAFFIC)

	_effects[zone] = fx


## Fire: orange/red flame particles.
func _create_fire_particles(zone: Node3D, radius: float) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = MAX_FIRE_PARTICLES
	particles.lifetime = 0.8
	particles.emitting = true

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = radius * 0.6
	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = 20.0
	mat.initial_velocity_min = 1.0
	mat.initial_velocity_max = 3.0
	mat.gravity = Vector3(0.0, 0.5, 0.0)
	mat.scale_min = 0.15
	mat.scale_max = 0.4
	mat.color = Color(1.0, 0.4, 0.1, 0.9)

	# Colour ramp: bright yellow → orange → dark red → transparent
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.9, 0.2, 1.0))
	gradient.add_point(0.3, Color(1.0, 0.4, 0.1, 0.9))
	gradient.add_point(0.7, Color(0.8, 0.1, 0.0, 0.6))
	gradient.set_color(1, Color(0.3, 0.0, 0.0, 0.0))
	var gradient_tex := GradientTexture1D.new()
	gradient_tex.gradient = gradient
	mat.color_ramp = gradient_tex

	particles.process_material = mat

	# Use simple quad mesh for particles
	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.3, 0.3)
	particles.draw_pass_1 = mesh

	zone.add_child(particles)
	return particles


## Smoke: grey particles rising from fire.
func _create_smoke_particles(zone: Node3D, radius: float) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = MAX_SMOKE_PARTICLES
	particles.lifetime = 2.0
	particles.emitting = true

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = radius * 0.4
	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = 15.0
	mat.initial_velocity_min = 0.5
	mat.initial_velocity_max = 1.5
	mat.gravity = Vector3(0.0, -0.2, 0.0)  # Slight negative = rises
	mat.scale_min = 0.3
	mat.scale_max = 0.8

	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.3, 0.3, 0.3, 0.0))
	gradient.add_point(0.2, Color(0.4, 0.4, 0.4, 0.5))
	gradient.add_point(0.6, Color(0.3, 0.3, 0.3, 0.3))
	gradient.set_color(1, Color(0.2, 0.2, 0.2, 0.0))
	var gradient_tex := GradientTexture1D.new()
	gradient_tex.gradient = gradient
	mat.color_ramp = gradient_tex

	particles.process_material = mat
	particles.position.y = 1.0  # Start above fire

	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.5, 0.5)
	particles.draw_pass_1 = mesh

	zone.add_child(particles)
	return particles


## Fire light: warm OmniLight3D that scales with radius.
func _create_fire_light(zone: Node3D, radius: float) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.5, 0.1)
	light.light_energy = 1.5
	light.omni_range = radius * 1.5
	light.omni_attenuation = 1.5
	light.position.y = 0.5
	light.shadow_enabled = false  # Performance

	zone.add_child(light)
	return light


## Collapse: dust particles.
func _create_dust_particles(zone: Node3D, radius: float) -> GPUParticles3D:
	var particles := GPUParticles3D.new()
	particles.amount = MAX_DUST_PARTICLES
	particles.lifetime = 3.0
	particles.emitting = true

	var mat := ParticleProcessMaterial.new()
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_SPHERE
	mat.emission_sphere_radius = radius * 0.8
	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = 45.0
	mat.initial_velocity_min = 0.2
	mat.initial_velocity_max = 0.8
	mat.gravity = Vector3(0.0, 0.3, 0.0)
	mat.scale_min = 0.1
	mat.scale_max = 0.3

	var gradient := Gradient.new()
	gradient.set_color(0, Color(0.6, 0.5, 0.4, 0.0))
	gradient.add_point(0.3, Color(0.6, 0.5, 0.4, 0.4))
	gradient.set_color(1, Color(0.5, 0.4, 0.3, 0.0))
	var gradient_tex := GradientTexture1D.new()
	gradient_tex.gradient = gradient
	mat.color_ramp = gradient_tex

	particles.process_material = mat

	var mesh := QuadMesh.new()
	mesh.size = Vector2(0.2, 0.2)
	particles.draw_pass_1 = mesh

	zone.add_child(particles)
	return particles


## Collapse barrier: simple box mesh with DANGER indication.
func _create_collapse_barrier(zone: Node3D, radius: float) -> MeshInstance3D:
	var barrier := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(radius * 2.0, 0.3, radius * 2.0)
	barrier.mesh = box

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.5, 0.4, 0.2, 0.4)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	barrier.material_override = mat
	barrier.position.y = 0.01  # Just above ground

	zone.add_child(barrier)
	return barrier


## Traffic: flashing warning indicator.
func _create_traffic_flasher(zone: Node3D, radius: float) -> OmniLight3D:
	var light := OmniLight3D.new()
	light.light_color = Color(1.0, 0.6, 0.0)
	light.light_energy = 0.0
	light.omni_range = radius * 1.2
	light.omni_attenuation = 2.0
	light.position.y = 1.0
	light.shadow_enabled = false

	zone.add_child(light)

	# Flash tween — syncs with traffic danger window
	var tween := zone.create_tween()
	tween.set_loops()
	tween.tween_property(light, "light_energy", 2.0, 0.3)
	tween.tween_property(light, "light_energy", 0.0, 0.3)
	tween.tween_interval(0.8)

	return light


## Semi-transparent zone boundary ring.
func _create_zone_border(zone: Node3D, radius: float, colour: Color) -> MeshInstance3D:
	var border := MeshInstance3D.new()

	# Use a torus mesh to create a ring, or fallback to a cylinder
	var cyl := CylinderMesh.new()
	cyl.top_radius = radius
	cyl.bottom_radius = radius
	cyl.height = 0.05
	cyl.radial_segments = 32
	cyl.rings = 1
	border.mesh = cyl

	var mat := StandardMaterial3D.new()
	mat.albedo_color = colour
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	border.material_override = mat
	border.position.y = 0.05

	zone.add_child(border)
	return border


## Update fire particle radius when hazard expands.
func _update_fire_radius(fx: Dictionary, new_radius: float) -> void:
	# Update fire emission radius
	if "fire" in fx:
		var fire: GPUParticles3D = fx["fire"]
		if fire and fire.process_material is ParticleProcessMaterial:
			fire.process_material.emission_sphere_radius = new_radius * 0.6

	# Update smoke emission radius
	if "smoke" in fx:
		var smoke: GPUParticles3D = fx["smoke"]
		if smoke and smoke.process_material is ParticleProcessMaterial:
			smoke.process_material.emission_sphere_radius = new_radius * 0.4

	# Update light range
	if "light" in fx:
		var light: OmniLight3D = fx["light"]
		if light:
			light.omni_range = new_radius * 1.5

	# Update border
	if "border" in fx:
		var border: MeshInstance3D = fx["border"]
		if border and border.mesh is CylinderMesh:
			border.mesh.top_radius = new_radius
			border.mesh.bottom_radius = new_radius


## Create screen edge warning overlay on the HUD layer.
func _create_warning_overlay() -> void:
	# Find the CanvasLayer parent (HUD)
	var parent: Node = get_parent()
	if not parent:
		return

	_warning_overlay = ColorRect.new()
	_warning_overlay.color = Color(1.0, 0.0, 0.0, 0.0)
	_warning_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_warning_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_warning_overlay.visible = false
	parent.add_child(_warning_overlay)


## Start screen edge warning flash.
func _start_warning_flash() -> void:
	if not _warning_overlay:
		return
	_warning_overlay.visible = true
	_stop_warning_flash_tween()

	_warning_tween = _warning_overlay.create_tween()
	_warning_tween.set_loops()
	_warning_tween.tween_property(_warning_overlay, "color:a", 0.15, 0.4)
	_warning_tween.tween_property(_warning_overlay, "color:a", 0.0, 0.4)


## Stop screen edge warning flash.
func _stop_warning_flash() -> void:
	_stop_warning_flash_tween()
	if _warning_overlay:
		_warning_overlay.color.a = 0.0
		_warning_overlay.visible = false


func _stop_warning_flash_tween() -> void:
	if _warning_tween:
		_warning_tween.kill()
		_warning_tween = null


## Find a node with a specific method in the tree.
func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null


## Cleanup all effects.
func cleanup() -> void:
	for zone in _effects:
		var fx: Dictionary = _effects[zone]
		for key in fx:
			var node: Node = fx[key]
			if is_instance_valid(node):
				node.queue_free()
	_effects.clear()
	_stop_warning_flash()
