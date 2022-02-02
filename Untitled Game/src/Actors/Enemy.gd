extends Actor
class_name Enemy


#Enemy properties
var _seperation_distance = 20
var _attack_range = 20
var _initial_attack_cooldown = .5 #in seconds
var _stun_duration = 50 #in seconds
#Enemy state
var _isReadyToAttack = false
var _isAttacking = false
var _isStunned = false
enum EnemyState {IDLE, CHASE, ATTACK_IN_PLACE, ROAM}
var _state = EnemyState.CHASE
var _target = null
var _flock = []
var _attackCooldownTimer = Timer.new()
var _stunTimer = Timer.new()
var _hitFlashTimer = Timer.new()
var _directionFacing = 0

func _ready():
	_attackCooldownTimer.connect("timeout",self,"_on_attack_cooldown_timeout") 
	_attackCooldownTimer.one_shot = true
	add_child(_attackCooldownTimer)
	_attackCooldownTimer.start(_initial_attack_cooldown)
	
	_stunTimer.connect("timeout",self,"_on_stun_cooldown_timeout") 
	_stunTimer.one_shot = true
	add_child(_stunTimer)
	
	_hitFlashTimer.connect("timeout",self,"_on_hitFlash_cooldown_timeout") 
	_hitFlashTimer.one_shot = true
	add_child(_hitFlashTimer)
	
	var parent = get_parent()
	if(parent != null):
		var tree = parent.get_tree()
		var players = tree.get_nodes_in_group("Player")
		if(players.size() > 0):
			_target = players[0]

func _physics_process(_delta: float) -> void:
	var direction = Vector2.ZERO
	
	#try disable collisions if in air.
	if(_inAir):
		if(self.has_node("CollisionBox")):
			get_node("CollisionBox").disabled = true
	else:
		if(self.has_node("CollisionBox")):
			get_node("CollisionBox").disabled = false
	
	if(!_isStunned && !_inAir):
		var targetDirection = try_chase()
		get_next_state(targetDirection)
		if(!_isAttacking):
			if(_state == EnemyState.CHASE):
				direction = targetDirection;
		
			direction = _flock_direction(direction)
		if (_state == EnemyState.CHASE or _state == EnemyState.ROAM) and !_isAttacking:
			_play_walk_animation_if_available(targetDirection.x)
		_directionFacing = targetDirection.x
		_flipBoxesIfNecessary(targetDirection.x)
			
	_velocity = getMovement(direction, _speed, _acceleration)
	_velocity = move_and_slide(_velocity)


func _flipBoxesIfNecessary(velocity_x: float):
	var rightHitBox: CollisionShape2D = get_node("Attack/AttackBox")
	var sprite: Sprite = get_node("enemy")
	var shadow: Sprite = get_node("Shadow")
	if velocity_x > 0:
		rightHitBox.position.x = abs(rightHitBox.position.x)
		sprite.flip_h = true
		if shadow != null:
			shadow.flip_h = true
	elif velocity_x < 0:
		rightHitBox.position.x = -abs(rightHitBox.position.x)
		sprite.flip_h = false
		if shadow != null:
			shadow.flip_h = false


func get_next_state(targetDirection: Vector2):
	if(_target != null):
		var dist_to_target = self.global_position.distance_to(_target.global_position)
		if(dist_to_target <= _attack_range && _isReadyToAttack):
			_isReadyToAttack = false
			_state = EnemyState.ATTACK_IN_PLACE
		elif  (targetDirection != Vector2.ZERO):
			_state = EnemyState.CHASE
		else:
			_state = EnemyState.ROAM
	else:
		_state = EnemyState.IDLE
	
func add_to_flock(flockMate):
	if !_flock.has(flockMate) && flockMate != self:
		_flock.push_back(flockMate)
		
func remove_from_flock(flockMate):
	if flockMate != self:
		_flock.erase(flockMate)

func _flock_direction(direction: Vector2):
	var separation = Vector2.ZERO
	for flockmate in _flock:
		if is_instance_valid(flockmate):
			var distanceFromFlockMate = self.position.distance_to(flockmate.position)
			if distanceFromFlockMate < 1:
				distanceFromFlockMate = rand_range(-8,8)
				
			if distanceFromFlockMate < _seperation_distance:
				separation -= (flockmate.position - self.position).normalized() * (_seperation_distance / distanceFromFlockMate * _speed)
	return (direction + separation * .5)
	
func try_chase() -> Vector2:
	var direction = Vector2.ZERO
	# if we can see the target, chase it
	direction = get_target_direction()
	# or chase first trail we can see
	var look = self.get_node("Sight")
	if look.is_colliding():
		for trail in _target._trail:
			look.cast_to = (trail.position - self.position)
			look.force_raycast_update()
			
			if !look.is_colliding():
				direction = look.cast_to.normalized()
				break
	return direction

func _play_walk_animation_if_available(velocity_x: float):
	if $AnimationTree != null and $AnimationPlayer != null and velocity_x != 0:
		var animationPlayer: AnimationPlayer = $AnimationPlayer
		if animationPlayer.has_animation("walk"):
			$AnimationTree.get("parameters/playback").travel("walk")

func show_hit_marker(isKick: bool):
	if ($PunchHitMarkerParticles != null or $KickHitMarkerParticles != null) and _health > 0:
		var hitMarkerParticles: Particles2D = $PunchHitMarkerParticles
		if isKick:
			hitMarkerParticles = $KickHitMarkerParticles
		if _directionFacing > 0:
			hitMarkerParticles.position.x = abs(hitMarkerParticles.position.x)
		elif _directionFacing < 0:
			hitMarkerParticles.position.x = -abs(hitMarkerParticles.position.x)
		hitMarkerParticles.restart()
		hitMarkerParticles.emitting = true


func get_target_direction() -> Vector2:
	var direction = Vector2.ZERO
	if(_target == null):
		return direction
		
	var look = self.get_node("Sight")
	look.cast_to = (_target.position - self.position)
	look.force_raycast_update()

	if !look.is_colliding():
		direction = look.cast_to.normalized()
		
	return direction
	

func take_damage(damage: int, direction: Vector2, force: float) -> void:
	if !isDying:
		#stun enemy
		_velocity = getMovement(Vector2.ZERO, 0, .5)
		#_velocity = move_and_slide(_velocity)
		#print("hit, reset attack")
		disable_hurt_box_if_exists()
		_finishedAttack(1)
		_isStunned = true
		_stunTimer.start(_stun_duration)
		
		#mark damage
		emit_signal("enemy_hit")
		self.modulate =  Color(10,10,10,10) 
		_hitFlashTimer.start(.2)
		if($AnimationTree != null):
			$AnimationTree.get("parameters/playback").travel("hurt")
		_health-=damage
		
		#knockback/knockup
		_inAir = true
		direction.y -= 4
		var knockbackVelocity = getMovement(direction, force, _acceleration)
		_velocity = move_and_slide(knockbackVelocity)
		
		#death check
		if(_health <= 0):
			die()

func disable_hurt_box_if_exists():
	var hitbox: CollisionShape2D = get_node("Attack/AttackBox")
	if(hitbox != null):
		#print("disable hit box")
		hitbox.disabled = true
	
func _on_attack_cooldown_timeout():
	_isReadyToAttack = true
		
func _on_stun_cooldown_timeout():
	_isStunned = false
	
func _on_hitFlash_cooldown_timeout():
	_isStunned = false
	self.modulate =  Color(1,1,1,1) 
		
func _finishedAttack(cooldown: int):
	_attackCooldownTimer.start(cooldown)
	_isAttacking = false
