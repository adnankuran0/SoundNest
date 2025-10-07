@tool
extends EditorPlugin

var _sfx_bus_index: int
var _music_bus_index: int
var _buffer_bus_index: int

func _enable_plugin() -> void:
	add_autoload_singleton("SoundManager", _get_plugin_path() + "/SoundManager.tscn")
	_add_audio_busses()

func _disable_plugin() -> void:
	remove_autoload_singleton("SoundManager")
	_remove_audio_busses()

func _get_plugin_path() -> String:
	return get_script().resource_path.get_base_dir()

func _add_audio_busses():
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus()
		_sfx_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_sfx_bus_index, "SFX")
		AudioServer.set_bus_volume_db(_sfx_bus_index, 0.0)

	if AudioServer.get_bus_index("MUSIC") == -1:
		AudioServer.add_bus()
		_music_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(_music_bus_index, "MUSIC")
		AudioServer.set_bus_volume_db(_music_bus_index, 0.0)

	# add empty bus cuz otherwise bus names don't show properly :(
	AudioServer.add_bus()
	_buffer_bus_index = AudioServer.bus_count - 1
	
func _remove_audio_busses():
	if AudioServer.get_bus_index("MUSIC") != -1:
		AudioServer.remove_bus(AudioServer.get_bus_index("MUSIC"))
	if AudioServer.get_bus_index("SFX") != -1:
		AudioServer.remove_bus(AudioServer.get_bus_index("SFX"))
