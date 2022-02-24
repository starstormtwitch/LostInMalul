extends Area2D

var coinSound = preload("res://assets/audio/PickupSounds/coin_pickup.wav")

func _ready():
	pass # Replace with function body.
  
func _on_Coin_body_entered(body):
	if body.is_in_group("Player"):
		set_collision_mask_bit(0, false);
		SoundPlayer.playSound(get_tree().get_current_scene(), coinSound, 0)
		body.collectCoin()
		queue_free()
