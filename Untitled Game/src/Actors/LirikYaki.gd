extends Actor

var _isAttacking = false
var _canTakeDamage = false
var _directionFacing = Vector2.ZERO
var _invincibilityTimer = Timer.new()

onready var sprite = $Sprite

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


func _on_attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, _directionFacing, 100000)
		$AnimationTree.get("parameters/playback").travel("Hurt")


func take_damage(damage: int, direction: Vector2, force: float) -> void:
	if _canTakeDamage:
		_canTakeDamage = false
		_invincibilityTimer.start(2)
		.take_damage(damage, direction, force)


func evaluatePlayerInput() -> Vector2:
	#get direction for inputs
	var direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if(direction != Vector2.ZERO):
		_directionFacing = direction
		
	_flipSpriteIfNeeded(direction.x)
	
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


#Flip sprite according to what input pressed, if 0 nothing is pressed and we leave as is
func _flipSpriteIfNeeded(x_direction):
	if x_direction > 0:
		sprite.scale.x = 1
	elif x_direction < 0:
		sprite.scale.x = -1


func _finishedAttack():
	_isAttacking = false
