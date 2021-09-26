extends Camera2D

#In charge of handling camera movemtents and events in scenes
class_name CustomCamera2D

const _DEFAULT_CAMERA_LIMIT_TOP_LEFT = -10000000
const _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT = 10000000
const _DEFAULT_CAMERA_ZOOM = Vector2(0.4,0.4)
const _DEFAULT_PAN_TIME = 1
const _DEFAULT_PAN_SPEED = 3
const _DEFAULT_PAN_ZOOM = Vector2(0.2,0.2)
const _DEFAULT_PAN_ZOOM_SPEED = 7

const _SMOOTHING = 0.05

var _remoteTransform2d: RemoteTransform2D

var _verbose = true

var _panSpeed: float = _DEFAULT_PAN_SPEED
var _panTime: float = _DEFAULT_PAN_TIME
var _panTarget = null
var _panZoom: Vector2 = _DEFAULT_PAN_ZOOM
var _panZoomSpeed: float = _DEFAULT_PAN_ZOOM_SPEED

func _init(cameraTarget: Node, current: bool):
	assert(cameraTarget, "Camera target is not a node.")
	cameraTarget.get_tree().current_scene.add_child(self)
	_remoteTransform2d = RemoteTransform2D.new()	
	_remoteTransform2d.remote_path = self.get_path()	
	cameraTarget.add_child(_remoteTransform2d)	
	self.zoom = _DEFAULT_CAMERA_ZOOM
	self.current = current
	
func _ready():
	self.set_process(true)

func _process(delta):
	if _panTarget != null:
		var panTargetPosition = _panTarget.get_global_position()
		self.position = lerp(self.get_global_position(), _panTarget.get_global_position(),  delta * _panSpeed)
		var distanceToTarget = self.position.distance_to(panTargetPosition)
		self.zoom = lerp(self.zoom, _panZoom, (delta * _panZoomSpeed) / distanceToTarget)
		if distanceToTarget < 25:
			if _panTime == null:
				_panTime = _DEFAULT_PAN_TIME
			yield(self.get_tree().create_timer(_panTime), "timeout")
			clearPan()
	
func panToTarget(target: Node, time: float = _DEFAULT_PAN_TIME, zoom: Vector2 = _DEFAULT_PAN_ZOOM, speed: float = _DEFAULT_PAN_SPEED) -> void:
	if _verbose:
		print("pan to target")
	setRemoteUpdates(false)
	_panTarget = target
	_panTime = time
	_panSpeed = speed
	
func clearPan() -> void:
	_panTarget = null
	setRemoteUpdates(true)
	self.zoom = _DEFAULT_CAMERA_ZOOM
	_panTime = _DEFAULT_PAN_TIME
	_panSpeed = _DEFAULT_PAN_SPEED
	_panZoom = _DEFAULT_PAN_ZOOM
		
func temporarylyFocusOn(target: Node, time: float, zoom: Vector2) -> void:
	if _verbose:
		print("focus on target")
	var newRemote = RemoteTransform2D.new()
	target.add_child(newRemote)
	setRemoteUpdates(false)
	newRemote.remote_path = self.get_path()
	self.zoom = zoom
	yield(target.get_tree().create_timer(time), "timeout")
	newRemote.update_position = false
	newRemote.queue_free()
	setRemoteUpdates(true)
	self.zoom = _DEFAULT_CAMERA_ZOOM
	
func setRemoteUpdates(update: bool) -> void:
	_remoteTransform2d.update_position = update
	_remoteTransform2d.update_rotation = update
	_remoteTransform2d.update_scale = update
		
func limitCameraToPositions(topLeft: Position2D, bottomRight: Position2D) -> void:
	limitCameraToCoordinates(topLeft.position.y, topLeft.position.x, bottomRight.position.y, bottomRight.position.x)

func limitCameraToCoordinates(top: float, left: float, bottom: float, right: float) -> void:
	self.limit_top = top
	self.limit_left = left
	self.limit_bottom = bottom
	self.limit_right = right
	if _verbose:
		print("new camera limits (top/left/bottom/right)")
		print(self.limit_top)
		print(self.limit_left)
		print(self.limit_bottom)
		print(self.limit_right)
	
func resetLimits() -> void:
	if _verbose:
		print("reset camera limits")
	limitCameraToCoordinates(_DEFAULT_CAMERA_LIMIT_TOP_LEFT, _DEFAULT_CAMERA_LIMIT_TOP_LEFT, _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT, _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT)
