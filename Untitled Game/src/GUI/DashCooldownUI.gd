extends Control


# how long cooldown lasts for in seconds
var cooldown_time: float = 1

onready var progressBar: ProgressBar = $ProgressBar
onready var intervalTimer: Timer = $IntervalTimer
onready var cooldownTimer: Timer = $CooldownTimer
onready var sprite: Sprite = $Sprite


func _ready():
	_connectToPlayer()


func _connectToPlayer():
	var player: LirikYaki = LevelGlobals.GetPlayerActor()
	player.connect("player_dodge", self, "startCooldown")
	cooldown_time = player.getDodgeCooldownTime()


func startCooldown():
	var intervalTime = float(cooldown_time) / 100
	sprite.modulate.a = 0.5
	progressBar.value = 0
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
