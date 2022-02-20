extends Node

class_name AttackManager

const _START_A_COMBO = 3
const _START_B_COMBO = 3
const COMBOTIME = 1
const MAX_DAMAGE_FORCE = 25000
const MIN_DAMAGE_FORCE = 1000

var isAttacking: bool = false
var didHitEnemy: bool = false #To check to see if we should play woosh sfx if we missed
var _beingHurt: bool = false
var isLastAttackAKick = false #Used to check which hitmarker to show
var _directionFacing: Vector2 = Vector2.ZERO
var damageForce = 0

var _comboAPoints = _START_A_COMBO;
var _comboBPoints = _START_B_COMBO;

# Injected from player
var _attackResetTimer: Timer
var _punchAudioPlayer: HitAudioPlayer
var _kickAudioPlayer: HitAudioPlayer
var _shoryukenAudioPlayer: AudioStreamPlayer
var _animationTree: AnimationTree

func _init(attackResetTimer: Timer, punchAudioPlayer: HitAudioPlayer,
		kickAudioPlayer: HitAudioPlayer, shoryukenAudioPlayer: AudioStreamPlayer, animationTree: AnimationTree):
	_attackResetTimer = attackResetTimer
	_punchAudioPlayer = punchAudioPlayer
	_kickAudioPlayer = kickAudioPlayer
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


func doSideSwipeAttack():
	if !isAttacking:
		_attack_setup(false)
		print("Combo A: " + String(_comboAPoints))
		if _comboAPoints == 1 or _comboBPoints == 1:
			_punchAudioPlayer.playerAttacks()
			_animationTree.get("parameters/playback").travel("Headbutt")
			combo_reset()
			damageForce = MAX_DAMAGE_FORCE
		elif _comboAPoints == 3:
			_punchAudioPlayer.playerAttacks()
			_animationTree.get("parameters/playback").travel("SideSwipe1")
			_comboAPoints = _comboAPoints - 1
			_comboBPoints = 3
			damageForce = MIN_DAMAGE_FORCE
		elif _comboAPoints == 2:
			_punchAudioPlayer.playerAttacks()
			_animationTree.get("parameters/playback").travel("SideSwipe2")
			_comboAPoints = _comboAPoints - 1
			_comboBPoints = 3
			damageForce = MIN_DAMAGE_FORCE


func doSideSwipeKick():
	if !isAttacking:
		_attack_setup(true)
		print("Combo B: " + String(_comboBPoints))
		if _comboBPoints == 1 or _comboAPoints == 1:
			_shoryukenAudioPlayer.play()
			_animationTree.get("parameters/playback").travel("Shoryuken")
			combo_reset()
			damageForce = MAX_DAMAGE_FORCE
		elif _comboBPoints == 3:
			_kickAudioPlayer.playerAttacks()
			_animationTree.get("parameters/playback").travel("SideSwipeKick")
			_comboBPoints = _comboBPoints - 1
			_comboAPoints = 3
			damageForce = MIN_DAMAGE_FORCE
		elif _comboBPoints == 2:
			_kickAudioPlayer.playerAttacks()
			_animationTree.get("parameters/playback").travel("SideSwipeRightKick2")
			_comboBPoints = _comboBPoints - 1
			_comboAPoints = 3
			damageForce = MIN_DAMAGE_FORCE


func playHitSounds():
	_punchAudioPlayer.playHitSound()
	_kickAudioPlayer.playHitSound()

func combo_reset() -> void:
	#print("combo reset")
	_comboAPoints = _START_A_COMBO
	_comboBPoints = _START_B_COMBO
