extends Control


# how long cooldown lasts for in seconds
export (int) var cooldown_time: int = 1

onready var progressBar: ProgressBar = $ProgressBar
onready var intervalTimer: Timer = $IntervalTimer
onready var cooldownTimer: Timer = $CooldownTimer
onready var sprite: Sprite = $Sprite


func startCooldown():
	var intervalTime = float(cooldown_time) / 100
	sprite.modulate.a = 0.66
	progressBar.visible = true
	intervalTimer.wait_time = intervalTime
	intervalTimer.start()
	cooldownTimer.wait_time = cooldown_time
	cooldownTimer.start()


func _intervalAdjust():
	progressBar.value += 1
	

func _fullProgress():
	intervalTimer.stop()
	progressBar.visible = false
	sprite.modulate.a = 1
