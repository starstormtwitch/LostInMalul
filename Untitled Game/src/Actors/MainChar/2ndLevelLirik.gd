extends LirikYaki

class_name SecondLevelLirik

var _attackManagerLevel2: AttackManagerLevel2 = null

func _ready() -> void:
	_animationHandler = Level2BlendTreeAnimationHandler.new(animationTree)
	_attackManagerLevel2 = AttackManagerLevel2.new(_attackResetTimer,
		chargeBar, _animationHandler)
	_attackManager = _attackManagerLevel2
	hadouken_scene = preload("res://src/Actors/MainChar/HadoukenBlastLevel2.tscn")


func _check_for_events(delta) -> bool:
	if Input.is_action_just_released(AttackManager.SPECIAL_ATTACK_EVENT) and _attackManager.IsChargingSpecial:
		_summonHadouken()
		return true
	elif checkForEvent(AttackManager.SPECIAL_ATTACK_EVENT, delta):
		checkForSuperCharges()
		return true
	elif checkForEvent(AttackManager.ATTACK1_EVENT, delta):
		_attackManager.doSideSwipeAttack(get_tree().get_current_scene())
		return true
	elif checkForEvent(AttackManager.ATTACK2_EVENT, delta):
		_attackManager.doSideSwipeKick(get_tree().get_current_scene())
		return true
	elif checkForEvent(_DASH_EVENT, delta):
		_start_dash()
		return false
	else:
		return false


func playChargeAnimation():
	print("play charging animation for hadouken.")
	_attackManagerLevel2.playChargingSpecialAnimation()
