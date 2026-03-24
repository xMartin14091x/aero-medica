## AudioSystem — Complete audio management: ambient, UI, patient cues, dynamic music.
## Procedural generation for all sounds (no external files required).
## Dynamic music layers crossfade based on scenario urgency.
extends Node

## Audio bus names.
const BUS_MASTER := "Master"
const BUS_MUSIC := "Master"  # Use Master bus (sub-buses require AudioBusLayout)
const BUS_SFX := "Master"
const BUS_AMBIENT := "Master"

## Volume defaults (dB).
var master_volume_db := 0.0
var music_volume_db := -6.0
var sfx_volume_db := -3.0
var ambient_volume_db := -8.0

## Ambient environment types.
enum AmbientType { NONE, TUTORIAL_PARK, RTA_TRAFFIC, CARDIAC_INDOOR, MCI_CROWD, FIRE_ALARM }

## Music urgency levels.
enum UrgencyLevel { CALM, MEDIUM, HIGH, CRITICAL }

## Audio players.
var _ambient_player: AudioStreamPlayer = null
var _music_calm: AudioStreamPlayer = null
var _music_tense: AudioStreamPlayer = null
var _music_critical: AudioStreamPlayer = null
var _ui_player: AudioStreamPlayer = null
var _patient_players: Dictionary = {}  # patient_node -> AudioStreamPlayer3D

## Current state.
var _current_ambient: AmbientType = AmbientType.NONE
var _current_urgency: UrgencyLevel = UrgencyLevel.CALM
var _music_active: bool = false

## Sample rate for procedural audio.
const SAMPLE_RATE := 22050


func _ready() -> void:
	_create_players()
	# Audio disabled — procedural sounds are placeholder quality
	_mute_all()
	#_wire_signals.call_deferred()


## Mute all audio output.
func _mute_all() -> void:
	AudioServer.set_bus_volume_db(0, -80.0)
	AudioServer.set_bus_mute(0, true)


func _create_players() -> void:
	# Ambient player
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.bus = BUS_AMBIENT
	_ambient_player.volume_db = ambient_volume_db
	add_child(_ambient_player)

	# Music layers
	_music_calm = AudioStreamPlayer.new()
	_music_calm.bus = BUS_MUSIC
	_music_calm.volume_db = music_volume_db
	add_child(_music_calm)

	_music_tense = AudioStreamPlayer.new()
	_music_tense.bus = BUS_MUSIC
	_music_tense.volume_db = -80.0  # Start silent
	add_child(_music_tense)

	_music_critical = AudioStreamPlayer.new()
	_music_critical.bus = BUS_MUSIC
	_music_critical.volume_db = -80.0
	add_child(_music_critical)

	# UI sound player
	_ui_player = AudioStreamPlayer.new()
	_ui_player.bus = BUS_SFX
	_ui_player.volume_db = sfx_volume_db
	add_child(_ui_player)


func _wire_signals() -> void:
	await get_tree().process_frame

	var root: Node = get_tree().current_scene
	if not root:
		return

	# Wire TimePressureSystem for music urgency
	var time_sys: Node = _find_node_by_signal(root, "time_warning")
	if time_sys:
		time_sys.time_warning.connect(_on_time_warning)
		time_sys.time_expired.connect(_on_time_expired)

	# Wire ScenarioManager for scenario lifecycle
	var scenario_mgr: Node = get_node_or_null("/root/ScenarioManager")
	if scenario_mgr:
		if scenario_mgr.has_signal("scenario_started"):
			scenario_mgr.scenario_started.connect(_on_scenario_started)
		if scenario_mgr.has_signal("scenario_ended"):
			scenario_mgr.scenario_ended.connect(_on_scenario_ended)

	# Wire AssessmentManager for UI sounds
	var player_node: Node = _find_node_in_group(root, "player")
	if player_node:
		var assess_mgr: Node = _find_child_by_method(player_node, "perform_assessment")
		if assess_mgr and assess_mgr.has_signal("assessment_performed"):
			assess_mgr.assessment_performed.connect(_on_assessment_performed)

	# Wire TriageSystem for triage sound
	var triage_sys: Node = _find_node_by_signal(root, "triage_assigned")
	if triage_sys:
		triage_sys.triage_assigned.connect(_on_triage_assigned)


