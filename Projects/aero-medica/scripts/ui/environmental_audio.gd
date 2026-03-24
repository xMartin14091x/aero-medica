## EnvironmentalAudio — Spatial audio for hazards and event notifications.
## Fire crackling, collapse rumble, traffic noise, event chimes.
## AudioStreamPlayer3D with distance falloff attached to hazard zones.
## Placeholder audio via procedural generation (no external files required).
extends Node

## Hazard type constants (matching HazardZone.HazardType enum).
const TYPE_FIRE := 0
const TYPE_COLLAPSE := 1
const TYPE_TRAFFIC := 2

## Audio bus for environmental sounds.
const AUDIO_BUS := "Master"

## Max distance for 3D audio falloff.
const MAX_DISTANCE := 25.0

## Active audio players per hazard zone.
var _audio_players: Dictionary = {}

## UI notification player (non-spatial).
var _notification_player: AudioStreamPlayer = null

## Hazard proximity warning player (non-spatial, for screen-level warning).
var _proximity_player: AudioStreamPlayer = null

## Whether player is in a hazard zone.
var _player_in_hazard: bool = false


func _ready() -> void:
	_create_ui_players()
	_wire_signals.call_deferred()


func _create_ui_players() -> void:
	# Notification chime player
	_notification_player = AudioStreamPlayer.new()
	_notification_player.bus = AUDIO_BUS
	_notification_player.volume_db = -6.0
	add_child(_notification_player)

	# Proximity warning player
	_proximity_player = AudioStreamPlayer.new()
	_proximity_player.bus = AUDIO_BUS
	_proximity_player.volume_db = -10.0
	add_child(_proximity_player)


func _wire_signals() -> void:
	await get_tree().process_frame

	var root: Node = get_tree().current_scene
	if not root:
		return

	# Find HazardSystem
	var hazard_sys: Node = _find_node_by_method(root, "get_active_hazards")
	if hazard_sys:
		hazard_sys.hazard_activated.connect(_on_hazard_activated)
		hazard_sys.entity_in_hazard.connect(_on_entity_in_hazard)
		hazard_sys.entity_left_hazard.connect(_on_entity_left_hazard)

		# Wire existing active hazards
		for zone in hazard_sys.get_active_hazards():
			_create_audio_for_zone(zone)

	# Find RandomEventSystem for event notifications
	var event_sys: Node = _find_node_by_signal(root, "random_event_triggered")
	if event_sys:
		event_sys.random_event_triggered.connect(_on_random_event)


## Create spatial audio for a hazard zone.
func _on_hazard_activated(zone: Node) -> void:
	_create_audio_for_zone(zone)


## Player enters hazard — play proximity warning.
func _on_entity_in_hazard(entity: Node3D, hazard_type: String) -> void:
	if entity.is_in_group("player"):
		_player_in_hazard = true
		_play_proximity_warning(hazard_type)


## Player exits hazard.
func _on_entity_left_hazard(entity: Node3D, _hazard_type: String) -> void:
	if entity.is_in_group("player"):
		_player_in_hazard = false
		_proximity_player.stop()


## Random event triggered — play notification chime.
func _on_random_event(_event_type: String, _event_data: Dictionary) -> void:
	_play_notification_chime()


## Create a spatial audio player for a hazard zone.
func _create_audio_for_zone(zone: Node) -> void:
	if zone in _audio_players:
		return

	var hazard_type: int = zone.hazard_type if "hazard_type" in zone else TYPE_FIRE

	var player := AudioStreamPlayer3D.new()
	player.bus = AUDIO_BUS
	player.max_distance = MAX_DISTANCE
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	player.unit_size = 5.0
	player.position.y = 0.5

	# Generate procedural audio based on hazard type
	var stream := _generate_hazard_audio(hazard_type)
	if stream:
		player.stream = stream
		player.autoplay = true

	# Volume based on type
	match hazard_type:
		TYPE_FIRE:
			player.volume_db = -3.0
		TYPE_COLLAPSE:
			player.volume_db = -6.0
		TYPE_TRAFFIC:
			player.volume_db = -4.0

	zone.add_child(player)
	_audio_players[zone] = player


