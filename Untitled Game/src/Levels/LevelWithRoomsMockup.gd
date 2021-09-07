extends Node2D

var _LABEL_POSITION_OFFSET = 100

var _lockCamera = false
var _startCountDown = 5
var _timerOn = false

onready var camera = $Camera2D
onready var player = $LirikYaki
onready var firstLockCollision = $FirstRoomLockArea/FirstRoomLockCollision
onready var cameraManager = CameraManager.new(player, camera)
onready var label = $CanvasLayer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cameraManager.followPlayerIfUnlocked()
	_handleTimerUpdate(delta)


func _on_FirstRoomLockArea_area_entered(area):
	print("first collision detect: " + area.name)
	# I use players position to lock the camera to, but it might be better to define
	# an actual space on the map/scene
	cameraManager.lockCameraToPosition(player.position)
	firstLockCollision.disabled = true
	_startTimer()


func _handleTimerUpdate(delta):
	_startCountDown -= delta
	#print("Updating time: " + String(_startCountDown))
	if _startCountDown > 0:
		_updateTimerText(_startCountDown)
	else:
		_timerOn = false
		hideTimerText()
		cameraManager.unlockTheCamera()


func _updateTimerText(time):
	var roundedTime = ceil(time)
	label.text = String(roundedTime)


func hideTimerText():
	label.text = ""


func _startTimer():
	_startCountDown = 5
	_timerOn = true
	label.text = "5"
