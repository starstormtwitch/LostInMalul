extends Area2D

var defenseSound = preload("res://assets/audio/PickupSounds/defense_up.wav")

func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		SoundPlayer.playSound(get_tree().get_current_scene(), defenseSound, 0)
		queue_free()
