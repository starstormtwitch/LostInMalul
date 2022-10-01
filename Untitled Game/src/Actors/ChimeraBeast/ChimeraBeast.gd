extends Enemy

const _GRAVITY = 10
const _JUMPFORCE = -160
var _isJumping = false
var _canDoJumpAttack = true;
const _JUMP_SPEED = 200

const slamSound = preload("res://assets/audio/ChimeraSlam.mp3")
const jumpSound = preload("res://assets/audio/ChimeraRev.mp3")

var _jumpVelocity = Vector2()
var _jumpDirection = Vector2()
var _jumpCooldownTimer = Timer.new()

onready var attackBox = $Attack/AttackBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_canTakeKnockup = false;
	_canBeStunned = false;
	_flocks = false;
	_maxHealth = 60
	_health = _maxHealth
	_acceleration = 0.2
	_speed = 65
	_attack_range = 300
	_minDistanceToStayFromPlayer = 50;
	_maxDistanceToStayFromPlayer = 50;
	attackBox.disabled = true
	_animationHandler = NodeStateMachineAnimationHandler.new($AnimationTree)
	if($AnimationTree != null):
		$AnimationTree.active = true
	$AnimationTree.get("parameters/playback").travel("spawn")
	
	_jumpCooldownTimer.connect("timeout",self,"_on_jump_cooldown_timeout") 
	_jumpCooldownTimer.one_shot = true
	add_child(_jumpCooldownTimer)
	
		
#disabling attacking for now
func _physics_process(_delta: float) -> void:
	match _state:
		EnemyState.ATTACK_IN_PLACE:
			#print("attack state")
			if !_isAttacking:
				_isAttacking = true
				var dist_to_target = self.global_position.distance_to(_target.global_position)
				if($AnimationTree != null):
					if(_canDoJumpAttack):
						_canDoJumpAttack = false;
						_jumpCooldownTimer.start(10)
						$AnimationTree.get("parameters/playback").travel("jump_attack")
						SoundPlayer.playSound(get_tree().get_current_scene(), jumpSound, 5)
					else: #only do slam attack
						$AnimationTree.get("parameters/playback").travel("slam")
						SoundPlayer.playSound(get_tree().get_current_scene(), slamSound, 5)
	if _isJumping:
		_handleJumpPhysics()
	
func _handleJumpPhysics():
	_velocity = move_and_slide(_jumpVelocity)

func _on_jump_attack():
	_isJumping = true
	var targetDirection = try_chase()
	_jumpVelocity = targetDirection * _JUMP_SPEED
	_velocity = move_and_slide(_jumpVelocity)
	
func _end_jump_attack():
	_isJumping = false
	_velocity = getMovement(Vector2.ZERO, 0, .5)
	_finishedAttack(8)

func _attack_done():
	_velocity = getMovement(Vector2.ZERO, 0, .5)
	_finishedAttack(5)

func _on_jump_cooldown_timeout():
	_canDoJumpAttack = true;

func _on_FlockBox_body_entered(body):
	if(body.is_in_group("enemy")):
		add_to_flock(body)

func _on_FlockBox_body_exited(body):
	if(body.is_in_group("enemy")):
		remove_from_flock(body)

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, _velocity.normalized(), 500)


func _on_FlockBox_area_entered(area):
	if(area.get_parent().is_in_group("enemy")):
		add_to_flock(area.get_parent())


func _on_FlockBox_area_exited(area):
	if(area.get_parent().is_in_group("enemy")):
		remove_from_flock(area.get_parent())
