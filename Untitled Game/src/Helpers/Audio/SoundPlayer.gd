extends Control

const selfDisposingAudioPlayer = preload("res://src/Helpers/Audio/SelfDisposingAudioPlayer.tscn")

class_name SoundPlayer

static func playSound(scene : Node, audio : AudioStream, volume : float):
	var streamPlayer = selfDisposingAudioPlayer.instance()
	scene.add_child(streamPlayer);
	streamPlayer.stream = audio
	streamPlayer.volume_db = volume
	streamPlayer.Play()
	
#static func playSound(scene : Node, audio : AudioStream, volume : float):
#	var streamPlayer = AudioStreamPlayer.new()
#	streamPlayer.bus = "SFX"
#	scene.add_child(streamPlayer);
#	streamPlayer.stream = audio
#	streamPlayer.volume_db = volume
#	streamPlayer.play()
#	yield(streamPlayer, "finished")
#	streamPlayer.queue_free()
