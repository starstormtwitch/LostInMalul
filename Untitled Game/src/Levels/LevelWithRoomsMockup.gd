extends Node2D


onready var camera = $Camera2D
onready var player = $yaki_lirik
onready var firstLockCollision = $FirstRoomLockArea

var _lockCamera = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !_lockCamera:
		camera.position = player.position


func _onFirstRoomCollisionDetected(area):
	if(area.name == "FirstRoomLockArea"):
		print("first collision detect")
		_lockCamera = true
		firstLockCollision.monitoring = false