## Generate a procedural AudioStream for a hazard type.
## Uses AudioStreamGenerator for real-time noise-based sound.
func _generate_hazard_audio(hazard_type: int) -> AudioStream:
	# Use AudioStreamWAV with procedural noise data
	var sample_rate := 22050
	var duration := 2.0  # Loop duration
	var num_samples := int(sample_rate * duration)

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_begin = 0
	audio.loop_end = num_samples

	var data := PackedByteArray()
	data.resize(num_samples)

	var rng := RandomNumberGenerator.new()
	rng.seed = hazard_type * 12345

	match hazard_type:
		TYPE_FIRE:
			# Fire crackling: filtered noise with intermittent pops
			for i in num_samples:
				var t := float(i) / sample_rate
				var noise := rng.randf_range(-1.0, 1.0)
				# Low-pass approximation via averaging
				var crackle := noise * 0.3
				# Intermittent louder pops
				if rng.randf() < 0.005:
					crackle += rng.randf_range(0.3, 0.7) * signf(noise)
				data[i] = int(clampf(crackle * 127.0 + 128.0, 0.0, 255.0))

		TYPE_COLLAPSE:
			# Collapse rumble: low frequency noise
			var phase := 0.0
			for i in num_samples:
				var t := float(i) / sample_rate
				phase += 40.0 / sample_rate  # ~40Hz rumble
				var rumble := sin(phase * TAU) * 0.4
				rumble += rng.randf_range(-0.2, 0.2)  # Add texture
				# Intermittent cracking sounds
				if rng.randf() < 0.002:
					rumble += rng.randf_range(0.3, 0.6)
				data[i] = int(clampf(rumble * 127.0 + 128.0, 0.0, 255.0))

		TYPE_TRAFFIC:
			# Traffic: engine drone + intermittent horns
			var phase := 0.0
			for i in num_samples:
				var t := float(i) / sample_rate
				phase += 80.0 / sample_rate  # ~80Hz engine
				var engine := sin(phase * TAU) * 0.25
				engine += sin(phase * TAU * 2.0) * 0.1  # Harmonic
				engine += rng.randf_range(-0.1, 0.1)
				# Intermittent horn
				if rng.randf() < 0.001:
					engine += sin(t * 440.0 * TAU) * 0.3
				data[i] = int(clampf(engine * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	return audio


## Play a notification chime for random events.
func _play_notification_chime() -> void:
	if not _notification_player:
		return

	var sample_rate := 22050
	var duration := 0.5
	var num_samples := int(sample_rate * duration)

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false

	var data := PackedByteArray()
	data.resize(num_samples)

	for i in num_samples:
		var t := float(i) / sample_rate
		# Two-tone chime (C5 + E5)
		var envelope := maxf(1.0 - t * 2.0, 0.0)
		var tone := sin(t * 523.0 * TAU) * 0.3 + sin(t * 659.0 * TAU) * 0.2
		tone *= envelope
		data[i] = int(clampf(tone * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	_notification_player.stream = audio
	_notification_player.play()


## Play proximity warning sound.
func _play_proximity_warning(hazard_type: String) -> void:
	if not _proximity_player:
		return

	var sample_rate := 22050
	var duration := 0.3
	var num_samples := int(sample_rate * duration)

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = sample_rate
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_begin = 0
	audio.loop_end = num_samples

	var data := PackedByteArray()
	data.resize(num_samples)

	# Warning beep — frequency varies by hazard type
	var freq := 880.0  # Default
	match hazard_type:
		"FIRE":
			freq = 880.0
		"COLLAPSE":
			freq = 440.0
		"TRAFFIC":
			freq = 660.0

	for i in num_samples:
		var t := float(i) / sample_rate
		var envelope := 1.0 if t < duration * 0.5 else maxf(1.0 - (t - duration * 0.5) * 4.0, 0.0)
		var tone := sin(t * freq * TAU) * 0.25 * envelope
		data[i] = int(clampf(tone * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	_proximity_player.stream = audio
	_proximity_player.play()


## Find a node with a specific method.
func _find_node_by_method(node: Node, method_name: String) -> Node:
	if node.has_method(method_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_method(child, method_name)
		if found:
			return found
	return null


## Find a node with a specific signal.
func _find_node_by_signal(node: Node, signal_name: String) -> Node:
	if node.has_signal(signal_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_signal(child, signal_name)
		if found:
			return found
	return null


## Cleanup all audio.
func cleanup() -> void:
	for zone in _audio_players:
		var player: Node = _audio_players[zone]
		if is_instance_valid(player):
			player.queue_free()
	_audio_players.clear()
	if _proximity_player:
		_proximity_player.stop()
