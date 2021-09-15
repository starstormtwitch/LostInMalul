extends Object

# In charge of managing arena room battles, will trigger when player hits the
# The area2d for the room. When event start it will enable static bodies in room 
# to keep the player in it. 
class_name ArenaRoomManager


var _cameraManager: CameraManager
var _arenaRoomTrigger: Area2D
var _arenaRoomColliders: Array
var _timerText: Label

var _startCountDown = 5
var _timerOn = false

func _init(cameraManager, arenaRoomTrigger, arenaRoomColliders, timerText):
	assert(cameraManager, "cameraManager does not exist")
	assert(arenaRoomTrigger, "arenaRoomTrigger does not exist")
	assert(arenaRoomColliders, "arenaRoomColliders does not exist")
	assert(timerText, "timerText does not exist")
	_cameraManager = cameraManager
	_arenaRoomTrigger = arenaRoomTrigger
	_arenaRoomColliders = arenaRoomColliders
	_timerText = timerText


func initiateRoomBattle(position):
	_cameraManager.lockCameraToPosition(position)
	_arenaRoomTrigger.queue_free()
	_enableRoomBoundaries()
	startTimer()


# Update countdown value left. Update timer text if not over, otherwise
# hide the timer text, and disable boundaries
func handleTimeUpdate(delta):
	if _timerOn:
		_startCountDown -= delta
		if _startCountDown > 0:
			_updateTimerText(_startCountDown)
		else:
			_timerOn = false
			_hideTimerText()
			_cameraManager.unlockTheCamera()
			_hideRoomBoundaries()


# Round countdown timer up, and then display text
func _updateTimerText(time):
	var roundedTime = ceil(time)
	_timerText.text = String(roundedTime)


func _enableRoomBoundaries():
	for boundary in _arenaRoomColliders:
		# set deffered I believe waits until the next physics process happens,
		# and then does the following action. This will make sure that the following
		# physics changes actully happens, instead of just dissapearing when done normally
		boundary.set_deferred("disabled", false)


func _hideRoomBoundaries():
	for boundary in _arenaRoomColliders:
		boundary.set_deferred("disabled", true)

# Start the timer, and setup countdown text
func startTimer():
	_startCountDown = 5
	_timerOn = true
	_timerText.text = "5"


func _hideTimerText():
	_timerText.text = ""
