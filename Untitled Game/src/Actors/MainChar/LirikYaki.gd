extends Actor

signal player_hit_enemy

const trail_scene = preload("res://src/Helpers/Trail.tscn")
const smoke_scene = preload("res://src/Actors/MainChar/SmokeParticles.tscn")
const hadouken_scene = preload("res://src/Actors/MainChar/HadoukenBlast.tscn")
const ghost_scene = preload("res://src/Helpers/Ghost.tscn")

const _JUMP_EVENT = "Jump"
const _ATTACK1_EVENT = "side_swipe_attack"
const _ATTACK2_EVENT = "attack_2"
const _DASH_EVENT = "Dodge"
const _DODGE_SPEED = 400
const _DODGE_ACCELERATION = 1
const COMBOTIME = 1
const _LEFT_FACING_SCALE = -1.0
const _RIGHT_FACING_SCALE = 1.0
const _FOOTSTEP_PARTICLE_POSITION_OFFSET = -6
const _START_A_COMBO = 3
const _START_B_COMBO = 3

var _isAttacking: bool = false
var _didHitEnemy: bool = false #To check to see if we should play woosh sfx if we missed
var _beingHurt: bool = false
var _canTakeDamage: bool = false
var _isLastAttackAKick = false #Used to check which hitmarker to show
var _isDodging = false
var _canDodge = true
var _directionFacing: Vector2 = Vector2.ZERO
var _dodgeDirection: Vector2 = Vector2.ZERO
var _trail = []
var _invincibilityTimer: Timer = Timer.new()

var _comboAPoints = _START_A_COMBO;
var _comboBPoints = _START_B_COMBO;

var _attackResetTimer: Timer = Timer.new()
var _hitDoneTimer: Timer = Timer.new()
var _hitAnimationTime = 1

onready var sprite: Sprite = $Sprite
onready var shadow: Sprite = $Shadow
onready var rightHitBox: CollisionShape2D = $attack/sideSwipeRight
onready var hitAudioPlayer: HitAudioPlayer = $HitAudioPlayer
onready var wooshAudioPlayer: AudioStreamPlayer = $WooshAudioPlayer
onready var footstepAudioPlayer: AudioStreamPlayer = $FootStepAudioStreamPlayer
onready var hadoukenSpawn: Position2D = $HadoukenSpawn
onready var ghostIntervalTimer: Timer = $GhostIntervalTimer
onready var ghostDurationTimer: Timer = $GhostDurationTImer
onready var dashDurationTimer: Timer = $DashDurationTimer
onready var dashCooldownTimer: Timer = $DashCooldownTimer

func _init():
	add_to_group("Player")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_invincibilityTimer.connect("timeout", self, "_on_invincibility_timeout") 
	_invincibilityTimer.one_shot = true
	add_child(_invincibilityTimer)
	
	_attackResetTimer.connect("timeout", self, "_on_combo_timeout") 
	_attackResetTimer.one_shot = true
	add_child(_attackResetTimer)
	
	_hitAnimationTime = $AnimationPlayer.get_animation("HurtRight").length
	_hitDoneTimer.one_shot = true
	_hitDoneTimer.connect("timeout", self, "_hit_timer_done") 
	add_child(_hitDoneTimer)
	
	_invincibilityTimer.start(3)
	
	_maxHealth = 10
	_health = _maxHealth
	_acceleration = .1
	_speed = 150
	_directionFacing.x = .1;
	$TrailTimer.connect("timeout", self, "add_trail")
	$AnimationTree.active = true


func _physics_process(_delta: float) -> void:
	var direction = Vector2.ZERO
	
	if !_canTakeDamage:
		#self.modulate =  Color(2,2,2,2) if Engine.get_frames_drawn() % 5 == 0 else Color(1,1,1,1)
		#self.modulate =  Color(1.3,1.3,1.3,1.3) if Engine.get_frames_drawn() % 5 == 0 else Color(1,1,1,1)
		self.modulate =  Color(1.5,1.2,1.2,1.3) if Engine.get_frames_drawn() % 5 == 0 else Color(1,1,1,1)
	
	if(!_isAttacking and !_isDodging):
		direction = evaluatePlayerInput()
		_dodgeDirection = direction
		
	if _isDodging:
		_velocity = getMovement(_dodgeDirection, _DODGE_SPEED, _DODGE_ACCELERATION)
		_velocity = move_and_slide(_velocity)
	elif !_beingHurt:
		_velocity = getMovement(direction, _speed, _acceleration)
		_velocity = move_and_slide(_velocity)


func _on_invincibility_timeout() -> void:
	self.modulate = Color(1,1,1,1)
	_canTakeDamage = true
	
	
func _on_combo_timeout() -> void:
	#print("combo reset")
	_comboAPoints = _START_A_COMBO
	_comboBPoints = _START_B_COMBO


# call function when foot hits floor. Play sounds and smoke particle
func footstepCallback():
	_generate_smoke_particle()
	_play_footstep_sound()


#Animation callback to generate smoke particle when feet touch the ground
func _generate_smoke_particle():
	var smoke = smoke_scene.instance()
	smoke.global_position = self.global_position
	smoke.global_position.y += _FOOTSTEP_PARTICLE_POSITION_OFFSET
	smoke.emitting = true
	if _directionFacing.x > 0:
		smoke.flipSide(false)
	elif _directionFacing.x < 0:
		smoke.flipSide(true)
	get_parent().add_child(smoke)


func _play_footstep_sound():
	footstepAudioPlayer.play()


#timer callback for when hit animation should be done. Doing this cause 
# there is some issue with animation not playing properly and not resetting this 
# flag causing the player to be stuck in animations. 
func _hit_timer_done():
	#print("hurt timer done")
	_beingHurt = false

