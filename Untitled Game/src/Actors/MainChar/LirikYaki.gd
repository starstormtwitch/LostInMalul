extends Actor

signal player_hit_enemy
signal player_dodge


class_name LirikYaki

const attack_sound = preload("res://assets/audio/HitAudio/Retro Impact Punch Hurt 01.wav")
const hit_sound = preload("res://assets/audio/HitAudio/Quick Hit Swoosh.wav")
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
const _LEFT_FACING_SCALE = -1.0
const _RIGHT_FACING_SCALE = 1.0
const _FOOTSTEP_PARTICLE_POSITION_OFFSET = -6

var _didHitEnemy: bool = false #To check to see if we should play woosh sfx if we missed
var _beingHurt: bool = false
var _canTakeDamage: bool = false
var _isDodging = false
var _canDodge = true
var _directionFacing: Vector2 = Vector2.ZERO
var _dodgeDirection: Vector2 = Vector2.ZERO
var _trail = []
var _invincibilityTimer: Timer = Timer.new()

var attackResetTimer: Timer = Timer.new()
var _hitDoneTimer: Timer = Timer.new()
var _hitAnimationTime = 1

onready var _attackManager: AttackManager
onready var sprite: Sprite = $Sprite
onready var shadow: Sprite = $Shadow
onready var rightHitBox: CollisionShape2D = $attack/sideSwipeRight
onready var punchAudioPlayer: HitAudioPlayer = $PunchAudioPlayer
onready var kickAudioPlayer: HitAudioPlayer = $KickAudioPlayer
onready var wooshAudioPlayer: AudioStreamPlayer = $WooshAudioPlayer
onready var footstepAudioPlayer: AudioStreamPlayer = $FootStepAudioStreamPlayer
onready var shoryukenAudioPlayer: AudioStreamPlayer = $ShoryukenStreamPlayer
onready var hadoukenSpawn: Position2D = $HadoukenSpawn
onready var ghostIntervalTimer: Timer = $GhostIntervalTimer
onready var ghostDurationTimer: Timer = $GhostDurationTImer
onready var dashDurationTimer: Timer = $DashDurationTimer
onready var dashCooldownTimer: Timer = $DashCooldownTimer
onready var animationTree: AnimationTree = $AnimationTree


func _init():
	add_to_group("Player")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_invincibilityTimer.connect("timeout", self, "_on_invincibility_timeout") 
	_invincibilityTimer.one_shot = true
	add_child(_invincibilityTimer)
	
	attackResetTimer.connect("timeout", self, "_on_combo_timeout") 
	attackResetTimer.one_shot = true
	add_child(attackResetTimer)
	
	_hitAnimationTime = $AnimationPlayer.get_animation("HurtRight").length
	_hitDoneTimer.one_shot = true
	_hitDoneTimer.connect("timeout", self, "_hit_timer_done") 
	add_child(_hitDoneTimer)
	
	_invincibilityTimer.start(3)
	
	_attackManager = AttackManager.new(attackResetTimer, punchAudioPlayer,
		kickAudioPlayer, shoryukenAudioPlayer, animationTree)
	
	_maxHealth = 10
	_health = _maxHealth
	_acceleration = .1
	_speed = 150
	_directionFacing.x = .1;
	$TrailTimer.connect("timeout", self, "add_trail")
	animationTree.active = true


func _physics_process(_delta: float) -> void:
	var direction = Vector2.ZERO
	
	if !_canTakeDamage:
		self.modulate =  Color(1.5,1.2,1.2,1.3) if Engine.get_frames_drawn() % 5 == 0 else Color(1,1,1,1)
	
	if(!_attackManager.isAttacking and !_isDodging):
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
	_attackManager.resetCombo()


# call function when foot hits floor. Play sounds and smoke particle
func footstepCallback():
	_generate_smoke_particle()
	_play_footstep_sound()


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


func _play_footstep_sound():
	footstepAudioPlayer.play()


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
		_attackManager.isAttacking = false
		_attackManager.resetCombo()
		_hitDoneTimer.start(_hitAnimationTime)
		animationTree.get("parameters/playback").travel("Hurt")
		_invincibilityTimer.start(2)
		.take_damage(damage, direction, force)


#timer callback for when hit animation should be done. Doing this cause 
# there is some issue with animation not playing properly and not resetting this 
# flag causing the player to be stuck in animations. 
func _hit_timer_done():
	_beingHurt = false


# callback function to for when the hurt animation is playing
func setHurtAnimationPlaying():
	pass


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
		animationTree.get("parameters/playback").travel("Idle")
	else:
		animationTree.get("parameters/playback").travel("Walk")
	return direction


func _check_for_events() -> bool:
	if Input.is_action_just_pressed(_ATTACK1_EVENT) or Input.is_action_pressed(_ATTACK1_EVENT):
		_attackManager.doSideSwipeAttack()
		return true
	elif Input.is_action_just_pressed(_ATTACK2_EVENT) or Input.is_action_pressed(_ATTACK2_EVENT):
		_attackManager.doSideSwipeKick()
		return true
	elif Input.is_action_just_pressed(_DASH_EVENT) or Input.is_action_pressed(_DASH_EVENT):
		_start_dash()
		return false
	else:
		return false


func _finishedAttack() -> void:
	print("attack finished")
	_attackManager.isAttacking = false


func checkIfWePlayWooshSFX():
	if !_didHitEnemy:
		wooshAudioPlayer.play()


# callback function for when hurt animation is done
func _hurtAnimationFinished() -> void:
	_beingHurt = false


func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, _directionFacing, 50000)
		_didHitEnemy = true
		area.get_parent().show_hit_marker(_attackManager.isLastAttackAKick)
		_on_enemy_hit()


func _on_enemy_hit():
	_attackManager.playHitSounds()
	emit_signal("player_hit_enemy")


func sendPlayerDeadSignal():
	#restarting game, instead of sending signal
	get_tree().reload_current_scene()


# Called in Animation Player from animation Hadouken
func summon_hadouken_blast():
	var instance = hadouken_scene.instance()
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


func getDodgeCooldownTime() -> float:
	return dashCooldownTimer.wait_time


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
