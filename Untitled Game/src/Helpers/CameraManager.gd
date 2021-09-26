extends Node

#In charge of handling camera movemtents and events in scenes
class_name CameraManager

var _player: KinematicBody2D
var _camera: Camera2D
var _remote2d: RemoteTransform2D
var _lockCamera = false
var _currentCameraPosition: Vector2
var _verbose = true
var _defaultZoom = Vector2(0.2,0.2)

var _panSpeed = 1.5
var _panTarget = null

const _DEFAULT_CAMERA_LIMIT_TOP_LEFT = -10000000
const _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT = 10000000

const _SMOOTHING = 0.05

#func _init(player, camera):
#	assert(player, "player does not exist")
#	assert(camera, "camera does not exist")
#	_camera = camera
#	_player = player
#	_currentCameraPosition = player.position
#	_camera.current = true
#	#_camera.smoothing_enabled = true
#	#_camera.smoothing_speed = _SMOOTHING

func _init(cameraTarget: Node, current: bool):
	assert(cameraTarget, "Camera target is not a node.")
	_remote2d = RemoteTransform2D.new()	
	_camera = Camera2D.new()
	cameraTarget.get_tree().current_scene.add_child(_camera)
	#cameraTarget.get_tree().current_scene.call_deferred("add_child", _camera)
	_remote2d.remote_path = _camera.get_path()	
	cameraTarget.add_child(_remote2d)	
	_camera.zoom = _defaultZoom
	_camera.current = current
	cameraTarget.get_tree().current_scene.add_child(self)
	
func _ready():
	self.set_process(true)

func _process(delta):
	if _panTarget != null:
		_camera.position = lerp(_camera.get_global_position(), _panTarget.get_global_position(),  delta * _panSpeed)
	
func panToTarget(target: Node, time: float) -> void:
	print("pan to target")
	_remote2d.update_position = false
	_panTarget = target
#	print(_camera.get_global_position())
#	print(target.get_global_position())
	#var target_dir = (target.get_global_position() - _camera.get_global_position()).normalized()
	#_camera.position += _panSpeed * target_dir # * delta
	#_camera.position = lerp(get_global_position(), target.get_global_position(), delta*speed)
#	while _camera.position != target.position:
#		_camera.position = lerp(_camera.get_global_position(), target.get_global_position(), _panSpeed)
#	print(_camera.get_global_position().round())
#	print(target.get_global_position().round())
	
	
func temporarylyFocusOn(target: Node, time: float, zoom: Vector2) -> void:
	var newRemote = RemoteTransform2D.new()
	target.add_child(newRemote)
	_remote2d.update_position = false
	newRemote.remote_path = _camera.get_path()
	_camera.zoom = zoom
	yield(target.get_tree().create_timer(time), "timeout")
	newRemote.update_position = false
	newRemote.queue_free()
	_remote2d.update_position = true
	_camera.zoom = _defaultZoom
	
	
func limitCameraToPositions(topLeft: Position2D, bottomRight: Position2D) -> void:
	limitCameraToCoordinates(topLeft.position.y, topLeft.position.x, bottomRight.position.y, bottomRight.position.x)

func limitCameraToCoordinates(top: float, left: float, bottom: float, right: float) -> void:
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
	
func resetLimits() -> void:
	limitCameraToCoordinates(_DEFAULT_CAMERA_LIMIT_TOP_LEFT, _DEFAULT_CAMERA_LIMIT_TOP_LEFT, _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT, _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT)

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
