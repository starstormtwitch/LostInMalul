extends CustomParticles

class_name SmokeParticles

# Called when the node enters the scene tree for the first time.
func _ready():
	#print("loading particle")
	yield(get_tree().create_timer(.5), "timeout")
	queue_free()
