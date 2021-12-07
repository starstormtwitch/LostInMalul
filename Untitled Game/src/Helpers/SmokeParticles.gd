extends Particles2D

class_name SmokeParticles

# Called when the node enters the scene tree for the first time.
func _ready():
	print("loading particle")
	yield(get_tree().create_timer(2), "timeout")
	queue_free()

func flipSide(flip: bool):
	if flip:
		self.scale = Vector2(-1, 1)
	else:
		self.scale = Vector2(1, 1)
