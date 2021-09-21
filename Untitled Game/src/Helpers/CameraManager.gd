extends Object

#In charge of handling camera movemtents and events in scenes
class_name CameraManager

var _player: KinematicBody2D
var _camera: Camera2D
var _lockCamera = false
var _currentCameraPosition: Vector2
var _verbose = true

const _SMOOTHING = 0.05

func _init(player, camera):
	assert(player, "player does not exist")
	assert(camera, "camera does not exist")
	_camera = camera
	_player = player
	_currentCameraPosition = player.position
	_camera.current = true
	#_camera.smoothing_enabled = true
	#_camera.smoothing_speed = _SMOOTHING

func limitCameraToPositions(topLeft, bottomRight):
	limitCameraToCoordinates(topLeft.position.y, topLeft.position.x, bottomRight.position.y, bottomRight.position.x)

func limitCameraToCoordinates(top, left, bottom, right):
	_camera.limit_top = top
	_camera.limit_left = left
	_camera.limit_bottom = bottom
	_camera.limit_right = right
	if _verbose:
		print("new camera limits (top/left/bottom/right)")
		print(_camera.limit_top)
		print(_camera.limit_left)
		print(_camera.limit_bottom)
		print(_camera.limit_right)
	
func resetLimits():
	limitCameraToCoordinates(-10000000, -10000000, 10000000, 10000000)

# Updates camera to player's position when unlocked
# Would call this in parent nodes _process function, to get camera updates when available
func followPlayerIfUnlocked(): 
	if !_lockCamera:
		var targetX = int(lerp(_currentCameraPosition.x, _player.position.x, _SMOOTHING))
		var targetY = int(lerp(_currentCameraPosition.y, _player.position.y, _SMOOTHING))
		_currentCameraPosition = Vector2(targetX, targetY)
		_camera.position = _currentCameraPosition

# Moves camera to positions, and disables camera updates until unlocked again
func lockCameraToPosition(position):
	_lockCamera = true
	_camera.position = position

#Unlock the camera for updates again
func unlockTheCamera():
	_lockCamera = false
