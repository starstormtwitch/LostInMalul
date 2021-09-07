extends Node2D


onready var camera = $Camera2D
onready var player = $LirikYaki
onready var firstLockCollision = $FirstRoomLockArea/FirstRoomLockCollision
onready var cameraManager = CameraManager.new(player, camera)

var _lockCamera = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cameraManager.followPlayerIfUnlocked()


func _on_FirstRoomLockArea_area_entered(area):
	print("first collision detect: " + area.name)
	# I use players position to lock the camera to, but it might be better to define
	# an actual space on the map/scene
	cameraManager.lockCameraToPosition(player.position)
	firstLockCollision.disabled = true
