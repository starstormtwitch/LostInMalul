extends Node

var _player: Actor

func _ready():
	_findPlayerEntity()

func SceneHasPlayerActor() -> bool:
	return _player != null

func GetPlayerActor() -> Actor:
	_findPlayerEntity()
	assert(_player, "Player node not found.")
	print("found player")
	return _player;

func _findPlayerEntity() -> void:
	var parent = get_parent()
	if parent != null:
		var tree = parent.get_tree()
		var players = tree.get_nodes_in_group("Player")
		if players.size() > 0:
			_player = players[0]
	else:
		printerr("parent does not exist")
