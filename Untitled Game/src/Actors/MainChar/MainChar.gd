extends Actor

signal player_hit_enemy
signal player_dodge
signal super_charge_change(new_value)
signal coin_changed
signal item_pickup
signal item_delete


class_name MainChar

const trail_scene = preload("res://src/Helpers/Trail.tscn")
const smoke_scene = preload("res://src/Actors/MainChar/SmokeParticles.tscn")
const ghost_scene = preload("res://src/Helpers/Ghost.tscn")
const spawner = preload("res://src/Helpers/Spawning/Spawner.tscn")
const dropped_item = preload("res://src/InventoryItems/DroppedItemBase.tscn")
const footstep = preload("res://assets/audio/footsteps_sfx.wav")
const woosh = preload("res://assets/audio/HitAudio/miss_sfx.wav")
const deathSound = preload("res://assets/audio/main_char_death_sfx.wav")
const hurtSound = preload("res://assets/audio/mainHurt.mp3")
var hadouken_scene = preload("res://src/Actors/MainChar/HadoukenBlast.tscn")


const _JUMP_EVENT = "Jump"
const _DASH_EVENT = "dodge"
const _DODGE_SPEED = 900
const _DODGE_ACCELERATION = 1
const _LEFT_FACING_SCALE = -1.0
const _RIGHT_FACING_SCALE = 1.0
const _FOOTSTEP_PARTICLE_POSITION_OFFSET = -6
const _MAX_SUPER_CHARGES = 3
const _MIN_SUPER_CHARGES = 0
const STARTING_SUPER_CHARGES = 1
const NORMAL_HEALTH_VALUE = 15
const NORMAL_DAMAGE_VALUE = 1
const INFINITE_HEALTH_VALUE = 20000
const INFINITE_DAMAGE_VALUE = 2000

var InventoryItem : Node2D
var Coins = 0
var _beingHurt: bool = false
var _canTakeDamage: bool = false
var _isDodging = false
var _canDodge = true
var _directionFacing: Vector2 = Vector2.ZERO
var _dodgeDirection: Vector2 = Vector2.ZERO
var _trail = []
var _invincibilityTimer: Timer = Timer.new()
var _defenseUpTimer: Timer = Timer.new()
var _damageUpTimer: Timer = Timer.new()
var _attackResetTimer: Timer = Timer.new()
var _takeDamageModifier = 1.0
var _giveDamageModifier = 1.0
var _damage = NORMAL_DAMAGE_VALUE
var _hitDoneTimer: Timer = Timer.new()
var _hitAnimationTime = 1
var _currentSuperCharges = STARTING_SUPER_CHARGES
var _lastHadoukenDamagePercentage: float = 0.0
var _setting: Settings = Settings.new()

# debug settings
var isInfiniteHealth = false
var isInfiniteDamage = false

onready var _attackManager: AttackManager
onready var sprite: Sprite = $KinematicSprite/Sprite
onready var shadow: Sprite = $Shadow
onready var rightHitBox: CollisionShape2D = $attack/sideSwipeRight
onready var hadoukenSpawn: Position2D = $HadoukenSpawn
onready var ghostIntervalTimer: Timer = $GhostIntervalTimer
onready var ghostDurationTimer: Timer = $GhostDurationTImer
onready var dashDurationTimer: Timer = $DashDurationTimer
onready var dashCooldownTimer: Timer = $DashCooldownTimer
onready var animationTree: AnimationTree = $AnimationTree
onready var chargeBar: TextureProgress = $ChargeBar


func _init():
	add_to_group("Player")
	load_character_save(LevelGlobals.GetPlayerSaveData())

func load_character_save(player_data):
	if(player_data != null && !player_data.empty()):
		Coins = player_data["coins"];
		if(player_data.has("health")):
			_health = player_data["health"]
		else:
			_health = _maxHealth;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	emit_signal("coin_changed")
	_setup_timer(_invincibilityTimer, "_on_invincibility_timeout")
	_setup_timer(_defenseUpTimer, "_on_defenseUp_timeout")
	_setup_timer(_damageUpTimer, "_on_damageUp_timeout")
	_setup_timer(_attackResetTimer, "_on_combo_timeout")
	_hitAnimationTime = $AnimationPlayer.get_animation("HurtRight").length
	_setup_timer(_hitDoneTimer, "_hit_timer_done")
	rightHitBox.disabled = true
	_setting.connectNodeToDebugSettingsChangedSignal(self, "_getDebugSettings")
	_getDebugSettings()
	_animationHandler = BlendTreeAnimationHandler.new(animationTree)
	
	_invincibilityTimer.start(3)
	
	_maxHealth = NORMAL_HEALTH_VALUE
	_health = 10
	_acceleration = .1
	_speed = 145
	_directionFacing.x = .1;
	$TrailTimer.connect("timeout", self, "add_trail")
	animationTree.active = true


func _setup_timer(timer: Timer, callback_name: String):
	timer.connect("timeout", self, callback_name) 
	timer.one_shot = true
	self.add_child(timer)


