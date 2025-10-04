extends Resource
class_name SoundSet
@export var set_name: String = ""
@export var sounds: Array[Sound] = []

func GetRandomSound():
	return sounds.pick_random()
