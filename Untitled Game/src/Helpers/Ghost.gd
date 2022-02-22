extends Sprite

class_name Ghost

const _VANISH_TIMER = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	$alpha_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1),
		Color(1, 1, 1, 0), _VANISH_TIMER, Tween.TRANS_SINE, Tween.EASE_IN)
	
	$alpha_tween.start()


func _on_alpha_tween_tween_completed(object, key):
	queue_free()


func set_paramaters_for_ghost(sprite: Sprite, position: Vector2):
	self.global_position = position
	self.texture = sprite.texture
	self.flip_h = sprite.flip_h
	self.hframes = sprite.hframes
	self.vframes = sprite.vframes
	self.frame = sprite.frame
