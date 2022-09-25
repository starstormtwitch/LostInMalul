extends AttackManager

class_name AttackManagerLevel2

var _startedHadouken = false

func _init(attackResetTimer: Timer, chargeBar: TextureProgress, animationHandler: BlendTreeAnimationHandler).(attackResetTimer, chargeBar, animationHandler):
	_START_A_COMBO = 2
	_comboAPoints = _START_A_COMBO


func resetCombo():
	_comboAPoints = _START_A_COMBO


func doSideSwipeAttack(scene : Node):
	if attackLock.try_lock() == OK:
		_attack_setup(false)
		_playPunchSFX = true
		#print("Combo A: " + String(_comboAPoints))
		if _comboAPoints == 2:
			_animationHandler.punch1()
			SoundPlayer.playSound(scene, missSound, -4)
			_comboAPoints = _comboAPoints - 1
			damageForce = MIN_DAMAGE_FORCE
		elif _comboAPoints == 1:
			_animationHandler.punch2()
			SoundPlayer.playSound(scene, missSound, -4)
			_comboAPoints = _START_A_COMBO
			damageForce = MIN_DAMAGE_FORCE


func doSideSwipeKick(scene : Node):
	if attackLock.try_lock() == OK:
		_attack_setup(true)
		print("Sideswipe kick")
		_animationHandler.kick1()
		SoundPlayer.playSound(scene, missSound, -4)
		damageForce = MAX_DAMAGE_FORCE
		combo_reset()


func playKickPart2(scene : Node):
	if attackLock.try_lock() == OK:
		_attack_setup(true)
		print("Sideswipe kick")
		_animationHandler.kick2()
		SoundPlayer.playSound(scene, missSound, -4)
		damageForce = MAX_DAMAGE_FORCE
		combo_reset()


func doShoryuken(scene : Node):
	if attackLock.try_lock() == OK:
		_attack_setup(true)
		print("SHoryuken")
		_animationHandler.shoryuken()
		damageForce = MAX_DAMAGE_FORCE
		combo_reset()


func startSpecial():
	_chargeBar.visible = true
	if _startedHadouken:
		_animationHandler.chargeHadouken()
	else:
		_startedHadouken = true
		_animationHandler.startHadouken()
	IsChargingSpecial = true


func playChargingSpecialAnimation():
	_animationHandler.chargeHadouken()


func releaseSpecial():
	.releaseSpecial()
	_startedHadouken = false


func gotHit():
	.gotHit()
	_startedHadouken = false


func combo_reset() -> void:
	#print("combo reset")
	_comboAPoints = _START_A_COMBO
