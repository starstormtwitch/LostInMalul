extends Enemy

const _GRAVITY = 10
const _JUMPFORCE = -160
const _JUMP_SPEED = 60

var _jumpVelocity = Vector2()
var _jumpDirection = Vector2()
var _isJumping = false

# Called when the node enters the scene tree for the first time.
func _ready():
	_health = 10
	_acceleration = 0.2
	_speed = 50
	_attack_range = 200
	if($AnimationTree != null):
		$AnimationTree.active = true
		
#disabling attacking for now
func _physics_process(_delta: float) -> void:
	match _state:
		EnemyState.ATTACK_IN_PLACE:
			#print("attack state")
			if !_isAttacking:
				_isAttacking = true
				if($AnimationTree != null):
					$AnimationTree.get("parameters/playback").travel("jump_attack")
	if _isJumping:
		_handleJumpPhysics()


func _handleJumpPhysics():
	#_jumpVelocity.y += _GRAVITY
	_velocity = move_and_slide(_jumpVelocity)

func _on_jump_attack():
	_isJumping = true
	#_jumpVelocity.y = _JUMPFORCE
	var targetDirection = get_target_direction()
	_jumpVelocity.x = targetDirection.x * _JUMP_SPEED
	_velocity = move_and_slide(_jumpVelocity)
	#_velocity = getMovement(targetDirection, 800, .5)
	#_velocity = move_and_slide(_velocity)
	
func _end_jump_attack():
	_isJumping = false
	_velocity = getMovement(Vector2.ZERO, 0, .5)
	#_velocity = move_and_slide(_velocity)
	_finishedAttack(2)

#func _on_FlockBox_body_entered(body):
#	if(body.is_in_group("enemy")):
#		add_to_flock(body)
#
#func _on_FlockBox_body_exited(body):
#	if(body.is_in_group("enemy")):
#		remove_from_flock(body)

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, _velocity.normalized(), 500)


func _on_FlockBox_area_entered(area):
	if(area.get_parent().is_in_group("enemy")):
		add_to_flock(area.get_parent())


func _on_FlockBox_area_exited(area):
	if(area.get_parent().is_in_group("enemy")):
		remove_from_flock(area.get_parent())
