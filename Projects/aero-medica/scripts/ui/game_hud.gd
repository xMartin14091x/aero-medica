## GameHUD — Master in-game HUD overlay combining all existing UI elements.
## Adds minimap, equipment indicator, patient overview, and pause menu.
extends CanvasLayer

## Pause state.
var _paused: bool = false

## UI references.
var _minimap_rect: ColorRect = null
var _minimap_player_dot: ColorRect = null
var _minimap_patient_dots: Array[ColorRect] = []
var _equip_label: Label = null
var _patient_list: VBoxContainer = null
var _pause_overlay: PanelContainer = null

## Scene tracking for minimap.
var _player_ref: Node3D = null
var _world_bounds := Rect2(0, 0, 32, 32)  # Default, updated from level


func _ready() -> void:
	_build_minimap()
	_build_equipment_indicator()
	_build_patient_overview()
	_build_pause_overlay()
	_find_references.call_deferred()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_toggle_pause()


func _process(_delta: float) -> void:
	if _player_ref and is_instance_valid(_player_ref):
		_update_minimap()


func _build_minimap() -> void:
	# Top-left minimap
	var container := PanelContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	container.offset_left = 16
	container.offset_top = 16
	container.offset_right = 166
	container.offset_bottom = 166
	add_child(container)

	_minimap_rect = ColorRect.new()
	_minimap_rect.color = Color(0.1, 0.15, 0.2, 0.8)
	_minimap_rect.custom_minimum_size = Vector2(150, 150)
	container.add_child(_minimap_rect)

	# Label
	var label := Label.new()
	label.text = tr("HUD_MINIMAP")
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	label.position = Vector2(4, 2)
	_minimap_rect.add_child(label)

	# Player dot (blue)
	_minimap_player_dot = ColorRect.new()
	_minimap_player_dot.color = Color(0.3, 0.6, 1.0)
	_minimap_player_dot.custom_minimum_size = Vector2(6, 6)
	_minimap_player_dot.size = Vector2(6, 6)
	_minimap_rect.add_child(_minimap_player_dot)


func _build_equipment_indicator() -> void:
	# Bottom-left equipment display
	var container := PanelContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	container.offset_left = 16
	container.offset_bottom = -16
	container.offset_right = 200
	container.offset_top = -60
	add_child(container)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_bottom", 6)
	container.add_child(margin)

	var vbox := VBoxContainer.new()
	margin.add_child(vbox)

	var header := Label.new()
	header.text = tr("HUD_EQUIPMENT")
	header.add_theme_font_size_override("font_size", 12)
	header.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox.add_child(header)

	_equip_label = Label.new()
	_equip_label.text = tr("HUD_EMPTY")
	_equip_label.add_theme_font_size_override("font_size", 16)
	_equip_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	vbox.add_child(_equip_label)


func _build_patient_overview() -> void:
	# Right-side collapsible patient list
	var container := PanelContainer.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
	container.offset_right = -16
	container.offset_left = -180
	container.offset_top = 80
	container.offset_bottom = -80
	add_child(container)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	container.add_child(scroll)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	scroll.add_child(margin)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	margin.add_child(vbox)

	var header := Label.new()
	header.text = tr("HUD_PATIENTS")
	header.add_theme_font_size_override("font_size", 14)
	header.add_theme_color_override("font_color", Color(0.6, 0.7, 0.8))
	vbox.add_child(header)

	_patient_list = VBoxContainer.new()
	_patient_list.add_theme_constant_override("separation", 4)
	vbox.add_child(_patient_list)


func _build_pause_overlay() -> void:
	_pause_overlay = PanelContainer.new()
	_pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.visible = false
	add_child(_pause_overlay)

	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.6)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.add_child(bg)

	var center := VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.offset_left = -150
	center.offset_right = 150
	center.offset_top = -120
	center.offset_bottom = 120
	center.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_theme_constant_override("separation", 16)
	_pause_overlay.add_child(center)

	var title := Label.new()
	title.text = tr("HUD_PAUSED_TITLE")
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center.add_child(title)

	var resume_btn := Button.new()
	resume_btn.text = tr("MENU_RESUME")
	resume_btn.custom_minimum_size = Vector2(250, 44)
	resume_btn.pressed.connect(_on_resume)
	center.add_child(resume_btn)

	var restart_btn := Button.new()
	restart_btn.text = tr("MENU_RESTART")
	restart_btn.custom_minimum_size = Vector2(250, 44)
	restart_btn.pressed.connect(_on_restart)
	center.add_child(restart_btn)

	var quit_btn := Button.new()
	quit_btn.text = tr("MENU_QUIT_TO_MENU")
	quit_btn.custom_minimum_size = Vector2(250, 44)
	quit_btn.pressed.connect(_on_quit_to_menu)
	center.add_child(quit_btn)


