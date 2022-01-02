extends Node

var _player: Actor

func _ready():
	_findPlayerEntity()

func SceneHasPlayerActor() -> bool:
	return _player != null

func GetPlayerActor() -> Actor:
	if(_player == null || !is_instance_valid(_player)):
		_findPlayerEntity()
	if(_player == null || !is_instance_valid(_player)):
		assert(false, "Player node not found.")
	return _player;

func _findPlayerEntity() -> void:
	var parent = get_parent()
	if parent != null:
		var tree = parent.get_tree()
		var players = tree.get_nodes_in_group("Player")
		if players.size() > 0:
			_player = players[0]
