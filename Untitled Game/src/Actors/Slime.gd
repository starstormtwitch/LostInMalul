extends Enemy

const _GRAVITY = 10
const _JUMPFORCE = -160
const _JUMP_SPEED = 60

const attackSound = preload("res://assets/audio/frWhoosh.mp3")

var _jumpVelocity = Vector2()
var _jumpDirection = Vector2()
var _isJumping = false

onready var attackBox = $Attack/AttackBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_health = 3
	_acceleration = 0.2
	_speed = 50
	_attack_range = 200
	attackBox.disabled = true
	_animationHandler = NodeStateMachineAnimationHandler.new($AnimationTree)
	if($AnimationTree != null):
		$AnimationTree.active = true
		
#disabling attacking for now
func _physics_process(_delta: float) -> void:
	match _state:
		EnemyState.ATTACK_IN_PLACE:
			#print("attack state")
			if !_isAttacking:
				_isAttacking = true
				SoundPlayer.playSound(get_tree().get_current_scene(), attackSound, -15)
				if($AnimationTree != null):
					$AnimationTree.get("parameters/playback").travel("jump_attack")
	if _isJumping:
		_handleJumpPhysics()
	
func _handleJumpPhysics():
	_velocity = move_and_slide(_jumpVelocity)

func _on_jump_attack():
	_isJumping = true
	var targetDirection = try_chase()
	_jumpVelocity.x = targetDirection.x * _JUMP_SPEED
	_velocity = move_and_slide(_jumpVelocity)
	
func _end_jump_attack():
	_isJumping = false
	_velocity = getMovement(Vector2.ZERO, 0, .5)
	_finishedAttack(2)

#func _on_FlockBox_body_entered(body):
#	if(body.is_in_group("enemy")):
#		add_to_flock(body)
#
#func _on_FlockBox_body_exited(body):
#	if(body.is_in_group("enemy")):
#		remove_from_flock(body)

func take_damage(damage: int, direction: Vector2, force: float) -> void:
	_isJumping = false
	.take_damage(damage, direction, force)

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, _velocity.normalized(), 500)


func _on_FlockBox_area_entered(area):
	if(area.get_parent().is_in_group("enemy")):
		add_to_flock(area.get_parent())


func _on_FlockBox_area_exited(area):
	if(area.get_parent().is_in_group("enemy")):
		remove_from_flock(area.get_parent())
