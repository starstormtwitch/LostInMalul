extends Node

class_name AttackManager

var kickSound = preload("res://assets/audio/HitAudio/kick_sfx.wav")
var punchSound = preload("res://assets/audio/HitAudio/punch_sfx.wav")
var missSound = preload("res://assets/audio/HitAudio/miss_sfx.wav")

const _START_A_COMBO = 3
const _START_B_COMBO = 3
const COMBOTIME = 1
const MAX_DAMAGE_FORCE = 10000
const MIN_DAMAGE_FORCE = 1000
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

#flags to check if we should play certain sounds when attacks land
var _playPunchSFX = false
var _playKickSFX = false

var _comboAPoints = _START_A_COMBO;
var _comboBPoints = _START_B_COMBO;

# Injected from player
var _attackResetTimer: Timer
var _shoryukenAudioPlayer: AudioStreamPlayer
var _animationTree: AnimationTree

func _init(attackResetTimer: Timer, shoryukenAudioPlayer: AudioStreamPlayer, animationTree: AnimationTree):
	_attackResetTimer = attackResetTimer
	_shoryukenAudioPlayer = shoryukenAudioPlayer
	_animationTree = animationTree


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
			playHitSounds(scene)
			_animationTree.get("parameters/playback").travel("Headbutt")
			combo_reset()
			damageForce = MAX_DAMAGE_FORCE
		elif _comboAPoints == 3:
			_animationTree.get("parameters/playback").travel("SideSwipe1")
			_comboAPoints = _comboAPoints - 1
			_comboBPoints = 3
			damageForce = MIN_DAMAGE_FORCE
		elif _comboAPoints == 2:
			_animationTree.get("parameters/playback").travel("SideSwipe2")
			_comboAPoints = _comboAPoints - 1
			_comboBPoints = 3
			damageForce = MIN_DAMAGE_FORCE


func doSideSwipeKick(scene : Node):
	if !isAttacking:
		_attack_setup(true)
		_playKickSFX = true
		print("Combo B: " + String(_comboBPoints))
		if _comboBPoints == 1 or _comboAPoints == 1:
			_animationTree.get("parameters/playback").travel("Shoryuken")
			combo_reset()
			damageForce = MIN_DAMAGE_FORCE
		elif _comboBPoints == 3:
			_animationTree.get("parameters/playback").travel("SideSwipeKick")
			_comboBPoints = _comboBPoints - 1
			_comboAPoints = 3
			damageForce = MIN_DAMAGE_FORCE
		elif _comboBPoints == 2:
			_animationTree.get("parameters/playback").travel("SideSwipeRightKick2")
			_comboBPoints = _comboBPoints - 1
			_comboAPoints = 3
			damageForce = MIN_DAMAGE_FORCE


func startSpecial():
	_animationTree.get("parameters/playback").travel("Hadouken")


func releaseSpecial():
	_animationTree.get("parameters/playback").travel("Hadouken2")


func playHitSounds(scene : Node):
	if _playPunchSFX:
		SoundPlayer.playSound(scene, punchSound, _DEFAULT_ATTACK_VOLUME)
	elif _playKickSFX: 
		SoundPlayer.playSound(scene, kickSound, _DEFAULT_ATTACK_VOLUME)
	_resetAllSounds()


func _resetAllSounds():
	_playKickSFX = false
	_playPunchSFX = false


func playMissSounds(scene: Node):
	SoundPlayer.playSound(scene, missSound, _DEFAULT_WOOSH_VOLUME)
	_resetAllSounds()


func combo_reset() -> void:
	#print("combo reset")
	_comboAPoints = _START_A_COMBO
	_comboBPoints = _START_B_COMBO
