## TestLevel — Generates a 10x10 tile grid for Phase 0 testing.
## Instances Road, Sidewalk, and Grass tile scenes in a mixed layout.
extends Node3D

## Tile size in world units (must match tile mesh size).
const TILE_SIZE := 2.0

## Grid dimensions.
const GRID_WIDTH := 10
const GRID_HEIGHT := 10

## Tile scene references.
var road_scene := preload("res://scenes/environments/Road.tscn")
var sidewalk_scene := preload("res://scenes/environments/Sidewalk.tscn")
var grass_scene := preload("res://scenes/environments/Grass.tscn")

## Reference to NavigationRegion3D for runtime navmesh baking.
@onready var nav_region: NavigationRegion3D = $NavigationRegion3D


func _ready() -> void:
	#_generate_grid()  # Tiles already placed in TestLevel.tscn — disabled to prevent overlap
	# Bake navmesh after tiles are placed
	nav_region.bake_navigation_mesh()
	# Wire camera target to player
	var camera := $IsometricCamera as Camera3D
	var player := $Player as CharacterBody3D
	if camera and player:
		camera.target = player


## Generate the 10x10 tile grid with a mixed layout.
## Layout: grass border, sidewalk ring, road center.
func _generate_grid() -> void:
	for x in range(GRID_WIDTH):
		for z in range(GRID_HEIGHT):
			var tile: Node3D = _pick_tile(x, z).instantiate()
			nav_region.add_child(tile)
			tile.position = Vector3(x * TILE_SIZE, 0.0, z * TILE_SIZE)


## Pick the appropriate tile type based on grid position.
## Outer 2 rows = grass, next ring = sidewalk, center = road.
func _pick_tile(x: int, z: int) -> PackedScene:
	var edge_dist := mini(mini(x, GRID_WIDTH - 1 - x), mini(z, GRID_HEIGHT - 1 - z))
	if edge_dist <= 1:
		return grass_scene
	elif edge_dist == 2:
		return sidewalk_scene
	else:
		return road_scene
