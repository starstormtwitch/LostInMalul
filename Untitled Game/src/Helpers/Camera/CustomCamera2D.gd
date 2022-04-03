extends Camera2D

#In charge of handling camera movements and events in scenes
class_name CustomCamera2D

const _DEFAULT_CAMERA_LIMIT_TOP_LEFT: int = -10000000
const _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT: int = 10000000
const _DEFAULT_CAMERA_ZOOM: Vector2 = Vector2(0.4,0.4)
const _DEFAULT_CAMERA_SMOOTH_STRANSITION_SPEED: int = 4

const _DEFAULT_PAN_TIME = 1
const _DEFAULT_PAN_SPEED = 1
const _DEFAULT_PAN_ZOOM = Vector2(0.2,0.2)
const _DEFAULT_PAN_ZOOM_SPEED = 7

#const _SMOOTHING = 0.05

enum TransitionTypeEnum {INSTANT = 0, SMOOTH = 1, FADE = 2}

signal pan_started
signal pan_finished
signal smooth_limit_started
signal smooth_limit_finished

var _remoteTransform2d: RemoteTransform2D
var _panTarget: CustomCamera2DPanTarget
var _animationPlayer: CustomCamera2DSimpleTransitionPlayer
var _currentDelimiter: CustomDelimiter2D = null

#variables for any smooth limit in progress
var _limit_smooth_top: float
var _limit_smooth_left: float
var _limit_smooth_bottom: float
var _limit_smooth_right: float
var _limit_smooth_active: bool = false
var _limit_smooth_target_position: Vector2

var _verbose = true

#variables for shaking
var _duration = 0.1
var _period_in_ms = 15
var _amplitude = 4
var _timer = 0.0
var _last_shook_timer = 0
var _previous_x = 0.0
var _previous_y = 0.0
var _last_offset = Vector2(0, 0)
var _is_shaking = false

#bounding area
var _leftBound: StaticBody2D = null
var _rightBound: StaticBody2D = null
var _upperBound: StaticBody2D = null
var _bottomBound: StaticBody2D = null
var _boundWidth: int = 5
var _defaultBoundLength: int = 10000000

func _init(cameraTarget: Node, current: bool):
	assert(cameraTarget, "Camera target is not a node.")
	cameraTarget.get_tree().current_scene.add_child(self)
	_remoteTransform2d = RemoteTransform2D.new()
	_remoteTransform2d.remote_path = self.get_path()
	cameraTarget.add_child(_remoteTransform2d)
	self.zoom = _DEFAULT_CAMERA_ZOOM
	self.current = current
	_animationPlayer = CustomCamera2DSimpleTransitionPlayer.new(cameraTarget.get_tree().current_scene)
	_get_new_camera_shake_values()
	_connect_to_settings_changed_signal()
	_configureBounds()
	
func _ready():
	self.set_process(true)
	#self.get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")	

#func _on_viewport_size_changed():
#	print("Viewport y: " + str(self.get_viewport().size.y))
#	print("viewport x: " + str(self.get_viewport().size.x))
	

