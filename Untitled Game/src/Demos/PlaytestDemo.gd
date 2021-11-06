extends Node2D


var _player : Actor
onready var cameraManager: CustomCamera2D


onready var _cam_Delimiter_Basement = get_node("LevelBackground/CameraPositions/Basement_Delimiter")

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	if(parent != null):
		var tree = parent.get_tree()
		var players = tree.get_nodes_in_group("Player")
		if(players.size() > 0):
			_player = players[0]
	assert(_player, "Player Node does not exist.")
	#assert(_camera, "Camera2D Node does not exist")
	cameraManager = CustomCamera2D.new(_player, true)
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_Basement)
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)


func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/Control/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()

