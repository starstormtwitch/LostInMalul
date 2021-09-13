extends Node2D


onready var player = get_node("YSort/Player")
onready var camera = get_node("YSort/Player/Camera2D")
onready var bathroom1 = get_node("YSort/BathroomScene1")
onready var bathroom2 = get_node("YSort/BathroomScene2")

# Called when the node enters the scene tree for the first time.
func _ready():
	bathroom1._set_Camera_To_Area(camera)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_RightExit_body_entered(body):
	if body == player:
		bathroom2._set_Camera_To_Area(camera)

func _on_LeftExit_body_entered(body):
	if body == player:
		bathroom1._set_Camera_To_Area(camera)
