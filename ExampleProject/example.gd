extends Node3D

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D

func _ready() -> void:
	# 2D Sound Test
	SoundNest.PlaySound2D("footstep")
	await get_tree().create_timer(0.5).timeout
	
	SoundNest.PlaySound2D("footstep", 2.0, true, 0.1)
	await get_tree().create_timer(0.5).timeout
	
	# 3D Sound Test
	var pos = Vector3(0, 0, 0)
	SoundNest.PlaySound3D("footstep", pos)
	await get_tree().create_timer(0.7).timeout
	
	SoundNest.PlaySound3D("footstep", pos, 2.0, true, 0.2)
	await get_tree().create_timer(0.7).timeout
	
	# PlaySoundAtNode Test
	SoundNest.PlaySoundAtNode("background_music", mesh_instance_3d, true, 0.3)
	await get_tree().create_timer(2.0).timeout
	
	SoundManager.StopAll()
	
	# Music Test
	SoundNest.PlayMusic("background_music")
	await get_tree().create_timer(2.0).timeout
	
	SoundNest.PlayMusic("background_music2",0.3)
	await get_tree().create_timer(2.0).timeout
	
	SoundNest.StopMusic(1.0)
	await get_tree().create_timer(1.5).timeout
	
	SoundNest.PlayMusic("background_music", 1.0)
	await get_tree().create_timer(2.0).timeout
	
	# Volume Test
	SoundNest.SetSFXVolume(-10.0)
	SoundNest.SetMusicVolume(-5.0)
	await get_tree().create_timer(0.5).timeout
	
	# Pause / Resume / Stop All Test
	SoundNest.PauseAll()
	await get_tree().create_timer(1.0).timeout
	
	SoundNest.ResumeAll()
	await get_tree().create_timer(1.0).timeout
	
	SoundNest.StopAll()
