# SoundNest

This is a simple sound manager plugin for Godot 4.5.  
It handles 2D & 3D sounds, music, and even sound sets with minimal fuss. 

---

## Features

- 2D & 3D sound support with pooling  
- Sound sets for random variations  
- Music playback with fade in/out  
- Play sounds by attached to any node 
- Stop, pause, resume, and volume control  

---

## Installation
Copy the addons/sound_manager directory into your res://addons/ directory.  
Enable SoundNest in project plugins.

---

## Usage

### Playing sounds

```gdscript
# Play a simple 2D sound
SoundManager.PlaySound2D("footstep")

# Play a 2D sound with custom pitch and random variation
SoundManager.PlaySound2D("footstep", custom_pitch=1.2, random_pitch=true, random_pitch_range=0.1)

# Play a 3D sound at a position
SoundManager.PlaySound3D("gunshot", Vector3(2,0,-3))

# Play a sound attached to a moving node
var node = Node3D.new()
add_child(node)
SoundManager.PlaySoundAtNode("footstep", node)
```
### Playing musics

```gdscript
# Play or change music with fade-in 
SoundManager.PlayMusic("background_music", fade_time=1.0)

# Stop music with fade-out
SoundManager.StopMusic(fade_time=1.0)
```

### Controlling all sounds
```gdscript
# Stop all sounds and music
SoundManager.StopAll()

# Pause all sounds
SoundManager.PauseAll()

# Resume all sounds
SoundManager.ResumeAll()

# Set volumes
SoundManager.SetSFXVolume(-10)  # in dB
SoundManager.SetMusicVolume(-5) # in dB
```

### Tips
- Use SoundSet if you want random variations for footsteps, gunshots, etc. 
- You don’t need to name every sound in a SoundSet. Just give the SoundSet a name, and it will automatically pick a random sound from its collection when played.  
- PlaySoundAtNode is perfect for moving objects so the sound follows them automatically.
- Adjust pool size in the inspector to optimize performance depending on how many simultaneous sounds you expect.
