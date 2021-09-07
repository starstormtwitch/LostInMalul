extends Object

#In charge of handling camera movemtents and events in scenes
class_name CameraManager

var _player: KinematicBody2D
var _camera: Camera2D
var _lockCamera = false

func _init(player, camera):
	_camera = camera
	_player = player


# Updates camera to player's position when unlocked
# Would call this in parent nodes _process function, to get camera updates when available
func followPlayerIfUnlocked(): 
	if !_lockCamera:
		_camera.position = _player.position


# Moves camera to positions, and disables camera updates until unlocked again
func lockCameraToPosition(position):
	_lockCamera = true
	_camera.position


#Unlock the camera for updates again
func unlockTheCamera():
	_lockCamera = false
