extends Node2D

var _LABEL_POSITION_OFFSET = 100

var _lockCamera = false
var _startCountDown = 5
var _timerOn = false

onready var camera = $Camera2D
onready var player = $LirikYaki
onready var firstLockArea = $FirstRoomLockArea
onready var cameraManager = CameraManager.new(player, camera)
onready var label = $CanvasLayer/Label
onready var leftFirstRoomCollider = $FirstRoomBattleBoundary/LeftSide
onready var rightFirstRoomCollider = $FirstRoomBattleBoundary/RightSide

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cameraManager.followPlayerIfUnlocked()
	_handleTimerUpdate(delta)


# Event when hitting the First Room lock area, will lock camera, and player to that area
func _on_FirstRoomLockArea_area_entered(area):
	print("first collision detect: " + area.name)
	# I use players position to lock the camera to, but it might be better to define
	# an actual space on the map/scene
	cameraManager.lockCameraToPosition(player.position)
	firstLockArea.queue_free() # disable any recurring events
	enableFirstRoomBoundaries()
	_startTimer()


# Update countdown value left. Update timer text if not over, otherwise
# hide the timer text, and disable boundaries
func _handleTimerUpdate(delta):
	if _timerOn:
		_startCountDown -= delta
		if _startCountDown > 0:
			_updateTimerText(_startCountDown)
		else:
			_timerOn = false
			hideTimerText()
			cameraManager.unlockTheCamera()
			hideFirstRoomBoundaries()


# Round countdown timer up, and then display text
func _updateTimerText(time):
	var roundedTime = ceil(time)
	label.text = String(roundedTime)


func hideTimerText():
	label.text = ""


func enableFirstRoomBoundaries():
	# set deffered I believe waits until the next physics process happens,
	# and then does the following action. This will make sure that the following
	# physics changes actully happens, instead of just dissapearing when done normally
	leftFirstRoomCollider.set_deferred("disabled", false)
	rightFirstRoomCollider.set_deferred("disabled", false)


func hideFirstRoomBoundaries():
	leftFirstRoomCollider.set_deferred("disabled", true)
	rightFirstRoomCollider.set_deferred("disabled", true)


#Start the timer, and setup countdown text
func _startTimer():
	_startCountDown = 5
	_timerOn = true
	label.text = "5"
