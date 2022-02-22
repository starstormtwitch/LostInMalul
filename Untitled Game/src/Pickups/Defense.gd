extends Area2D

var defenseSound = preload("res://assets/audio/PickupSounds/defense_up.wav")
signal defense_collected

func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if body.is_in_group("Player"):
		set_collision_mask_bit(0, false);
		SoundPlayer.playSound(get_tree().get_current_scene(), defenseSound, 0)
		body.defenseUpCollected();
		queue_free()