## Set ambient soundscape for a scenario.
func set_ambient(ambient_type: AmbientType) -> void:
	if ambient_type == _current_ambient:
		return

	_current_ambient = ambient_type
	if ambient_type == AmbientType.NONE:
		_ambient_player.stop()
		return

	var stream := _generate_ambient(ambient_type)
	if stream:
		_ambient_player.stream = stream
		_ambient_player.play()


## Start dynamic music.
func start_music() -> void:
	_music_active = true
	_current_urgency = UrgencyLevel.CALM

	_music_calm.stream = _generate_music_layer(UrgencyLevel.CALM)
	_music_tense.stream = _generate_music_layer(UrgencyLevel.MEDIUM)
	_music_critical.stream = _generate_music_layer(UrgencyLevel.CRITICAL)

	_music_calm.volume_db = music_volume_db
	_music_tense.volume_db = -80.0
	_music_critical.volume_db = -80.0

	_music_calm.play()
	_music_tense.play()
	_music_critical.play()


## Stop all music.
func stop_music() -> void:
	_music_active = false
	_music_calm.stop()
	_music_tense.stop()
	_music_critical.stop()


## Set music urgency level with crossfade.
func set_urgency(level: UrgencyLevel) -> void:
	if level == _current_urgency or not _music_active:
		return

	_current_urgency = level
	var fade_time := 1.5

	var tween := create_tween()
	tween.set_parallel(true)

	match level:
		UrgencyLevel.CALM:
			tween.tween_property(_music_calm, "volume_db", music_volume_db, fade_time)
			tween.tween_property(_music_tense, "volume_db", -80.0, fade_time)
			tween.tween_property(_music_critical, "volume_db", -80.0, fade_time)
		UrgencyLevel.MEDIUM:
			tween.tween_property(_music_calm, "volume_db", music_volume_db - 3.0, fade_time)
			tween.tween_property(_music_tense, "volume_db", music_volume_db, fade_time)
			tween.tween_property(_music_critical, "volume_db", -80.0, fade_time)
		UrgencyLevel.HIGH:
			tween.tween_property(_music_calm, "volume_db", -80.0, fade_time)
			tween.tween_property(_music_tense, "volume_db", music_volume_db, fade_time)
			tween.tween_property(_music_critical, "volume_db", music_volume_db - 6.0, fade_time)
		UrgencyLevel.CRITICAL:
			tween.tween_property(_music_calm, "volume_db", -80.0, fade_time)
			tween.tween_property(_music_tense, "volume_db", -80.0, fade_time)
			tween.tween_property(_music_critical, "volume_db", music_volume_db, fade_time)


## Play UI feedback sounds.
func play_ui_click() -> void:
	_play_ui_sound(_generate_click_sound())

func play_ui_pickup() -> void:
	_play_ui_sound(_generate_pickup_sound())

func play_ui_confirm() -> void:
	_play_ui_sound(_generate_confirm_sound())

func play_ui_error() -> void:
	_play_ui_sound(_generate_error_sound())

func play_triage_tag() -> void:
	_play_ui_sound(_generate_triage_sound())


## Create patient audio cue (3D spatial).
func create_patient_audio(patient: Node3D, state: String) -> void:
	if patient in _patient_players:
		_update_patient_audio(patient, state)
		return

	var player := AudioStreamPlayer3D.new()
	player.bus = BUS_SFX
	player.max_distance = 15.0
	player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
	player.unit_size = 3.0
	player.volume_db = sfx_volume_db - 3.0

	patient.add_child(player)
	_patient_players[patient] = player

	_update_patient_audio(patient, state)


## Update patient audio based on medical state.
func _update_patient_audio(patient: Node3D, state: String) -> void:
	if patient not in _patient_players:
		return

	var player: AudioStreamPlayer3D = _patient_players[patient]

	match state:
		"CONSCIOUS":
			player.stream = _generate_patient_groan()
			player.play()
		"UNCONSCIOUS":
			player.stream = _generate_patient_breathing()
			player.play()
		"CARDIAC_ARREST", "DEAD":
			player.stop()


