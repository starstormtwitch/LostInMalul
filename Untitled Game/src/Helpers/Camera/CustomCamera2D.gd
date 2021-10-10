extends Camera2D

#In charge of handling camera movements and events in scenes
class_name CustomCamera2D

const _DEFAULT_CAMERA_LIMIT_TOP_LEFT = -10000000
const _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT = 10000000
const _DEFAULT_CAMERA_ZOOM = Vector2(0.4,0.4)

const _SMOOTHING = 0.05

var _remoteTransform2d: RemoteTransform2D
var _panTarget: CustomCamera2DPanTarget

#variables for any smooth limit in progress
var _limit_smooth_top: float
var _limit_smooth_left: float
var _limit_smooth_bottom: float
var _limit_smooth_right: float
var _limit_smooth_active: bool = false
var _limit_smooth_target_position: Vector2

var _verbose = true

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
	if _limit_smooth_active:
		var smoothSpeed = 4
		var cameraReachedTarget = self.position.x == _limit_smooth_target_position.x && self.position.y == _limit_smooth_target_position.y
		if !cameraReachedTarget:
			self.position.x = move_toward(self.position.x, _limit_smooth_target_position.x, smoothSpeed)
			self.position.y = move_toward(self.position.y, _limit_smooth_target_position.y, smoothSpeed)
		var limitsReachedTarget = self.limit_top == _limit_smooth_top && self.limit_bottom == _limit_smooth_bottom && self.limit_left == _limit_smooth_left && self.limit_right == _limit_smooth_right
		if !limitsReachedTarget:
			self.limit_top = move_toward(self.limit_top, _limit_smooth_top, smoothSpeed)
			self.limit_bottom = move_toward(self.limit_bottom, _limit_smooth_bottom, smoothSpeed)
			self.limit_left = move_toward(self.limit_left, _limit_smooth_left, smoothSpeed)
			self.limit_right = move_toward(self.limit_right, _limit_smooth_right, smoothSpeed)
		if cameraReachedTarget && limitsReachedTarget:
			_limit_smooth_active = false
			self.smoothing_enabled = false
			setRemoteUpdates(true)
	elif _panTarget != null:
		var panTargetPosition = _panTarget.getPosition()
		var distanceToTarget = self.position.distance_to(panTargetPosition)
		self.position = lerp(self.get_global_position(), panTargetPosition,  delta * _panTarget._speed * abs(log(distanceToTarget)))
		self.zoom = lerp(self.zoom, _panTarget._zoom , (delta * _panTarget._zoomSpeed) / distanceToTarget) #formula can/must be improved
		if _panTarget.ClearTimer == null && distanceToTarget < 25: #magic number that works well enough for now
			yield(_panTarget.startPanTimer(), "timeout")
			clearPan()

func panToTarget(target: CustomCamera2DPanTarget) -> void:
	if _verbose:
		print("CustomCamera2D: Pan to target.")
	setRemoteUpdates(false)
	_panTarget = target

func clearPan() -> void:
	if _panTarget != null:
		if _verbose:
			print("CustomCamera2D: Clear pan.")
		_panTarget = null
		setRemoteUpdates(true)
		self.zoom = _DEFAULT_CAMERA_ZOOM

func temporarylyFocusOn(target: Node, time: float, zoom: Vector2) -> void:
	if _verbose:
		print("CustomCamera2D: Focus on target.")
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
	if _verbose:
		print("CustomCamera2D: Set remote updates (follow player) to " + str(update))
	_remoteTransform2d.update_position = update
	_remoteTransform2d.update_rotation = update
	_remoteTransform2d.update_scale = update

func limitCameraToDelimiter(delimiter: CustomDelimiter2D, smooth: bool = false) -> void:
	limitCameraToCoordinates(delimiter.getTop(), delimiter.getLeft(), delimiter.getBottom(), delimiter.getRight(), smooth)

func limitCameraToPositions(topLeft: Position2D, bottomRight: Position2D, smooth: bool = false) -> void:
	var globalTopLeft = topLeft.get_global_position()
	var globalBottomRight = bottomRight.get_global_position()
	limitCameraToCoordinates(globalTopLeft.y, globalTopLeft.x, globalBottomRight.y, globalBottomRight.x, smooth)

func limitCameraToCoordinates(top: int, left: int, bottom: int, right: int, smooth: bool = false) -> void:
	if smooth:
		setRemoteUpdates(false)
		self.smoothing_enabled = true
		self.smoothing_speed = 100
		_limit_smooth_top = top
		_limit_smooth_left = left
		_limit_smooth_bottom = bottom
		_limit_smooth_right = right
		var xDist = (self.get_viewport_rect().size.x / 2) * self.zoom.x
		var yDist = (self.get_viewport_rect().size.y / 2) * self.zoom.y
		_limit_smooth_target_position = Vector2(self.position.x, self.position.y)
		if self.limit_top < _limit_smooth_top:
			_limit_smooth_target_position.y = top + yDist
		if self.limit_left < _limit_smooth_left: 
			_limit_smooth_target_position.x = left + xDist
		if self.limit_bottom > _limit_smooth_bottom:
			_limit_smooth_target_position.y = bottom - yDist
		if self.limit_right > _limit_smooth_right:
			_limit_smooth_target_position.x = right - xDist
		#print(_limit_smooth_target_position)
		#var x = _limit_smooth_left + (self.get_viewport_rect().size.x / 2) * self.zoom.x
		#var y = _limit_smooth_bottom + (self.get_viewport_rect().size.y / 2) * self.zoom.y
	else:
		clearPan() #todo: review this, but its a good idea to clear camera effects if the camera changes limits
		self.limit_top = top
		self.limit_left = left
		self.limit_bottom = bottom
		self.limit_right = right
	_limit_smooth_active = smooth
	if _verbose:
		print("CustomCamera2D: New camera limits (Smooth:"+str(smooth)+") Top/Left/Bottom/Right " 
		+ str(top) + "/" + str(left) + "/" + str(bottom) + "/" + str(right))

func resetLimits() -> void:
	if _verbose:
		print("CustomCamera2D: Reset camera limits.")
	limitCameraToCoordinates(_DEFAULT_CAMERA_LIMIT_TOP_LEFT, _DEFAULT_CAMERA_LIMIT_TOP_LEFT, _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT, _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT)
	

#inner classes

class CustomCamera2DPanTarget:
	#variables for any pan effect in progress
	const _DEFAULT_PAN_TIME = 1
	const _DEFAULT_PAN_SPEED = 1
	const _DEFAULT_PAN_ZOOM = Vector2(0.2,0.2)
	const _DEFAULT_PAN_ZOOM_SPEED = 7
	var _target: Node = null
	var _time: float
	var _speed: float
	var _zoom: Vector2
	var _zoomSpeed: float
	var _clearTimer: SceneTreeTimer = null
	
	func _init(target: Node, time: float = _DEFAULT_PAN_TIME, speed: float = _DEFAULT_PAN_SPEED, zoom: Vector2 = _DEFAULT_PAN_ZOOM, zoomSpeed: float = _DEFAULT_PAN_ZOOM_SPEED):
		_target = target
		_time = time
		_speed = speed
		_zoom = zoom
		_zoomSpeed = zoomSpeed
	
	func getPosition() -> Vector2:
		return _target.get_global_position()
	
	func startPanTimer() -> SceneTreeTimer:
		_clearTimer = _target.get_tree().create_timer(_time)
		return _clearTimer
