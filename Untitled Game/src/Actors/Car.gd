extends KinematicBody2D


const _SPEED = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	_drive()


func _drive():
	move_and_slide(Vector2(_SPEED, 0))
