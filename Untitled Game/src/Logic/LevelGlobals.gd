extends Node

var _player: Actor
var _scene: Node

var _player_data: Dictionary = {}
var _layerDict: Dictionary = {}
const _layerBitParamName: String = "bit"
const _layerValueParamName: String = "value"
const _levelDictionary = {
	"House" : preload("res://src/Levels/House.tscn"),
}  

func _ready():
	_findPlayerEntity()
	_findSceneEntity()
	_createLayerDictionary()

func SceneHasPlayerActor() -> bool:
	return _player != null
	
func SceneHasTree() -> bool:
	return _scene != null

func GetPlayerSaveData() -> Dictionary:
	return _player_data
	
func SetPlayerSaveData(player_data : Dictionary):
	_player_data = player_data;

func GetLevelScene(level : String) -> PackedScene:
	assert(_levelDictionary.has(level), "Level scene does not exist in level globals")
	return _levelDictionary[level];

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
	else:
		printerr("Parent does not exist.")
		
func _findSceneEntity() -> void:
	var parent = get_parent()
	if parent != null:
		_scene = parent
	else:
		printerr("Parent does not exist.")

func _createLayerDictionary() -> void:
	for i in range(1, 32, 1):
		var layer = ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(i))
		if layer != null && !layer.empty():
			_layerDict[layer] = {
				_layerBitParamName : i,
				_layerValueParamName : pow(2, i-1)
			}
#	print(_layerDict)

func GetLayerBit(name: String) -> int:
	return _layerDict[name][_layerBitParamName]
	
func GetLayerValue(name: String) -> int:
	return _layerDict[name][_layerValueParamName]
