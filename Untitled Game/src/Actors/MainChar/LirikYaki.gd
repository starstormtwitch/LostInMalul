extends MainChar

class_name LirikYaki

func _ready() -> void:
	$Light2D.visible = false;
	$Light2DMask.visible = false;
	_attackManager = AttackManager.new(_attackResetTimer,
		chargeBar, _animationHandler)

func ToggleLight(toggleStatus) -> void:
	$Light2D.visible = toggleStatus;
	$Light2DMask.visible = toggleStatus;

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
