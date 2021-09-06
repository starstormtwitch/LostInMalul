extends Node2D


onready var camera = $Camera2D
onready var player = $LirikYaki
onready var firstLockCollision = $FirstRoomLockArea

var _lockCamera = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !_lockCamera:
		camera.position = player.position

func _on_FirstRoomLockArea_area_entered(area):
	print("first collision detect: " + area.name)
	_lockCamera = true
	firstLockCollision.monitoring = false
