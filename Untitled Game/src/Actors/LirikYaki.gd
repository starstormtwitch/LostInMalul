extends Actor

const trail_scene = preload("res://src/Helpers/Trail.tscn")

var _isAttacking = false
var _canTakeDamage = false
var _directionFacing = Vector2.ZERO
var _trail = []
var _invincibilityTimer = Timer.new()

onready var sprite = $Sprite
onready var leftFacingCollider = $LeftFacingCollider
onready var rightFacingCollider = $RightFacingCollider
onready var leftFacingHurtbox = $HurtArea/hurtboxFacingLeft
onready var rightFacingHurtBox = $HurtArea/hurtboxFacingRight

# Called when the node enters the scene tree for the first time.
func _ready():
	_invincibilityTimer.connect("timeout",self,"_on_invincibility_timeout") 
	_invincibilityTimer.one_shot = true
	add_child(_invincibilityTimer)
	_invincibilityTimer.start(3)
	
	_health = 10
	_acceleration = .1
	_speed = 600
	_directionFacing.x = .1;
	$TrailTimer.connect("timeout", self, "add_trail")
	$AnimationTree.active = true


func _physics_process(_delta: float) -> void:
	var direction = Vector2.ZERO
	
	if !_canTakeDamage:
		self.modulate =  Color(10,10,10,10) if Engine.get_frames_drawn() % 5 == 0 else Color(1,1,1,1)
	
	if(!_isAttacking):
		direction = evaluatePlayerInput()
		
	_velocity = getMovement(direction, _speed, _acceleration)
	_velocity = move_and_slide(_velocity)


func _on_invincibility_timeout():
	self.modulate = Color(1,1,1,1)
	_canTakeDamage = true


func add_trail():
	if(get_parent() != null):
		var trail      = trail_scene.instance()
		trail.player   = self
		trail.position = self.position
		get_parent().add_child(trail)
		_trail.push_front(trail)


func take_damage(damage: int, direction: Vector2, force: float) -> void:
	if _canTakeDamage:
		_canTakeDamage = false
		$AnimationTree.get("parameters/playback").travel("Hurt")
		_invincibilityTimer.start(2)
		.take_damage(damage, direction, force)


func evaluatePlayerInput() -> Vector2:
	#get direction for inputs
	var direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
		
	_handleCollidersForDifferentDirections(direction.x)
	_setBlendPositions(direction.x)
	
	#check attack inputs
	if Input.is_action_just_pressed("side_swipe_attack") or Input.is_action_pressed("side_swipe_attack"):
		$AnimationTree.get("parameters/playback").travel("SideSwipe")
		_isAttacking = true
		return Vector2.ZERO
	
	
	#set animation for direction and return for movement
	if direction == Vector2.ZERO:
		$AnimationTree.get("parameters/playback").travel("Idle")
	else:
		$AnimationTree.get("parameters/playback").travel("Walk")
	
	return direction

#Set value of blend for the next time we we call the animation
#Ignore value of 0, since we either arent moving or walking vertically
func _setBlendPositions(x_direction):
	if x_direction != 0:
		$AnimationTree.set("parameters/Hurt/blend_position", x_direction)
		$AnimationTree.set("parameters/Walk/blend_position", x_direction)
		$AnimationTree.set("parameters/Idle/blend_position", x_direction)
		$AnimationTree.set("parameters/SideSwipe/blend_position", x_direction)


#Disable and enable colliders depending which direction your facing
func _handleCollidersForDifferentDirections(x_direction):
	if x_direction > 0:
		leftFacingCollider.disabled = true
		rightFacingCollider.disabled = false
		leftFacingHurtbox.disabled = true
		rightFacingHurtBox.disabled = false
	elif x_direction < 0:
		leftFacingCollider.disabled = false
		rightFacingCollider.disabled = true
		leftFacingHurtbox.disabled = false
		rightFacingHurtBox.disabled = true


func _finishedAttack():
	_isAttacking = false


func _on_attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, _directionFacing, 100000)
