extends Actor
class_name Enemy

var _explosion_scene = preload("res://src/Effects/Explosion.tscn")

#Enemy properties
var _seperation_distance = 20
var _attack_range = 20
var _initial_attack_cooldown = .5 #in seconds
var _stun_duration = 50 #in seconds
var _canTakeKnockup = true;
var _canBeStunned = true;
var _flocks = true;
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
var _minDistanceToStayFromPlayer = 0;
var _maxDistanceToStayFromPlayer = 0;

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
	._physics_process(_delta)
	var direction = Vector2.ZERO
		
	if(!_isStunned && !_inAir && !isDying):
		var targetDirection = try_chase()
		get_next_state(targetDirection)
		if(!_isAttacking):
			if(_state == EnemyState.CHASE):
				direction = targetDirection;
		if (_state == EnemyState.CHASE):
			_play_walk_animation_if_available(targetDirection.x)
		if(_state == EnemyState.ROAM or _state == EnemyState.IDLE):
			_play_idle_animation_if_available(targetDirection.x)
		_directionFacing = targetDirection.x
		_flipBoxesIfNecessary(targetDirection.x)
		
		if(_flocks):
			direction = _flock_direction(direction)
		_velocity = getMovement(direction, _speed, _acceleration)
		_velocity = move_and_slide(_velocity)
	elif(_inAir):
		_velocity += _gravity
		moveParent(_velocity)
		moveKinematicSprite(_velocity)

func _flipBoxesIfNecessary(velocity_x: float):
	var rightHitBox: CollisionShape2D = get_node("Attack/AttackBox")
	var sprite: Sprite = get_node("KinematicSprite/Sprite")
	
	var shadow: Sprite = get_node_or_null("Shadow")
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
	if(_isAttacking):
		return;
	if(_target != null):
		var dist_to_target = self.global_position.distance_to(_target.global_position)
		if(dist_to_target <= _attack_range && _isReadyToAttack):
			_isReadyToAttack = false
			_state = EnemyState.ATTACK_IN_PLACE
		elif  (targetDirection != Vector2.ZERO && targetDirection != Vector2.ZERO  && dist_to_target >= _maxDistanceToStayFromPlayer):
			_state = EnemyState.CHASE
		elif  (_state == EnemyState.CHASE && targetDirection != Vector2.ZERO && dist_to_target >= _minDistanceToStayFromPlayer):
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
	return (direction + (separation.normalized() * .5))
	
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
	if  get_node_or_null("AnimationTree") != null and $AnimationPlayer != null and velocity_x != 0:
		var animationPlayer: AnimationPlayer = $AnimationPlayer
		if animationPlayer.has_animation("walk"):
			$AnimationTree.get("parameters/playback").travel("walk")


func _play_idle_animation_if_available(velocity_x: float):
	if get_node_or_null("AnimationTree") != null and $AnimationPlayer != null:
		var animationPlayer: AnimationPlayer = $AnimationPlayer
		if animationPlayer.has_animation("idle"):
			$AnimationTree.get("parameters/playback").travel("idle")


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
	
func stun(duration: float):
	_isStunned = true
	_stunTimer.start(duration)
	

func take_damage(damage: int, direction: Vector2, force: float) -> void:
	if !isDying:
		#stun enemy
		_velocity = getMovement(Vector2.ZERO, 0, .5)
		disable_hurt_box_if_exists()
		
		if(_canBeStunned):
			_isStunned = true
			_stunTimer.start(_stun_duration)
			if($AnimationTree != null):
				_finishedAttack(.5)
				$AnimationTree.get("parameters/playback").travel("hurt")
		
		#mark damage
		self.modulate =  Color(10,10,10,10) 
		_hitFlashTimer.start(.2)
		var newHealth = _health - damage;
		emit_signal("health_changed", _health, newHealth, _maxHealth)
		_health = newHealth
		
		#knockback/knockup
		if(_canTakeKnockup):
			_inAir = true
			direction.y -= 6
			var knockbackVelocity = getMovement(direction, force, .5)
			var y = moveKinematicSprite(knockbackVelocity)
			var x = moveParent(knockbackVelocity)
			_velocity = Vector2(x.x, y.y)
		else:
			direction = Vector2.ZERO;
			
		#death check
		if(_health <= 0):
			die()

func disable_hurt_box_if_exists():
	var hitbox: CollisionShape2D = get_node("Attack/AttackBox")
	if(hitbox != null):
		#print("disable hit box")
		hitbox.set_deferred("disabled", true);
	
func _on_attack_cooldown_timeout():
	_isReadyToAttack = true
		
func _on_stun_cooldown_timeout():
	_isStunned = false
	
func _on_hitFlash_cooldown_timeout():
	_isStunned = false
	self.modulate =  Color(1,1,1,1) 
		
func _finishedAttack(cooldown: int):
	_state = EnemyState.ROAM
	_isAttacking = false
	_isReadyToAttack = false
	_attackCooldownTimer.start(cooldown)

func showExplosion():
	if $explosionPosition != null:
		var explosionPosition: Position2D = $explosionPosition
		var instance = _explosion_scene.instance()
		instance.global_position = explosionPosition.global_position
		get_parent().add_child(instance)
		instance.z_index = 1
