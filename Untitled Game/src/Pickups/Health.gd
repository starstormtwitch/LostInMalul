extends Area2D

var healthSound = preload("res://assets/audio/PickupSounds/health_pickup.wav")

func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		SoundPlayer.playSound(get_tree().get_current_scene(), healthSound, 0)
		queue_free()
