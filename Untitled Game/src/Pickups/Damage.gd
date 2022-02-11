extends Area2D

var damageSound = preload("res://assets/audio/PickupSounds/damage_up.wav")

func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		SoundPlayer.playSound(get_tree().get_current_scene(), damageSound, 5)
		queue_free()