func _process(delta):
	if _limit_smooth_active and !_is_shaking:
		var cameraReachedTarget = self.position.x == _limit_smooth_target_position.x && self.position.y == _limit_smooth_target_position.y
		if !cameraReachedTarget:
			self.position.x = move_toward(self.position.x, _limit_smooth_target_position.x, _DEFAULT_CAMERA_SMOOTH_STRANSITION_SPEED)
			self.position.y = move_toward(self.position.y, _limit_smooth_target_position.y, _DEFAULT_CAMERA_SMOOTH_STRANSITION_SPEED)
		var limitsReachedTarget = compareCameraLimitIsEqual(_limit_smooth_top, _limit_smooth_left, _limit_smooth_bottom, _limit_smooth_right)
		if !limitsReachedTarget:
			self.limit_top = move_toward(self.limit_top, _limit_smooth_top, _DEFAULT_CAMERA_SMOOTH_STRANSITION_SPEED)
			self.limit_bottom = move_toward(self.limit_bottom, _limit_smooth_bottom, _DEFAULT_CAMERA_SMOOTH_STRANSITION_SPEED)
			self.limit_left = move_toward(self.limit_left, _limit_smooth_left, _DEFAULT_CAMERA_SMOOTH_STRANSITION_SPEED)
			self.limit_right = move_toward(self.limit_right, _limit_smooth_right, _DEFAULT_CAMERA_SMOOTH_STRANSITION_SPEED)
		if cameraReachedTarget && limitsReachedTarget:
			_limit_smooth_active = false
			self.smoothing_enabled = false
			setRemoteUpdates(true)
			_updateBoundLimits()
			emit_signal("smooth_limit_finished")
	elif _panTarget != null and !_is_shaking:
		var panTargetPosition = _panTarget.getPosition()
		var distanceToTarget = self.position.distance_to(panTargetPosition)
		self.position = lerp(self.get_global_position(), panTargetPosition,  delta * _panTarget._speed * abs(log(distanceToTarget)))
		self.zoom = lerp(self.zoom, _panTarget._zoom , (delta * _panTarget._zoomSpeed) / distanceToTarget) #formula can/must be improved
		if _panTarget._clearTimer == null && distanceToTarget < 25: #magic number that works well enough for now
			yield(_panTarget.startPanTimer(), "timeout")
			clearPan()
	_handleShake(delta)


func _handleShake(delta):
	if _timer == 0:
		return
	# Only shake on certain frames.
	_last_shook_timer = _last_shook_timer + delta
	# Be mathematically correct in the face of lag; usually only happens once.
	while _last_shook_timer >= _period_in_ms:
		#print("continue shake")
		_last_shook_timer = _last_shook_timer - _period_in_ms
		# Lerp between [amplitude] and 0.0 intensity based on remaining shake time.
		var intensity = _amplitude * (1 - ((_duration - _timer) / _duration))
		 # Noise calculation logic from http://jonny.morrill.me/blog/view/14
		var new_x = rand_range(-1.0, 1.0)
		var x_component = intensity * (_previous_x + (delta * (new_x - _previous_x)))
		var new_y = rand_range(-1.0, 1.0)
		var y_component = intensity * (_previous_y + (delta * (new_y - _previous_y)))
		_previous_x = new_x
		_previous_y = new_y
		# Track how much we've moved the offset, as opposed to other effects.
		var new_offset = Vector2(x_component, y_component)
		set_offset(get_offset() - _last_offset + new_offset)
		_last_offset = new_offset
	# Reset the offset when we're done shaking.
	_timer = _timer - delta
	if _timer <= 0:
		#print("shake End")
		_is_shaking = false
		_timer = 0
		set_offset(get_offset() - _last_offset)


# Kick off a new screenshake effect.
func shake():
	# Initialize variables.
	#print("start shake")
	_timer = _duration
	_is_shaking = true
	_previous_x = rand_range(-.3, .3)
	_previous_y = rand_range(-.3, .3)
	# Reset previous offset, if any.
	var currentOffset = get_offset()
	#print("Current camera offset" + String(currentOffset))
	set_offset(get_offset() - _last_offset)
	_last_offset = Vector2(0, 0)

func shakeWith(duration: float, frequency: float, amplitude: float):
	pass


func panToTarget(target: Node, time: float = _DEFAULT_PAN_TIME, speed: float = _DEFAULT_PAN_SPEED, zoom: Vector2 = _DEFAULT_PAN_ZOOM, zoomSpeed: float = _DEFAULT_PAN_ZOOM_SPEED) -> void:
	if _verbose:
		print("CustomCamera2D: Pan to target.")
	setRemoteUpdates(false)
	_panTarget = CustomCamera2DPanTarget.new(target, time, speed, zoom, zoomSpeed)
	emit_signal("pan_started")

