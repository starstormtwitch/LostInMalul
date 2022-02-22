extends AudioStreamPlayer2D

func _on_SelfDisposingMusicPlayer_finished():
	queue_free()

func Play():
	.play()
