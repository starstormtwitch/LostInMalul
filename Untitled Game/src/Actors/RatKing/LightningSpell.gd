extends KinematicBody2D

const laserSound = preload("res://assets/audio/BossLaser.mp3")
const zapSound = preload("res://assets/audio/zapHit.mp3")

func dispose() -> void:
	SoundPlayer.playSound(get_tree().get_current_scene(), laserSound, 5)
	queue_free()


func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		var randomVelocity = Vector2.ZERO;
		randomVelocity.x = rand_range(-1,1);
		randomVelocity.y = rand_range(-1,1);
		SoundPlayer.playSound(get_tree().get_current_scene(), zapSound, 5)
		area.get_parent().take_damage(1, randomVelocity.normalized(), 1000)
