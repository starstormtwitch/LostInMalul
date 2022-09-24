extends Enemy


const bullet_scene = preload("res://src/Actors/shitman/Bullet.tscn")

const _GRAVITY = 10
const _JUMPFORCE = -160
const _JUMP_SPEED = 60

var _jumpVelocity = Vector2()
var _jumpDirection = Vector2()

onready var bulletSpawn: Position2D = $BulletSpawn

# Called when the node enters the scene tree for the first time.
func _ready():
	_minDistanceToStayFromPlayer = 30;
	_maxDistanceToStayFromPlayer = 90;
	_health = 8
	_acceleration = 0.2
	_speed = 65
	_attack_range = 30
	_animationHandler = NodeStateMachineAnimationHandler.new($AnimationTree)
	if($AnimationTree != null):
		$AnimationTree.active = true
		
#disabling attacking for now
func _physics_process(_delta: float) -> void:
	#._physics_process(_delta)
	match _state:
		EnemyState.ATTACK_IN_PLACE:
			#print("attack state")
			if !_isAttacking:
				_isAttacking = true
				if($AnimationTree != null):
					$AnimationTree.get("parameters/playback").travel("attack")


func _attack_done():
	_velocity = getMovement(Vector2.ZERO, 0, .5)
	#_velocity = move_and_slide(_velocity)
	_finishedAttack(2)


func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, _velocity.normalized(), 500)


func _on_FlockBox_area_entered(area):
	if(area.get_parent().is_in_group("enemy")):
		add_to_flock(area.get_parent())


func _on_FlockBox_area_exited(area):
	if(area.get_parent().is_in_group("enemy")):
		remove_from_flock(area.get_parent())


func summon_bullet():
	var instance = bullet_scene.instance()
	instance.set_direction(_isFacingDirectionLeft)
	instance.global_position = bulletSpawn.global_position
	get_parent().add_child(instance)


func _flipBoxesIfNecessary(velocity_x: float):
	._flipBoxesIfNecessary(velocity_x)
	if velocity_x > 0:
		bulletSpawn.position.x = abs(bulletSpawn.position.x)
	elif velocity_x < 0:
		bulletSpawn.position.x = -abs(bulletSpawn.position.x)