func clearPan() -> void:
	if _panTarget != null:
		if _verbose:
			print("CustomCamera2D: Clear pan.")
		_panTarget = null
		setRemoteUpdates(true)
		self.zoom = _DEFAULT_CAMERA_ZOOM
		emit_signal("pan_finished")

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
		print("CustomCamera2D: Set remote updates (follow target) to " + str(update))
	_remoteTransform2d.update_position = update
	_remoteTransform2d.update_rotation = update
	_remoteTransform2d.update_scale = update


func limitCameraToDelimiter(delimiter: CustomDelimiter2D, transitionType: int = TransitionTypeEnum.INSTANT) -> void:
	print("Limiting to new area")
	_currentDelimiter = delimiter
	limitCameraToCoordinates(delimiter.getTop(), delimiter.getLeft(), delimiter.getBottom(), delimiter.getRight(), transitionType)


func limitCameraToPositions(topLeft: Position2D, bottomRight: Position2D, transitionType: int = TransitionTypeEnum.INSTANT) -> void:
	var globalTopLeft = topLeft.get_global_position()
	var globalBottomRight = bottomRight.get_global_position()
	limitCameraToCoordinates(globalTopLeft.y, globalTopLeft.x, globalBottomRight.y, globalBottomRight.x, transitionType)


func limitCameraToCoordinates(top: int, left: int, bottom: int, right: int, transitionType: int = TransitionTypeEnum.INSTANT) -> void:
	if transitionType == TransitionTypeEnum.INSTANT:
		clearPan() #todo: review this, but its a good idea to clear camera effects if the camera changes limits
		setLimits(top, left, bottom, right)
	elif transitionType == TransitionTypeEnum.SMOOTH:
		setRemoteUpdates(false)
		self.smoothing_enabled = true
		self.smoothing_speed = 100
		_limit_smooth_top = top
		_limit_smooth_left = left
		_limit_smooth_bottom = bottom
		_limit_smooth_right = right
		var viewportRectSize = self.get_viewport_rect()
		var xDist = (viewportRectSize.size.x / 2) * self.zoom.x
		var yDist = (viewportRectSize.size.y / 2) * self.zoom.y
		_limit_smooth_target_position = Vector2(self.position.x, self.position.y)
		if self.limit_top < _limit_smooth_top:
			_limit_smooth_target_position.y = top + yDist
		if self.limit_bottom > _limit_smooth_bottom:
			_limit_smooth_target_position.y = bottom - yDist
		if self.limit_left < _limit_smooth_left: 
			_limit_smooth_target_position.x = left + xDist
		if self.limit_right > _limit_smooth_right:
			_limit_smooth_target_position.x = right - xDist
		emit_signal("smooth_limit_started")
	elif transitionType == TransitionTypeEnum.FADE:
		_animationPlayer.playFadeIn()
		yield(_animationPlayer._player, "animation_finished")
		setLimits(top, left, bottom, right)
		_animationPlayer.playFadeOut()
		yield(_animationPlayer._player, "animation_finished")
		
	_limit_smooth_active = transitionType == TransitionTypeEnum.SMOOTH	
	
	if _verbose:
		print("CustomCamera2D: New camera limits (Smooth:"+str(_limit_smooth_active)+") Top/Left/Bottom/Right " 
		+ str(top) + "/" + str(left) + "/" + str(bottom) + "/" + str(right))

func compareCameraLimitIsEqual(top: int, left: int, bottom: int, right: int) -> bool:
	return self.limit_top == top && self.limit_left == left && self.limit_bottom == bottom && self.limit_right == right

func compareCameraLimitIsEqualToDelimiter(delimiter: CustomDelimiter2D) -> bool:
	return compareCameraLimitIsEqual(delimiter.getTop(), delimiter.getLeft(), delimiter.getBottom(), delimiter.getRight())

func setLimits(top: int, left: int, bottom: int, right: int) -> void:
	self.limit_top = top
	self.limit_left = left
	self.limit_bottom = bottom
	self.limit_right = right
	_updateBoundLimits()


func resetLimits() -> void:
	if _verbose:
		print("CustomCamera2D: Reset camera limits.")
	limitCameraToCoordinates(_DEFAULT_CAMERA_LIMIT_TOP_LEFT, _DEFAULT_CAMERA_LIMIT_TOP_LEFT,\
		 _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT, _DEFAULT_CAMERA_LIMIT_BOTTOM_RIGHT)


