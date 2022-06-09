extends MainChar

class_name LirikYaki

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	._ready()
	_attackManager = AttackManager.new(_attackResetTimer,
		chargeBar, animationTree)


func _check_for_events() -> bool:
	if Input.is_action_just_released(AttackManager.SPECIAL_ATTACK_EVENT) and _attackManager.isChargingSpecial:
		_summonHadouken()
		return true
	elif checkForEvent(AttackManager.SPECIAL_ATTACK_EVENT):
		checkForSuperCharges()
		return true
	elif checkForEvent(AttackManager.ATTACK1_EVENT):
		_attackManager.doSideSwipeAttack(get_tree().get_current_scene())
		return true
	elif checkForEvent(AttackManager.ATTACK2_EVENT):
		_attackManager.doSideSwipeKick(get_tree().get_current_scene())
		return true
	elif checkForEvent(_DASH_EVENT):
		_start_dash()
		return false
	else:
		return false
