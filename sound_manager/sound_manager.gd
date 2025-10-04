extends Node

@export var sounds: Array[Sound]
@export var sound_sets: Array[SoundSet] 
@export var musics : Array[Sound]

var player_pool_3d : Array[AudioStreamPlayer3D] = []
var player_pool_2d : Array[AudioStreamPlayer2D] = []
var music_player : AudioStreamPlayer2D
var pool_size : int = 16

# must add SFX and MUSIC busses to audio server

func _ready() -> void:
	for i in range(pool_size):
		var player_3d = AudioStreamPlayer3D.new()
		player_3d.bus = "SFX"
		player_3d.autoplay = false
		add_child(player_3d)
		player_pool_3d.append(player_3d)
		
		var player_2d = AudioStreamPlayer2D.new()
		player_2d.bus = "SFX"
		player_2d.autoplay = false
		player_2d.panning_strength = 0.0
		player_2d.attenuation = 0.0
		player_2d.max_distance = 4096
		player_2d.max_polyphony = 5.0
		add_child(player_2d)
		player_pool_2d.append(player_2d)
		
	music_player = AudioStreamPlayer2D.new()
	music_player.bus = "MUSIC"
	music_player.autoplay = false
	music_player.panning_strength = 0.0
	music_player.attenuation = 0.0
	music_player.max_distance = 4096
	music_player.max_polyphony = 5.0
		
func GetSound(name: String) -> Sound:
	for sound in sounds:
		if sound.name == name:
			return sound
	for sound_set in sound_sets:
		if sound_set.set_name == name:
			return sound_set.GetRandomSound()
	
			
	return null
	
func GetMusic(name : String) -> Sound:
	for music in musics:
		if music.name == name:
			return music
	return null
	
func _GetFreePlayer3D() -> AudioStreamPlayer3D:
	for player in player_pool_3d:
		if not player.playing:
			return player
	
	var new_player = AudioStreamPlayer3D.new()
	return new_player;
	
func _GetFreePlayer2D() -> AudioStreamPlayer2D:
	for player in player_pool_2d:
		if not player.playing:
			return player
			
	var new_player = AudioStreamPlayer2D.new()
	return new_player;

func PlaySound3D(name : String, position : Vector3, random_pitch := false, random_pitch_range := 0.1):
	var sound: Sound = GetSound(name)
	if sound == null:
		push_warning("Sound not found: %s" % name)
		return
		
	var player := _GetFreePlayer3D()
	if player == null:
		push_warning("No free audio players available.")
		return

	player.stream = sound.stream
	player.volume_db = sound.volume
	player.pitch_scale = sound.pitch
	player.panning_strength = sound.panning_strength
	player.max_distance = sound.max_distance
	player.unit_size = sound.unit_size
	player.max_db = 0.0
	player.global_position = position

	player.bus = "SFX"
	
	if random_pitch:
		player.pitch_scale = randf_range(sound.pitch-random_pitch_range,sound.pitch+random_pitch_range)
	else:
		player.pitch_scale = 1.0
		
	player.play()
	
func PlaySound2D(name : String, random_pitch := false,random_pitch_range := 0.1):
	var sound: Sound = GetSound(name)
	if sound == null:
		push_warning("Sound not found: %s" % name)
		return
		
	var player := _GetFreePlayer2D()
	if player == null:
		push_warning("No free audio players available.")
		return
		
	player.stream = sound.stream
	player.volume_db = sound.volume
	player.pitch_scale = sound.pitch
	player.bus = "SFX"
	
	if random_pitch:
		player.pitch_scale = randf_range(sound.pitch-random_pitch_range,sound.pitch+random_pitch_range)
	else:
		player.pitch_scale = 1.0
		
	player.play()

func PlaySoundAtNode(name : String, node : Node3D, random_pitch := false, random_pitch_range := 0.1):
	PlaySound3D(name,node.global_position,random_pitch,random_pitch_range)

func StopSound(name: String):
	for player in player_pool_3d:
		if player.playing and player.stream and player.stream.resource_path.ends_with(name):
			player.stop()
	for player in player_pool_2d:
		if player.playing and player.stream and player.stream.resource_path.ends_with(name):
			player.stop()

func SetSFXVolume(volumeDB : float):
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index,volumeDB)

func SetMusicVolume(volumeDB : float):
	var bus_index = AudioServer.get_bus_index("MUSIC")
	AudioServer.set_bus_volume_db(bus_index,volumeDB)

func StopAll():
	for player in player_pool_3d:
		player.stop()
	for player in player_pool_2d:
		player.stop()
	music_player.stop()
	
func PauseAll():
	for player in player_pool_3d:
		player.stream_paused = true
	for player in player_pool_2d:
		player.stream_paused = true
	music_player.stream_paused = true

func ResumeAll():
	for player in player_pool_3d:
		player.stream_paused = false
	for player in player_pool_2d:
		player.stream_paused = false
	music_player.stream_paused = false

# Music Player

func PlayMusic(name: String, fade_time := 1.0):
	if music_player == null:
		push_warning("Music player is null")
		return
	
	var music : Sound = GetMusic(name)
	if music == null:
		push_warning("Music not found: %s" % name)
		return
	
	if music_player.playing and fade_time > 0:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", -40, fade_time)
		tween.finished.connect(func():
			music_player.stop()
			_StartMusic(music, fade_time)
		)
	else:
		_StartMusic(music, fade_time)

func StopMusic(fade_time := 1.0):
	if music_player.playing:
		if fade_time > 0:
			var tween := create_tween()
			tween.tween_property(music_player, "volume_db", -40, fade_time)
			tween.finished.connect(func():
				music_player.stop()
			)
		else:
			music_player.stop()

func _StartMusic(music: Sound, fade_time: float):
	music_player.stream = music.stream
	music_player.volume_db = -40  
	music_player.play()
	
	var target_volume = music.volume  
	if fade_time > 0:
		var tween := create_tween()
		tween.tween_property(music_player, "volume_db", target_volume, fade_time)
	else:
		music_player.volume_db = target_volume
