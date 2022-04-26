extends Control

const selfDisposingMusicPlayer = preload("res://src/Helpers/Audio/SelfDisposingMusicPlayer.tscn")

class_name SoundPlayer

static func playSound(scene : Node, audio : AudioStream, volume : float):
	var streamPlayer = selfDisposingMusicPlayer.instance()
	scene.add_child(streamPlayer);
	streamPlayer.stream = audio
	streamPlayer.volume_db = volume
	streamPlayer.Play()
	
