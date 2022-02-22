extends KinematicBody2D

func dispose() -> void:
	queue_free()


func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		var randomVelocity = Vector2.ZERO;
		randomVelocity.x = rand_range(-1,1);
		randomVelocity.y = rand_range(-1,1);
		area.get_parent().take_damage(1, randomVelocity.normalized(), 1000)
