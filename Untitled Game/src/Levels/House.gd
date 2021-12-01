extends Node2D

var _player : Actor
onready var cameraManager: CustomCamera2D

const _INTERACT_EVENT = "interact"

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = LevelGlobals.GetPlayerActor()
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)		

func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/Control/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()