func _set_shake_settings(duration: float, frequency: float, amplitude: float):
	_duration = duration
	_period_in_ms = 1.0 / frequency
	_amplitude = amplitude


func _connect_to_settings_changed_signal():
	var parent = get_parent()
	if(parent != null):
		var tree = parent.get_tree()
		var settings = tree.get_nodes_in_group("Settings")
		if(settings.size() > 0):
			var _settings = settings[0]
			print("Connecting settings signal to Camera2D")
			_settings.connect("settings_changed", self, "_get_new_camera_shake_values")
		else:
			printerr("No node in Settings group in parent tree. Needed to connect to signals. CustomCamera2D.gd::250") 
	else:
		printerr("No parent found. Needed to connect to signals. CustomCamera2D.gd::252")

# Callback for settings updated signal in PauseScreenContainer node
func _get_new_camera_shake_values():
	var values = Settings.load_screen_shake_settings()
	_set_shake_settings(values.duration, values.frequency, values.amplitude)
	#print("Load settings for camera shake")


## Configure collision shapes around the camera.
func _configureBounds() -> void:
	_leftBound = _createNewBound()
	_rightBound = _createNewBound()
	_upperBound = _createNewBound()
	_bottomBound = _createNewBound()
	
	_leftBound.rotate(PI/2) #90
	_rightBound.rotate(-PI/2) #-90
	_upperBound.rotate(PI) #180
	_bottomBound.rotate(0) #0 
	#by default one way collision aims "down"
	#the arrow on a one way collision points the angle that it can be traversed from.

## Set collision shapes around the camera to be positioned at the edges of its limits.
func _updateBoundLimits() -> void:
	#Calculate the lenght of the rectangles extents.
	#Rectangles will be centered and the extents are half of the rectangles x or y length.
	#Length will depend on the magnitude of the limits in the x or y coordinates for the camera.
	#Width remains constant, since we are rotating the rectangles.
	#Note: the length calculations can be "optional" if an "infinite" length is used instead, 
	# by removing these next lines and using always a high default value.
	var xlen = (self.limit_right - self.limit_left) / 2
	var ylen = (self.limit_bottom - self.limit_top) / 2
	_leftBound.shape_owner_get_shape(0,0).extents = Vector2(ylen, _boundWidth)
	_rightBound.shape_owner_get_shape(0,0).extents = Vector2(ylen, _boundWidth)
	_upperBound.shape_owner_get_shape(0,0).extents = Vector2(xlen, _boundWidth)
	_bottomBound.shape_owner_get_shape(0,0).extents = Vector2(xlen, _boundWidth)
	var xcenter = (self.limit_left + self.limit_right) / 2
	var ycenter = (self.limit_top + self.limit_bottom) / 2
	#Use bound width as an offset of the position to make the bounds be at the exact camera limits.
	_leftBound.position = Vector2(self.limit_left - _boundWidth, ycenter)
	_rightBound.position = Vector2(self.limit_right + _boundWidth, ycenter)
	_upperBound.position = Vector2(xcenter, self.limit_top - _boundWidth)
	_bottomBound.position = Vector2(xcenter, self.limit_bottom + _boundWidth)

## Base code for rectangle collision shape creation.
func _createNewBound() -> StaticBody2D:
	#create body, collision and shape
	var sb: StaticBody2D = StaticBody2D.new()
	var coll: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	coll.shape = rect
	#The rectangle's half extents. The width and height of this shape is twice the half extents.
	rect.extents = Vector2(_defaultBoundLength, _boundWidth)#shapes are rotated later
	sb.set_collision_layer_bit(LevelGlobals.GetLayerBit("Boundaries"),true) #set boundary layer
	sb.set_collision_mask_bit(LevelGlobals.GetLayerBit("Player"),true) #mask to player layer
	sb.set_collision_mask_bit(LevelGlobals.GetLayerBit("Enemy"),true) #mask to enemy layer
	coll.one_way_collision = true
	#coll.one_way_collision_margin = 10
	sb.add_child(coll)
	self.get_tree().current_scene.add_child(sb)
	return sb

