extends Area2D

# Initially at 0, characters are made to move by the ObjectPool.
var g_velocity: float = 0

const traffic1 = preload("res://assets/audio/traffic1.mp3")
const traffic2 = preload("res://assets/audio/traffic2.mp3")
const traffic3 = preload("res://assets/audio/traffic3.mp3")
const traffic4 = preload("res://assets/audio/traffic4.mp3")
var spriteWidth

func _ready():
	spriteWidth = $Sprite.texture.get_width()

func _process(_delta: float) -> void:
	position.x += g_velocity * _delta
	if(g_velocity > 1):
		$Sprite.scale.x = -1
		$CollisionShape2D.position.x = (spriteWidth*2)-30
	else:
		$Sprite.scale.x = 1
		$CollisionShape2D.position.x = spriteWidth

# @note: for ObjectPool.
func get_height() -> float:
	return $Sprite.texture.get_size().y * scale.y * $Sprite.scale.y
	

func _on_Box_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(3, Vector2(0, LevelGlobals.rng.randf_range(-5,5)), 5000)

	
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

