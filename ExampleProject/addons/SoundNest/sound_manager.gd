extends Node

@export_category("SM Settings")
## How many players will created for 2d and 3d seperately
@export var _pool_size : int = 16 
## Should create new player if pool size is not enough
@export var _dynamic_pool : bool = false 

@export_category("Sounds")
@export var _sounds: Array[Sound]
@export var _sound_sets: Array[SoundSet] 
@export var _musics : Array[Sound]

var _active_sounds := [] #  { "player": AudioStreamPlayer, "name": String }
var _player_pool_3d : Array[AudioStreamPlayer3D] = []
var _player_pool_2d : Array[AudioStreamPlayer2D] = []
var _music_player : AudioStreamPlayer2D

func _CreatePlayer(player_class: Object, bus: String = "SFX") -> Object:
	var player = player_class.new()
	player.bus = bus
	player.autoplay = false
	if player is AudioStreamPlayer2D:
		player.panning_strength = 0
		player.attenuation = 0
		player.max_distance = 4096
		player.max_polyphony = 5
	add_child(player)
	if player is AudioStreamPlayer2D:
		_player_pool_2d.append(player)
	else:
		_player_pool_3d.append(player)
	return player
	
func _CreateMusicPlayer():
	_music_player = AudioStreamPlayer2D.new()
	_music_player.bus = "MUSIC"
	_music_player.autoplay = false
	_music_player.panning_strength = 0.0 # disabling attenuation models for 2d sounds
	_music_player.attenuation = 0.0
	_music_player.max_distance = 4096
	_music_player.max_polyphony = 5.0
	add_child(_music_player)

func _ready() -> void:
	# check if buses are correctly set up
	var sfx_bus_index = AudioServer.get_bus_index("SFX")
	var music_bus_index = AudioServer.get_bus_index("MUSIC")
	if sfx_bus_index == -1 or music_bus_index == -1:
		push_warning("Can not find neccesary audio busses") 
	
	# create player pool
	for i in range(_pool_size):
		_CreatePlayer(AudioStreamPlayer3D)
		_CreatePlayer(AudioStreamPlayer2D)
		
	_CreateMusicPlayer()
		
func GetSound(name: String) -> Sound:
	for sound in _sounds:
		if sound.name == name:
			return sound
	for sound_set in _sound_sets:
		if sound_set.set_name == name:
			return sound_set.GetRandomSound()
			
	return null
	
func GetMusic(name : String) -> Sound:
	for music in _musics:
		if music.name == name:
			return music
	return null
	
func _GetFreePlayer(pool: Array, player_class: Object) -> Object:
	for player in pool:
		if not player.playing:
			return player

	if _dynamic_pool:
		return _CreatePlayer(player_class)
	else:
		return null

func _PlaySound(name: String, pool: Array, player_class: Object, is_3d: bool, 
position := Vector3.ZERO, custom_pitch := 1.0 ,random_pitch := false, random_pitch_range := 0.1):
	var sound: Sound = GetSound(name)
	if sound == null:
		push_warning("Sound not found: %s" % name)
		return

	var player = _GetFreePlayer(pool, player_class)
	if player == null:
		push_warning("No free audio players available.")
		return

	player.stream = sound.stream
	player.volume_db = sound.volume
	player.bus = "SFX"
	if custom_pitch != 1.0:
		player.pitch_scale = custom_pitch
	else:
		player.pitch_scale = sound.pitch
		
	if is_3d:
		player.max_distance = sound.max_distance
		player.unit_size = sound.unit_size
		player.panning_strength = sound.panning_strength
		player.max_db = 0.0
		player.global_position = position

	if random_pitch:
		player.pitch_scale = randf_range(player.pitch_scale - random_pitch_range, player.pitch_scale + random_pitch_range)
	

	player.play()
	_active_sounds.append({"player": player, "name": name})
	

