extends Object

#In charge of handling camera movemtents and events in scenes
class_name CameraManager

var _player: KinematicBody2D
var _camera: Camera2D
var _lockCamera = false
var _currentCameraPosition: Vector2

const _SMOOTHING = 0.05

func _init(player, camera):
	_camera = camera
	_player = player
	_currentCameraPosition = player.position

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
	_camera.position


#Unlock the camera for updates again
func unlockTheCamera():
	_lockCamera = false
