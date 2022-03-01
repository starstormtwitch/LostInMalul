extends Area2D

var healthSound = preload("res://assets/audio/PickupSounds/health_pickup.wav")
signal health_collected

func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		set_collision_mask_bit(0, false);
		SoundPlayer.playSound(get_tree().get_current_scene(), healthSound, 0)
		body.healthCollected();
		queue_free()
