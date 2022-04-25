extends Area2D


var superOrbSound = preload("res://assets/audio/PickupSounds/super_orb_pickup.wav")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_SuperOrb_body_entered(body):
	if body.is_in_group("Player"):
		set_collision_mask_bit(0, false);
		SoundPlayer.playSound(get_tree().get_current_scene(), superOrbSound, 0)
		body.superChargeCollected()
		queue_free()
