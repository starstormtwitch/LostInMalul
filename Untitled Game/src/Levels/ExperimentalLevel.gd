extends Node2D


onready var player = get_node("YSort/Player")
onready var camera = get_node("YSort/Player/Camera2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("YSort/BathroomScene1")._set_Camera_To_Area(camera)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_RightExit_body_entered(body):
	if body == player:
		get_node("YSort/BathroomScene2")._set_Camera_To_Area(camera)

func _on_LeftExit_body_entered(body):
	if body == player:
		get_node("YSort/BathroomScene2")._set_Camera_To_Area(camera)
