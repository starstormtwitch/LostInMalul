extends AudioStreamPlayer

class_name SelfDisposingAudioPlayer

func _on_SelfDisposingMusicPlayer_finished():
	queue_free()

func Play():
	.play()