## Volume controls.
func set_master_volume(volume_db: float) -> void:
	master_volume_db = volume_db

func set_music_volume(volume_db: float) -> void:
	music_volume_db = volume_db
	if _music_active:
		set_urgency(_current_urgency)  # Reapply

func set_sfx_volume(volume_db: float) -> void:
	sfx_volume_db = volume_db
	_ui_player.volume_db = sfx_volume_db

func set_ambient_volume(volume_db: float) -> void:
	ambient_volume_db = volume_db
	_ambient_player.volume_db = ambient_volume_db


## Signal handlers.
func _on_scenario_started() -> void:
	start_music()

func _on_scenario_ended(_results: Dictionary) -> void:
	stop_music()
	_ambient_player.stop()
	_cleanup_patient_audio()

func _on_time_warning(remaining: float) -> void:
	# Determine urgency from remaining time ratio (needs total from somewhere)
	# Use absolute thresholds as fallback
	if remaining < 60.0:
		set_urgency(UrgencyLevel.CRITICAL)
	elif remaining < 120.0:
		set_urgency(UrgencyLevel.HIGH)
	elif remaining < 300.0:
		set_urgency(UrgencyLevel.MEDIUM)

func _on_time_expired() -> void:
	set_urgency(UrgencyLevel.CRITICAL)

func _on_assessment_performed(_patient: Node, _action_type: int, _result: Dictionary) -> void:
	play_ui_confirm()

func _on_triage_assigned(_patient: Node, _assigned: int, _correct: int, is_correct: bool) -> void:
	play_triage_tag()
	if not is_correct:
		# Subtle error hint
		await get_tree().create_timer(0.3).timeout
		play_ui_error()


func _play_ui_sound(stream: AudioStream) -> void:
	if stream:
		_ui_player.stream = stream
		_ui_player.play()


func _cleanup_patient_audio() -> void:
	for patient in _patient_players:
		var player: Node = _patient_players[patient]
		if is_instance_valid(player):
			player.queue_free()
	_patient_players.clear()


## --- Procedural Audio Generation ---