func PlaySound3D(name: String, position: Vector3, custom_pitch := 1.0 ,random_pitch := false, random_pitch_range := 0.1):
	_PlaySound(name, _player_pool_3d, AudioStreamPlayer3D, true, position , custom_pitch, random_pitch, random_pitch_range)

func PlaySound2D(name: String, custom_pitch := 1.0, random_pitch := false, random_pitch_range := 0.1):
	_PlaySound(name, _player_pool_2d, AudioStreamPlayer2D, false, Vector3.ZERO, custom_pitch, random_pitch, random_pitch_range)
	
func PlaySoundAtNode(name : String, node : Node3D, random_pitch := false, random_pitch_range := 0.1):
	var pos = node.global_position
	PlaySound3D(name, pos, 1.0, random_pitch, random_pitch_range)
	var item = _active_sounds[-1]
	if item.player.playing:
		if item.player.get_parent() != null:
			item.player.get_parent().remove_child(item.player)
		node.add_child(item.player)
		if not item.player.is_connected("finished", Callable(self, "_OnLendedSoundEnded").bind(item.player)):
			item.player.connect("finished", Callable(self, "_OnLendedSoundEnded").bind(item.player))
			
func _OnLendedSoundEnded(player):
	if not player:
		return

	print("bibcik")
	# remove from active list
	for i in range(_active_sounds.size() - 1, -1, -1):
		if _active_sounds[i]["player"] == player:
			_active_sounds.remove_at(i)
			break

	# move player back to SoundManager
	if player.get_parent() != self:
		player.get_parent().remove_child(player)
		add_child(player)
	player.stop()

func StopSound(name: String):
	for i in range(_active_sounds.size() - 1, -1, -1):
		var item = _active_sounds[i]
		if item["name"] == name and item["player"].playing:
			item["player"].stop()
			_active_sounds.remove_at(i)


func SetMasterVolume(volumeDB : float):
	var bus_index = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_index,volumeDB)

func SetSFXVolume(volumeDB : float):
	var bus_index = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_index,volumeDB)

func SetMusicVolume(volumeDB : float):
	var bus_index = AudioServer.get_bus_index("MUSIC")
	AudioServer.set_bus_volume_db(bus_index,volumeDB)

func StopAll():
	for player in _player_pool_3d:
		player.stop()
	for player in _player_pool_2d:
		player.stop()
	_music_player.stop()
	
func PauseAll():
	for player in _player_pool_3d:
		player.stream_paused = true
	for player in _player_pool_2d:
		player.stream_paused = true
	_music_player.stream_paused = true

func ResumeAll():
	for player in _player_pool_3d:
		player.stream_paused = false
	for player in _player_pool_2d:
		player.stream_paused = false
	_music_player.stream_paused = false

# Music Player

func PlayMusic(name: String, fade_time := 1.0):
	if _music_player == null:
		push_warning("Music player is null")
		return
	
	var music : Sound = GetMusic(name)
	if music == null:
		push_warning("Music not found: %s" % name)
		return
	
	if _music_player.playing and fade_time > 0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", -40, fade_time)
		tween.finished.connect(func():
			_music_player.stop()
			_StartMusic(music, fade_time)
		)
	else:
		_StartMusic(music, fade_time)

func StopMusic(fade_time := 1.0):
	if _music_player.playing:
		if fade_time > 0:
			var tween := create_tween()
			tween.tween_property(_music_player, "volume_db", -40, fade_time)
			tween.finished.connect(func():
				_music_player.stop()
			)
		else:
			_music_player.stop()

func _StartMusic(music: Sound, fade_time: float):
	_music_player.stream = music.stream
	_music_player.volume_db = -40  
	_music_player.play()
	
	var target_volume = music.volume  
	if fade_time > 0:
		var tween := create_tween()
		tween.tween_property(_music_player, "volume_db", target_volume, fade_time)
	else:
		_music_player.volume_db = target_volume
