extends Actor
class_name Enemy

#Enemy properties
var _seperation_distance = 50
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
		var root = tree.get_root()
		_target = root.find_node("Player", true, false)

func _physics_process(_delta: float) -> void:
	var direction = Vector2.ZERO
	
	#try disable collisions if in air.
	if(_inAir):
		if(self.has_node("CollisionBox")):
			get_node("CollisionBox").disabled = true
	
	if(!_isStunned && !_inAir):
		if(self.has_node("CollisionBox")):
			get_node("CollisionBox").disabled = true
		var targetDirection = try_chase()
		get_next_state(targetDirection)
	
		if(!_isAttacking):
			if(_state == EnemyState.CHASE):
				direction = targetDirection;
		
			direction = _flock_direction(direction)
			
		
	_velocity = getMovement(direction, _speed, _acceleration)
	_velocity = move_and_slide(_velocity)
		
	
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
			if distanceFromFlockMate == 0:
				distanceFromFlockMate = 1
				
			var randDirection = flockmate.position
			randDirection.y += rand_range(-300,300)
			if distanceFromFlockMate < _seperation_distance:
				separation -= (randDirection - self.position).normalized() * (_seperation_distance / distanceFromFlockMate * ((_velocity.x + _velocity.y) / 2))
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
	#stun enemy
	_isStunned = true
	_stunTimer.start(_stun_duration)
		
	#mark damage
	self.modulate =  Color(10,10,10,10) 
	_hitFlashTimer.start(.2)
	if($AnimationTree != null):
		$AnimationTree.get("parameters/playback").travel("hurt")
	_health-=damage
	
	#knockback/knockup
	_inAir = true
	direction.y -= 2
	var knockbackVelocity = getMovement(direction, force, _acceleration)
	_velocity = move_and_slide(knockbackVelocity)
	
	#death check
	if(_health <= 0):
		die()
		
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