func _physics_process(_delta: float) -> void:
	if !isDying:
		._physics_process(_delta)
		var direction = Vector2.ZERO
		
		_assign_player_color()
		
		if(!_attackManager.isAttacking and !_isDodging):
			direction = evaluatePlayerInput(_delta)
			_dodgeDirection = direction
			
		if _isDodging:
			_velocity = getMovement(_dodgeDirection, _DODGE_SPEED, _DODGE_ACCELERATION)
			_velocity = move_and_slide(_velocity)
		elif !_beingHurt:
			_velocity = getMovement(direction, _speed, _acceleration)
			_velocity = move_and_slide(_velocity)


func _assign_player_color():
	var charColor = Color(1,1,1,1);
	if _giveDamageModifier != 1 && _takeDamageModifier != 1:
		var purple = Color(1.0, 0.0, 1.0)
		var lightpurple = purple.lightened(0.4)
		charColor =  lightpurple
	elif _giveDamageModifier != 1:
		var red = Color(1.0, 0.0, 0.0)
		var pink = red.lightened(0.4)
		charColor =  pink
	elif _takeDamageModifier != 1:
		var green = Color(0.0, 1.0, 0.0)
		var lightgreen = green.lightened(0.4)
		charColor =  lightgreen
	self.modulate = charColor;
	if !_canTakeDamage:
		self.modulate =  Color(.5,.2,.2,.3) if Engine.get_frames_drawn() % 5 == 0 else charColor


func _check_if_cancel_dodge():
	# means we collided with something
	if is_on_ceiling() or is_on_floor() or is_on_wall():
		print("cancel dodge")
		_cancel_dash()

func _on_invincibility_timeout() -> void:
	self.modulate = Color(1,1,1,1)
	_canTakeDamage = true


func _on_damageUp_timeout() -> void:
	self.modulate = Color(1,50,0,0)
	_giveDamageModifier = 1


func _on_defenseUp_timeout() -> void:
	self.modulate = Color(1,0,0,50)
	_takeDamageModifier = 1


func _on_combo_timeout() -> void:
	_attackManager.resetCombo()


# call function when foot hits floor. Play sounds and smoke particle
func footstepCallback():
	_generate_smoke_particle()
	SoundPlayer.playSound(get_tree().get_current_scene(), footstep, -15)


#Animation callback to generate smoke particle when feet touch the ground
func _generate_smoke_particle():
	var smoke = smoke_scene.instance()
	get_parent().add_child(smoke)
	smoke.global_position = self.global_position
	smoke.global_position.y += _FOOTSTEP_PARTICLE_POSITION_OFFSET
	smoke.emitting = true
	if _directionFacing.x > 0:
		smoke.flipSide(false)
	elif _directionFacing.x < 0:
		smoke.flipSide(true)


func collectCoin():
	Coins = Coins + 1;
	emit_signal("coin_changed")
	
	
func damageUpCollected():
	_damageUpTimer.start(15)
	_giveDamageModifier = 2.0;
	
	
func defenseUpCollected():
	_defenseUpTimer.start(15)
	_takeDamageModifier = .5;


func healthCollected():
	var newHealth = _health + 1;
	if(newHealth <= _maxHealth):
		emit_signal("health_changed", _health, newHealth, _maxHealth)
		_health = newHealth;


func superChargeCollected():
	_currentSuperCharges = min(_MAX_SUPER_CHARGES, _currentSuperCharges + 1)
	emit_signal("super_charge_change", _currentSuperCharges)


func superChargeReduce():
	_currentSuperCharges = max(_MIN_SUPER_CHARGES, _currentSuperCharges - 1)
	emit_signal("super_charge_change", _currentSuperCharges)


func checkForSuperCharges():
	if _currentSuperCharges > 0 and !_attackManager.IsChargingSpecial:
		superChargeReduce()
		_attackManager.startSpecial()


func add_trail() -> void:
	if(get_parent() != null):
		var trail      = trail_scene.instance()
		trail.player   = self
		trail.position = self.position
		get_parent().add_child(trail)
		_trail.push_front(trail)

func add_item_to_inventory(item : Node2D):
	emit_signal("item_pickup", item);
	if(is_instance_valid(InventoryItem)):
		var slotItem = InventoryItem;
		var itemDropper = spawner.instance();
		itemDropper.global_position = self.global_position; 
		get_parent().add_child(itemDropper);
		var newDroppedItem = dropped_item.instance()
		newDroppedItem.init(self, slotItem)
		itemDropper.spawnInstantiatedNode(newDroppedItem, itemDropper.global_position);
	if(item != null):
		InventoryItem = item;
		
func delete_item_from_inventory():
	emit_signal("item_delete");
	if(is_instance_valid(InventoryItem)):
		InventoryItem.queue_free()
		InventoryItem = null; 
	

func take_damage(damage: int, direction: Vector2, force: float) -> void:
	if _canTakeDamage:
		#print("call hurt logic")
		_canTakeDamage = false
		SoundPlayer.playSound(get_tree().get_current_scene(), hurtSound, 0)
		_beingHurt = true
		_attackManager.gotHit()
		$attack/sideSwipeRight.set_deferred("disabled", true);
		_hitDoneTimer.start(_hitAnimationTime)
		_invincibilityTimer.start(3)
		rightHitBox.set_deferred("disabled", true)
		var finalDamage = ceil(damage * _takeDamageModifier)
		if isInfiniteHealth:
			finalDamage = 0
		.take_damage(finalDamage, direction, force)


