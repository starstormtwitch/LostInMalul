extends StaticBody2D

# Initially at 0, characters are made to move by the ObjectPool.
var g_velocity: float = 0

const traffic1 = preload("res://assets/audio/traffic1.mp3")
const traffic2 = preload("res://assets/audio/traffic2.mp3")
const traffic3 = preload("res://assets/audio/traffic3.mp3")
const traffic4 = preload("res://assets/audio/traffic4.mp3")

func _process(_delta: float) -> void:
	position.x += g_velocity
	if(g_velocity > 1):
		$Sprite.flip_h = true
		$CollisionShape2D.scale.x = -1
	else:
		$Sprite.flip_h = false
		$CollisionShape2D.scale.x = 1

# @note: for ObjectPool.
func get_height() -> float:
	return $Sprite.texture.get_size().y * scale.y * $Sprite.scale.y
	
# @note: for ObjectPool.
func reset() -> void:
	g_velocity = 0
	
# @note: for ObjectPool.
func start(velocity: float) -> void:
	g_velocity = -velocity
	var current_traffic_noise = LevelGlobals.rng.randi_range(1,4)
	match current_traffic_noise:
		1:
			SoundPlayer.playSound(get_tree().get_current_scene(), traffic1, 1)
		2:
			SoundPlayer.playSound(get_tree().get_current_scene(), traffic2, 1)
		3:
			SoundPlayer.playSound(get_tree().get_current_scene(), traffic3, 1)
		4:
			SoundPlayer.playSound(get_tree().get_current_scene(), traffic4, 1)
	#$AnimationPlayer.play('Walk')
