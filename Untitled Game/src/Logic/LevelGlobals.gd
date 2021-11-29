extends Node

var _player: Actor

func _ready():
	_findPlayerEntity()

func GetPlayerActor() -> Actor:
	assert(_player, "Player node not found.")
	return _player;

func _findPlayerEntity() -> void:
	var parent = get_parent()
	if parent != null:
		var tree = parent.get_tree()
		var players = tree.get_nodes_in_group("Player")
		if players.size() > 0:
			_player = players[0]
