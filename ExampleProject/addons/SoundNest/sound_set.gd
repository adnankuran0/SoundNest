class_name SoundSet extends Resource

@export var set_name: String = ""
@export var sounds: Array[Sound] = []

func GetRandomSound():
	return sounds.pick_random()
