extends MainChar

class_name LirikYaki

var attackList = ["Headbutt", "Hadouken2", "Shoryuken", "SideSwipeRight", "SideSwipeRight2", "SideSwipeRightKick", "SideSwipeRightKick2","SideSwipeRight", "Hadouken3", "Shoryuken", "SideSwipeRight", "SideSwipeRight2", "SideSwipeRightKick2"]

func _ready() -> void:
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

func _on_AnimationPlayer_animation_finished(anim_name):
	if(attackList.Has(anim_name)):
		_finishedAttack()


func _on_AnimationPlayer_animation_changed(old_name, new_name):
	if(attackList.Has(old_name)):
		_finishedAttack()