#timer callback for when hit animation should be done. Doing this cause 
# there is some issue with animation not playing properly and not resetting this 
# flag causing the player to be stuck in animations. 
func _hit_timer_done():
	_beingHurt = false


# callback function to for when the hurt animation is playing
func setHurtAnimationPlaying():
	pass


func evaluatePlayerInput(delta) -> Vector2:
	#get direction for inputs
	var direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if(direction != Vector2.ZERO):
		_directionFacing = direction
	
	_flip_nodes(direction)
	
	if _beingHurt:
		return Vector2.ZERO
	if _check_for_events(delta):
		return Vector2.ZERO
		
	if _attackManager.IsChargingSpecial:
		animationTree.get("parameters/playback").travel("Hadouken")
		return Vector2.ZERO
		
	#set animation for direction and return for movement
	if !_attackManager.IsChargingSpecial:
		if direction == Vector2.ZERO:
			_animationHandler.idle()
		else:
			_animationHandler.walk()
	return direction


func _flip_nodes(direction: Vector2):
	if direction.x < 0:
		rightHitBox.position.x = -abs(rightHitBox.position.x)
		hadoukenSpawn.position.x = -abs(hadoukenSpawn.position.x)
		sprite.flip_h = true
		shadow.flip_h = true
	elif direction.x > 0:
		rightHitBox.position.x = abs(rightHitBox.position.x)
		hadoukenSpawn.position.x = abs(hadoukenSpawn.position.x)
		sprite.flip_h = false
		shadow.flip_h = false


func _check_for_events(delta) -> bool:
	return true # Implement in child classes. 


func _summonHadouken():
	_lastHadoukenDamagePercentage = _attackManager.getHadoukenPercentage()
	_attackManager.releaseSpecial()


func checkForEvent(event_name: String, delta) -> bool:
	if Input.is_action_just_pressed(event_name) or Input.is_action_pressed(event_name):
		return true
	return false

func _finishedAttack() -> void:
	if(_attackManager.isAttacking):
		print("attack finished")
		$attack/sideSwipeRight.set_deferred("disabled", true);
		_attackManager.isAttacking = false
		_attackManager.attackLock.unlock()


# callback function for when hurt animation is done
func _hurtAnimationFinished() -> void:
	_beingHurt = false


func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		#print("direction of hit: " + String(_directionFacing.x))
		var finalDam = ceil(_damage * _giveDamageModifier)
		if isInfiniteDamage:
			finalDam = INFINITE_DAMAGE_VALUE
		area.get_parent().take_damage(finalDam, _directionFacing, _attackManager.damageForce)
		_attackManager.didHitEnemy = true
		area.get_parent().show_hit_marker(_attackManager.isLastAttackAKick)
		_on_enemy_hit()


func _on_enemy_hit():
	_attackManager.playHitSounds(get_tree().get_current_scene())
	emit_signal("player_hit_enemy")

func playDeathRattle():
	SoundPlayer.playSound(get_tree().get_current_scene(), deathSound, -4)


func sendPlayerDeadSignal():
	#restarting game, instead of sending signal
	get_tree().reload_current_scene()


# Called in Animation Player from animation Hadouken
func summon_hadouken_blast():
	var instance = hadouken_scene.instance()
	instance.calculateDamage(_lastHadoukenDamagePercentage)
	instance.set_direction(_directionFacing)
	instance.global_position = hadoukenSpawn.global_position
	get_parent().add_child(instance)


func _start_dash():
	if _canDodge:
		_isDodging = true
		_canDodge = false
		emit_signal("player_dodge")
		ghostIntervalTimer.start()
		ghostDurationTimer.start()
		dashCooldownTimer.start()
		dashDurationTimer.start()


func _cancel_dash():
	_isDodging = false
	ghostIntervalTimer.stop()
	ghostDurationTimer.stop()
	dashDurationTimer.stop()
	_velocity = Vector2.ZERO


func getDodgeCooldownTime() -> float:
	return dashCooldownTimer.wait_time


func _on_ghostIntervalTimer_timeout():
	var this_ghost: Ghost = ghost_scene.instance()
	get_parent().add_child(this_ghost)
	this_ghost.set_paramaters_for_ghost(sprite, self.global_position)


func _on_DashDurationTimer_timeout():
	_isDodging = false


func _on_DashCooldownTimer_timeout():
	_canDodge = true


func _on_GhostDurationTImer_timeout():
	ghostIntervalTimer.stop()


func _on_ChargeIntervalTimer_timeout():
	_attackManager.increaseChargeBar()

func playShoryukenSFX():
	_attackManager.playShoryukenSound(get_tree().get_current_scene())

func _getDebugSettings():
	var gameSettings = Settings.load_game_settings()
	isInfiniteDamage = gameSettings.infiniteDamage
	isInfiniteHealth = gameSettings.infiniteHealth