func _toggle_pause() -> void:
	_paused = not _paused
	_pause_overlay.visible = _paused
	get_tree().paused = _paused


func _on_resume() -> void:
	_paused = false
	_pause_overlay.visible = false
	get_tree().paused = false


func _on_restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_quit_to_menu() -> void:
	get_tree().paused = false
	var gm: Node = get_node_or_null("/root/GameManager")
	if gm and gm.has_method("change_scene"):
		gm.change_scene("res://scenes/main/MainMenu.tscn")


func _find_references() -> void:
	await get_tree().process_frame

	# Find player
	var players := get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		_player_ref = players[0] as Node3D

	# Find and track patients
	_update_patient_list()

	# Wire inventory for equipment display
	if _player_ref:
		var inv: Node = _find_child_by_signal(_player_ref, "inventory_changed")
		if inv:
			inv.inventory_changed.connect(_on_inventory_changed)

	# Calculate world bounds from level
	var root: Node = get_tree().current_scene
	if root:
		var level_size := _estimate_level_bounds(root)
		if level_size.x > 0 and level_size.y > 0:
			_world_bounds = Rect2(0, 0, level_size.x, level_size.y)


func _update_minimap() -> void:
	if not _player_ref or not is_instance_valid(_player_ref):
		return

	var map_size := _minimap_rect.size
	var px := (_player_ref.position.x / _world_bounds.size.x) * map_size.x
	var pz := (_player_ref.position.z / _world_bounds.size.y) * map_size.y
	_minimap_player_dot.position = Vector2(clampf(px - 3, 0, map_size.x - 6), clampf(pz - 3, 0, map_size.y - 6))

	# Update patient dots
	var patients := get_tree().get_nodes_in_group("patient")
	# Ensure we have enough dots
	while _minimap_patient_dots.size() < patients.size():
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(4, 4)
		dot.size = Vector2(4, 4)
		dot.color = Color(0.8, 0.8, 0.2)
		_minimap_rect.add_child(dot)
		_minimap_patient_dots.append(dot)

	for i in patients.size():
		var patient := patients[i] as Node3D
		if patient and is_instance_valid(patient):
			var dot := _minimap_patient_dots[i]
			var dx := (patient.position.x / _world_bounds.size.x) * map_size.x
			var dz := (patient.position.z / _world_bounds.size.y) * map_size.y
			dot.position = Vector2(clampf(dx - 2, 0, map_size.x - 4), clampf(dz - 2, 0, map_size.y - 4))
			dot.visible = true

	# Hide unused dots
	for i in range(patients.size(), _minimap_patient_dots.size()):
		_minimap_patient_dots[i].visible = false


func _update_patient_list() -> void:
	if not _patient_list:
		return

	for child in _patient_list.get_children():
		child.queue_free()

	var patients := get_tree().get_nodes_in_group("patient")
	for i in patients.size():
		var patient := patients[i]
		var row := Label.new()
		row.text = "%s %d: %s" % [tr("HUD_PATIENTS"), i + 1, tr("TRIAGE_UNASSESSED")]
		row.add_theme_font_size_override("font_size", 12)
		row.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
		_patient_list.add_child(row)


func _on_inventory_changed(item_name: String) -> void:
	if _equip_label:
		if item_name.is_empty():
			_equip_label.text = tr("HUD_EMPTY")
		else:
			_equip_label.text = item_name


func _estimate_level_bounds(root: Node) -> Vector2:
	# Try to read GRID_WIDTH/GRID_HEIGHT constants from level script
	if "GRID_WIDTH" in root and "GRID_HEIGHT" in root:
		var tile_size := 2.0
		if "TILE_SIZE" in root:
			tile_size = root.TILE_SIZE
		return Vector2(root.GRID_WIDTH * tile_size, root.GRID_HEIGHT * tile_size)
	return Vector2(32, 32)


func _find_child_by_signal(node: Node, signal_name: String) -> Node:
	for child in node.get_children():
		if child.has_signal(signal_name):
			return child
	return null


## Hide/show HUD (for debrief/review screens).
func set_hud_visible(visible: bool) -> void:
	for child in get_children():
		if child != _pause_overlay:
			child.visible = visible
