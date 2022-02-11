extends Area2D

var coinSound = preload("res://assets/audio/PickupSounds/coin_pickup.wav")

func _ready():
	pass # Replace with function body.


func _on_Coin_body_entered(body):
	if body.is_in_group("Player"):
		SoundPlayer.playSound(get_tree().get_current_scene(), coinSound, 0)
		queue_free()
