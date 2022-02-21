extends Node

var _player: Actor

var _layerDict: Dictionary = {}
const _layerBitParamName: String = "bit"
const _layerValueParamName: String = "value"

func _ready():
	_findPlayerEntity()
	_createLayerDictionary()

func SceneHasPlayerActor() -> bool:
	return _player != null

func GetPlayerActor() -> Actor:
	_findPlayerEntity()
	assert(_player, "Player node not found.")
	print("Player found.")
	return _player;

func _findPlayerEntity() -> void:
	var parent = get_parent()
	if parent != null:
		var tree = parent.get_tree()
		var players = tree.get_nodes_in_group("Player")
		if players.size() > 0:
			_player = players[0]
	else:
		printerr("Parent does not exist.")

func _createLayerDictionary() -> void:
	for i in range(1, 32, 1):
		var layer = ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(i))
		if !layer.empty():
			_layerDict[layer] = {
				_layerBitParamName : i,
				_layerValueParamName : pow(2, i-1)
			}
#	print(_layerDict)

func GetLayerBit(name: String) -> int:
	return _layerDict[name][_layerBitParamName]
	
func GetLayerValue(name: String) -> int:
	return _layerDict[name][_layerValueParamName]
