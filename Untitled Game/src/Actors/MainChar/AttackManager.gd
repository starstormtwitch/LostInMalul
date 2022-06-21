extends Node

class_name AttackManager

const kickSound = preload("res://assets/audio/HitAudio/kick_sfx.wav")
const punchSound = preload("res://assets/audio/HitAudio/punch_sfx.wav")
const missSound = preload("res://assets/audio/HitAudio/miss_sfx.wav")
const shoryukenSound = preload("res://assets/audio/HitAudio/shoryken_sfx.wav")
const hadouken = preload("res://assets/audio/HitAudio/explosion_sound.wav")

const _START_A_COMBO = 3
const _START_B_COMBO = 3
const COMBOTIME = 1
const MAX_DAMAGE_FORCE = 4000
const MIN_DAMAGE_FORCE = 700
const ATTACK1_EVENT = "side_swipe_attack"
const ATTACK2_EVENT = "attack_2"
const SPECIAL_ATTACK_EVENT = "special_attack"
const _DEFAULT_ATTACK_VOLUME = -4
const _DEFAULT_WOOSH_VOLUME = 4

var isAttacking: bool = false
var didHitEnemy: bool = false #To check to see if we should play woosh sfx if we missed
var _beingHurt: bool = false
var isLastAttackAKick = false #Used to check which hitmarker to show
var _directionFacing: Vector2 = Vector2.ZERO
var damageForce = 0
export var IsChargingSpecial = false

#flags to check if we should play certain sounds when attacks land
var _playPunchSFX = false
var _playKickSFX = false
var _playHadoukenSFX = false
var _playShoryukenSFX = false


var _comboAPoints = _START_A_COMBO;
var _comboBPoints = _START_B_COMBO;

# Injected from player
var _attackResetTimer: Timer
var _chargeBar: TextureProgress
var _animationHandler: BlendTreeAnimationHandler

func _init(attackResetTimer: Timer, chargeBar: TextureProgress, animationHandler: BlendTreeAnimationHandler):
	_attackResetTimer = attackResetTimer
	_chargeBar = chargeBar
	_animationHandler = animationHandler


func resetCombo():
	_comboAPoints = _START_A_COMBO
	_comboBPoints = _START_B_COMBO


func _attack_setup(is_kick: bool):
	isAttacking = true
	didHitEnemy = false
	isLastAttackAKick = is_kick
	_attackResetTimer.start(COMBOTIME)


func doSideSwipeAttack(scene : Node):
	if !isAttacking:
		_attack_setup(false)
		_playPunchSFX = true
		print("Combo A: " + String(_comboAPoints))
		if _comboAPoints == 1 or _comboBPoints == 1:
			_animationHandler.headbutt()
			SoundPlayer.playSound(scene, missSound, -4)
			damageForce = MAX_DAMAGE_FORCE
			combo_reset()
		elif _comboAPoints == 3:
			_animationHandler.punch1()
			SoundPlayer.playSound(scene, missSound, -4)
			_comboAPoints = _comboAPoints - 1
			_comboBPoints = 3
			damageForce = MIN_DAMAGE_FORCE
		elif _comboAPoints == 2:
			_animationHandler.punch2()
			SoundPlayer.playSound(scene, missSound, -4)
			_comboAPoints = _comboAPoints - 1
			_comboBPoints = 3
			damageForce = MIN_DAMAGE_FORCE


func doSideSwipeKick(scene : Node):
	if !isAttacking:
		_attack_setup(true)
		print("Combo B: " + String(_comboBPoints))
		if _comboBPoints == 1 or _comboAPoints == 1:
			_animationHandler.shoryuken()
			SoundPlayer.playSound(scene, shoryukenSound, _DEFAULT_ATTACK_VOLUME)
			damageForce = MAX_DAMAGE_FORCE
			combo_reset()
		elif _comboBPoints == 3:
			_comboBPoints = _comboBPoints - 1
			_playKickSFX = true
			print("playkick1")
			_animationHandler.kick1()
			SoundPlayer.playSound(scene, missSound, -4)
			_comboAPoints = 3
			damageForce = MIN_DAMAGE_FORCE
		elif _comboBPoints == 2:
			_comboBPoints = _comboBPoints - 1
			_playKickSFX = true
			print("playkick2")
			_animationHandler.kick2()
			SoundPlayer.playSound(scene, missSound, -4)
			_comboAPoints = 3
			damageForce = MIN_DAMAGE_FORCE


func getHadoukenPercentage() -> float:
	return _chargeBar.value


func startSpecial():
	_chargeBar.visible = true
	_animationHandler.chargeHadouken()
	IsChargingSpecial = true


func releaseSpecial():
	isAttacking = true
	_animationHandler.releaseHadouken()
	IsChargingSpecial = false
	_playHadoukenSFX = true
	_hideChargeBar()


func _hideChargeBar():
	_chargeBar.value = 0
	_chargeBar.visible = false


func increaseChargeBar():
	if IsChargingSpecial:
		_chargeBar.value += 1


func playHitSounds(scene : Node):
	if _playPunchSFX:
		SoundPlayer.playSound(scene, punchSound, _DEFAULT_ATTACK_VOLUME)
	elif _playKickSFX: 
		SoundPlayer.playSound(scene, kickSound, _DEFAULT_ATTACK_VOLUME)
	elif _playHadoukenSFX: 
		SoundPlayer.playSound(scene, hadouken, _DEFAULT_ATTACK_VOLUME)
	_resetAllSounds()


func _resetAllSounds():
	_playKickSFX = false
	_playPunchSFX = false
	_playHadoukenSFX = false
	_playShoryukenSFX = false


func gotHit():
	IsChargingSpecial = false
	isAttacking = false
	_hideChargeBar()
	resetCombo()


func combo_reset() -> void:
	#print("combo reset")
	_comboAPoints = _START_A_COMBO
	_comboBPoints = _START_B_COMBO