func add_trail() -> void:
	if(get_parent() != null):
		var trail      = trail_scene.instance()
		trail.player   = self
		trail.position = self.position
		get_parent().add_child(trail)
		_trail.push_front(trail)


func take_damage(damage: int, direction: Vector2, force: float) -> void:
	if _canTakeDamage:
		print("call hurt logic")
		_canTakeDamage = false
		_beingHurt = true
		_isAttacking = false
		_on_combo_timeout()
		_hitDoneTimer.start(_hitAnimationTime)
		$AnimationTree.get("parameters/playback").travel("Hurt")
		_invincibilityTimer.start(2)
		.take_damage(damage, direction, force)

# callback function to for when the hurt animation is playing
func setHurtAnimationPlaying():
	pass
	#print("play hurt animation")
	#_beingHurt = true

func evaluatePlayerInput() -> Vector2:
	#get direction for inputs
	var direction = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	if(direction != Vector2.ZERO):
		_directionFacing = direction
	
	if direction.x < 0:
		rightHitBox.position.x = -abs(rightHitBox.position.x)
		sprite.flip_h = true
		shadow.flip_h = true
	elif direction.x > 0:
		rightHitBox.position.x = abs(rightHitBox.position.x)
		sprite.flip_h = false
		shadow.flip_h = false
	
	if _beingHurt:
		return Vector2.ZERO
	if _check_for_events():
		return Vector2.ZERO
		
	#set animation for direction and return for movement
	if direction == Vector2.ZERO:
		$AnimationTree.get("parameters/playback").travel("Idle")
	else:
		$AnimationTree.get("parameters/playback").travel("Walk")
	return direction

func _check_for_events() -> bool:
	if Input.is_action_just_pressed(_ATTACK1_EVENT) or Input.is_action_pressed(_ATTACK1_EVENT):
		doSideSwipeAttack()
		return true
	elif Input.is_action_just_pressed(_ATTACK2_EVENT) or Input.is_action_pressed(_ATTACK2_EVENT):
		doSideSwipeKick()
		return true
	elif Input.is_action_just_pressed(_DASH_EVENT) or Input.is_action_pressed(_DASH_EVENT):
		start_dash()
		return false
	else:
		return false

func _attack_setup(is_kick: bool):
	_isAttacking = true
	_didHitEnemy = false
	_isLastAttackAKick = is_kick
	_attackResetTimer.start(COMBOTIME)

func doSideSwipeAttack():
	if !_isAttacking:
		_attack_setup(false)
		print("Combo A: " + String(_comboAPoints))
		if _comboAPoints == 1 or _comboBPoints == 1:
			hitAudioPlayer.playerAttacks()
			$AnimationTree.get("parameters/playback").travel("Hadouken")
			_on_combo_timeout()
		elif _comboAPoints == 3:
			hitAudioPlayer.playerAttacks()
			$AnimationTree.get("parameters/playback").travel("SideSwipe1")
			_comboAPoints = _comboAPoints - 1
			_comboBPoints = 3
		elif _comboAPoints == 2:
			hitAudioPlayer.playerAttacks()
			$AnimationTree.get("parameters/playback").travel("SideSwipe2")
			_comboAPoints = _comboAPoints - 1
			_comboBPoints = 3


func doSideSwipeKick():
	if !_isAttacking:
		_attack_setup(true)
		print("Combo B: " + String(_comboBPoints))
		if _comboBPoints == 1 or _comboAPoints == 1:
			hitAudioPlayer.playerAttacks()
			$AnimationTree.get("parameters/playback").travel("Shoryuken")
			_on_combo_timeout()
		elif _comboBPoints == 3:
			hitAudioPlayer.playerAttacks()
			$AnimationTree.get("parameters/playback").travel("SideSwipeKick")
			_comboBPoints = _comboBPoints - 1
			_comboAPoints = 3
		elif _comboBPoints == 2:
			hitAudioPlayer.playerAttacks()
			$AnimationTree.get("parameters/playback").travel("SideSwipeRightKick2")
			_comboBPoints = _comboBPoints - 1
			_comboAPoints = 3


func _finishedAttack() -> void:
	print("attack finished")
	_isAttacking = false


func checkIfWePlayWooshSFX():
	if !_didHitEnemy:
		wooshAudioPlayer.play()


# callback function for when hurt animation is done
func _hurtAnimationFinished() -> void:
	#print("hurt animation done")
	_beingHurt = false


func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, _directionFacing, 50000)
		_didHitEnemy = true
		area.get_parent().show_hit_marker(_isLastAttackAKick)


func sendPlayerDeadSignal():
	#restarting game, instead of sending signal
	get_tree().reload_current_scene()


func _on_enemy_hit():
	hitAudioPlayer.playHitSound()
	#print("emit shake signal")
	emit_signal("player_hit_enemy")


func summon_hadouken_blast():
	var instance = hadouken_scene.instance()
	instance.set_direction(_directionFacing)
	instance.global_position = hadoukenSpawn.global_position
	get_parent().add_child(instance)


func start_dash():
	if _canDodge:
		_isDodging = true
		_canDodge = false
		ghostIntervalTimer.start()
		ghostDurationTimer.start()
		dashCooldownTimer.start()
		dashDurationTimer.start()


func _on_ghostIntervalTimer_timeout():
	var this_ghost: Ghost = ghost_scene.instance()
	get_parent().add_child(this_ghost)
	this_ghost.set_paramaters_for_ghost(sprite, sprite.global_position)


func _on_DashDurationTimer_timeout():
	_isDodging = false


func _on_DashCooldownTimer_timeout():
	_canDodge = true


func _on_GhostDurationTImer_timeout():
	ghostIntervalTimer.stop()