#inner classes

#simple transitions class
class CustomCamera2DSimpleTransitionPlayer:
	const _Animation_Fade_Name: String = "fade"
	const _Animation_Fade_DefaultLength: float = 0.5
	const _Animation_Fade_DefaultIdleTime: float = 0.2
	signal animation_started
	signal animation_finished
	var _Animation_Fade_TrackIndex: int
	var _Animation_Fade_Animation: Animation
	var _canvas: CanvasLayer
	var _colorRect: ColorRect
	var _player: AnimationPlayer
	var _scene: Node
	
	func _init(scene: Node):
		_scene = scene
		_setupAnimationPlayer()
		_setupSimpleFade()
	
	func _setupAnimationPlayer() -> void:
		_canvas = CanvasLayer.new()
		_player = AnimationPlayer.new()
		_scene.add_child(_canvas)
		_scene.add_child(_player)
		_colorRect = ColorRect.new()
		_colorRect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_colorRect.color = Color(0,0,0,0)		
		_colorRect.set_size(Vector2(_scene.get_viewport().size.x * 2, _scene.get_viewport().size.y * 2))
		_canvas.add_child(_colorRect)
	
	func _setupSimpleFade() -> void:
		_Animation_Fade_Animation = Animation.new()
		_Animation_Fade_Animation.length = _Animation_Fade_DefaultLength
		_Animation_Fade_TrackIndex = _Animation_Fade_Animation.add_track(Animation.TYPE_VALUE)
		var animationTargetPath = _canvas.name + "/" + _colorRect.name + ":color"	
		_Animation_Fade_Animation.track_set_path(_Animation_Fade_TrackIndex, animationTargetPath)
		_Animation_Fade_Animation.track_insert_key(_Animation_Fade_TrackIndex, 0, Color(0,0,0,0)) #key idx 1
		_Animation_Fade_Animation.track_insert_key(_Animation_Fade_TrackIndex, _Animation_Fade_DefaultLength, Color(0,0,0,1)) #key idx 2
		_Animation_Fade_Animation.track_set_interpolation_type(_Animation_Fade_TrackIndex, Animation.INTERPOLATION_LINEAR)
		_player.add_animation(_Animation_Fade_Name, _Animation_Fade_Animation)
	
	func playFade(fadeLength: float = _Animation_Fade_DefaultLength, fadeIdleTime: float = _Animation_Fade_DefaultIdleTime) -> void:
		if fadeIdleTime == null || fadeIdleTime == 0:
			fadeIdleTime = _Animation_Fade_DefaultIdleTime
		playFadeIn(fadeLength)
		yield(_scene.get_tree().create_timer(fadeIdleTime), "timeout")
		playFadeOut(fadeLength)
	
	func playFadeIn(fadeLength: float = _Animation_Fade_DefaultLength) -> void:
		if fadeLength == null || fadeLength == 0:
			fadeLength = _Animation_Fade_DefaultLength
		if _player.current_animation == _Animation_Fade_Name:
			yield(_player,  "animation_finished")
		_player.play(_Animation_Fade_Name, -1, 1 / fadeLength, false)
		
	func playFadeOut(fadeLength: float = _Animation_Fade_DefaultLength) -> void:
		if fadeLength == null || fadeLength == 0:
			fadeLength = _Animation_Fade_DefaultLength
		if _player.current_animation == _Animation_Fade_Name:
			yield(_player, "animation_finished")
		_player.play(_Animation_Fade_Name, -1, -(1 / fadeLength), true)

#pan class
class CustomCamera2DPanTarget:	
	var _target: Node = null
	var _time: float
	var _speed: float
	var _zoom: Vector2
	var _zoomSpeed: float
	var _clearTimer: SceneTreeTimer = null
	
	func _init(target: Node, time: float, speed: float, zoom: Vector2, zoomSpeed: float):
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