func _generate_ambient(ambient_type: AmbientType) -> AudioStream:
	var duration := 4.0
	var num_samples := int(SAMPLE_RATE * duration)
	var rng := RandomNumberGenerator.new()
	rng.seed = ambient_type * 54321

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = SAMPLE_RATE
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_begin = 0
	audio.loop_end = num_samples

	var data := PackedByteArray()
	data.resize(num_samples)

	match ambient_type:
		AmbientType.TUTORIAL_PARK:
			# Light noise with occasional "bird" chirps (high freq blips)
			for i in num_samples:
				var t := float(i) / SAMPLE_RATE
				var noise := rng.randf_range(-0.05, 0.05)
				if rng.randf() < 0.0005:
					noise += sin(t * rng.randf_range(2000.0, 4000.0) * TAU) * 0.15
				data[i] = int(clampf(noise * 127.0 + 128.0, 0.0, 255.0))

		AmbientType.RTA_TRAFFIC:
			# Low drone + intermittent horn/siren
			var phase := 0.0
			for i in num_samples:
				phase += 60.0 / SAMPLE_RATE
				var drone := sin(phase * TAU) * 0.1
				drone += rng.randf_range(-0.05, 0.05)
				if rng.randf() < 0.0002:
					var t := float(i) / SAMPLE_RATE
					drone += sin(t * 800.0 * TAU) * 0.2
				data[i] = int(clampf(drone * 127.0 + 128.0, 0.0, 255.0))

		AmbientType.CARDIAC_INDOOR:
			# Very quiet room tone + subtle clock tick
			for i in num_samples:
				var noise := rng.randf_range(-0.02, 0.02)
				# Tick every ~1 second
				if i % SAMPLE_RATE < 100:
					noise += 0.15
				data[i] = int(clampf(noise * 127.0 + 128.0, 0.0, 255.0))

		AmbientType.MCI_CROWD:
			# Chaotic crowd noise with distant sirens
			var siren_phase := 0.0
			for i in num_samples:
				var noise := rng.randf_range(-0.15, 0.15)
				siren_phase += (600.0 + sin(float(i) / SAMPLE_RATE * 0.5 * TAU) * 200.0) / SAMPLE_RATE
				noise += sin(siren_phase * TAU) * 0.05
				data[i] = int(clampf(noise * 127.0 + 128.0, 0.0, 255.0))

		AmbientType.FIRE_ALARM:
			# Alarm beep + crackling + rumble
			var phase := 0.0
			for i in num_samples:
				var t := float(i) / SAMPLE_RATE
				phase += 30.0 / SAMPLE_RATE
				var rumble := sin(phase * TAU) * 0.1
				rumble += rng.randf_range(-0.08, 0.08)
				# Alarm beep every 2 seconds
				if fmod(t, 2.0) < 0.3:
					rumble += sin(t * 1000.0 * TAU) * 0.12
				data[i] = int(clampf(rumble * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	return audio


func _generate_music_layer(urgency: UrgencyLevel) -> AudioStream:
	var duration := 8.0
	var num_samples := int(SAMPLE_RATE * duration)
	var rng := RandomNumberGenerator.new()
	rng.seed = urgency * 98765

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = SAMPLE_RATE
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_begin = 0
	audio.loop_end = num_samples

	var data := PackedByteArray()
	data.resize(num_samples)

	match urgency:
		UrgencyLevel.CALM:
			# Soft pad: slow sine waves
			for i in num_samples:
				var t := float(i) / SAMPLE_RATE
				var pad := sin(t * 130.0 * TAU) * 0.08  # C3
				pad += sin(t * 196.0 * TAU) * 0.05  # G3
				pad += sin(t * 164.0 * TAU) * 0.04  # E3
				# Slow volume modulation
				pad *= 0.7 + sin(t * 0.25 * TAU) * 0.3
				data[i] = int(clampf(pad * 127.0 + 128.0, 0.0, 255.0))

		UrgencyLevel.MEDIUM:
			# Pulsing rhythm
			for i in num_samples:
				var t := float(i) / SAMPLE_RATE
				var pulse := sin(t * 220.0 * TAU) * 0.1
				# 1Hz pulse
				pulse *= maxf(sin(t * 1.0 * TAU), 0.0)
				pulse += sin(t * 110.0 * TAU) * 0.05
				data[i] = int(clampf(pulse * 127.0 + 128.0, 0.0, 255.0))

		UrgencyLevel.HIGH, UrgencyLevel.CRITICAL:
			# Fast pulse + dissonant tones
			var bpm := 140.0 if urgency == UrgencyLevel.HIGH else 170.0
			var beat_freq := bpm / 60.0
			for i in num_samples:
				var t := float(i) / SAMPLE_RATE
				var beat := maxf(sin(t * beat_freq * TAU), 0.0)
				var tone := sin(t * 233.0 * TAU) * 0.1  # Bb3
				tone += sin(t * 277.0 * TAU) * 0.06  # Db4 (minor)
				tone *= beat
				tone += rng.randf_range(-0.02, 0.02)
				data[i] = int(clampf(tone * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	return audio


func _generate_click_sound() -> AudioStream:
	return _generate_short_tone(800.0, 0.05, 0.2)

func _generate_pickup_sound() -> AudioStream:
	return _generate_short_tone(400.0, 0.1, 0.25)

func _generate_confirm_sound() -> AudioStream:
	# Two-tone ascending
	var num_samples := int(SAMPLE_RATE * 0.2)
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = SAMPLE_RATE
	audio.stereo = false

	var data := PackedByteArray()
	data.resize(num_samples)

	for i in num_samples:
		var t := float(i) / SAMPLE_RATE
		var freq := 523.0 if t < 0.1 else 659.0  # C5 then E5
		var envelope := maxf(1.0 - t * 5.0, 0.0) if t >= 0.1 else 1.0
		var tone := sin(t * freq * TAU) * 0.2 * envelope
		data[i] = int(clampf(tone * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	return audio

func _generate_error_sound() -> AudioStream:
	# Low descending buzz
	var num_samples := int(SAMPLE_RATE * 0.25)
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = SAMPLE_RATE
	audio.stereo = false

	var data := PackedByteArray()
	data.resize(num_samples)

	for i in num_samples:
		var t := float(i) / SAMPLE_RATE
		var freq := 300.0 - t * 200.0
		var envelope := maxf(1.0 - t * 4.0, 0.0)
		var tone := sin(t * freq * TAU) * 0.2 * envelope
		tone += sin(t * freq * 1.5 * TAU) * 0.1 * envelope  # Dissonant
		data[i] = int(clampf(tone * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	return audio

func _generate_triage_sound() -> AudioStream:
	return _generate_short_tone(660.0, 0.15, 0.2)


func _generate_patient_groan() -> AudioStream:
	var duration := 3.0
	var num_samples := int(SAMPLE_RATE * duration)
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = SAMPLE_RATE
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_begin = 0
	audio.loop_end = num_samples

	var data := PackedByteArray()
	data.resize(num_samples)

	for i in num_samples:
		var t := float(i) / SAMPLE_RATE
		# Low vocal tone with vibrato
		var freq := 120.0 + sin(t * 3.0 * TAU) * 15.0
		var tone := sin(t * freq * TAU) * 0.15
		tone += sin(t * freq * 2.0 * TAU) * 0.05  # Harmonic
		# Intermittent (groan pattern)
		var groan_env := maxf(sin(t * 0.5 * TAU), 0.0)
		tone *= groan_env
		tone += rng.randf_range(-0.02, 0.02)
		data[i] = int(clampf(tone * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	return audio


func _generate_patient_breathing() -> AudioStream:
	var duration := 4.0
	var num_samples := int(SAMPLE_RATE * duration)
	var rng := RandomNumberGenerator.new()
	rng.randomize()

	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = SAMPLE_RATE
	audio.stereo = false
	audio.loop_mode = AudioStreamWAV.LOOP_FORWARD
	audio.loop_begin = 0
	audio.loop_end = num_samples

	var data := PackedByteArray()
	data.resize(num_samples)

	for i in num_samples:
		var t := float(i) / SAMPLE_RATE
		# Breathing cycle: in (0-1s), pause (1-1.5s), out (1.5-2.5s), pause
		var cycle := fmod(t, 3.0)
		var breath := 0.0
		if cycle < 1.0:
			# Inhale: rising noise
			breath = rng.randf_range(-0.1, 0.1) * (cycle / 1.0)
		elif cycle > 1.5 and cycle < 2.5:
			# Exhale: falling noise
			breath = rng.randf_range(-0.1, 0.1) * (1.0 - (cycle - 1.5) / 1.0)
		data[i] = int(clampf(breath * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	return audio


func _generate_short_tone(freq: float, duration: float, amplitude: float) -> AudioStream:
	var num_samples := int(SAMPLE_RATE * duration)
	var audio := AudioStreamWAV.new()
	audio.format = AudioStreamWAV.FORMAT_8_BITS
	audio.mix_rate = SAMPLE_RATE
	audio.stereo = false

	var data := PackedByteArray()
	data.resize(num_samples)

	for i in num_samples:
		var t := float(i) / SAMPLE_RATE
		var envelope := maxf(1.0 - t / duration, 0.0)
		var tone := sin(t * freq * TAU) * amplitude * envelope
		data[i] = int(clampf(tone * 127.0 + 128.0, 0.0, 255.0))

	audio.data = data
	return audio


## Utility: find node with specific signal.
func _find_node_by_signal(node: Node, signal_name: String) -> Node:
	if node.has_signal(signal_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_by_signal(child, signal_name)
		if found:
			return found
	return null


func _find_node_in_group(node: Node, group_name: String) -> Node:
	if node.is_in_group(group_name):
		return node
	for child in node.get_children():
		var found: Node = _find_node_in_group(child, group_name)
		if found:
			return found
	return null


func _find_child_by_method(node: Node, method_name: String) -> Node:
	for child in node.get_children():
		if child.has_method(method_name):
			return child
	return null


## Cleanup all audio.
func cleanup() -> void:
	_ambient_player.stop()
	stop_music()
	_cleanup_patient_audio()
