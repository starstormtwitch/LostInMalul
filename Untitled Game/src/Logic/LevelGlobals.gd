extends Node

var _player: Actor
var _scene: Node

var _layerDict: Dictionary = {}
var _player_data: Dictionary = {
		"checkpoint" : start_point,
		"level" : start_level,
		"coins" : 0
		}
const save_path = "user://save.dat"
const start_level = "House"
const start_point = "Start"
const _layerBitParamName: String = "bit"
const _layerValueParamName: String = "value"
const _levelDictionary = {
	"MainMenu" : preload("res://src/Levels/Menu/MainMenu.tscn"),
	"House" : preload("res://src/Levels/House.tscn"),
	"Streets" : preload("res://src/Levels/Streets.tscn"),
	"Credits" : preload("res://src/Levels/Credits.tscn"),
	"Minigame" : preload("res://src/Levels/BanningMinigame.tscn"),
}  
var rng = RandomNumberGenerator.new();

func _ready():
	rng.randomize();
	_createLayerDictionary()
	InputFunctions.LoadCustomMappings()

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

func save_game():
	var saveFile = File.new();
	var error = saveFile.open_encrypted_with_pass(save_path, File.WRITE, "33KJLDSF0AFKJ23LJA;DSFL3;OIDFJAODLASNCMCNVC320498203948WKLJFCJ230498ODISFASDF9A87DS0987AS6C09A6FA6G9D7S98G6A9DFSHG98DA98H06A87FDGADFV5ADSF98DSA87F65ADS98GA87G6A6A0D87F7SA0DC6A0S6A0DS786F")
	assert(error == OK, "ERROR: Failed to save game!!!")
	print(_player_data)
	saveFile.store_var(_player_data);
	saveFile.close();
	
func NewPlayerSave() -> Dictionary:
	var playerSaveData = {
		"coins" : 0,
		"checkpoint" : start_point,
		"level" : start_level
		};
	
	return playerSaveData;
	
func CreatePlayerSave(player : Actor) -> Dictionary:
	var playerSaveData = {
		"coins" : player.Coins,
		"health" : player._health,
		"checkpoint" : start_point,
		"level" : start_level
		};
	
	return playerSaveData;

func SetCheckpoint(level, checkpointKey):
	assert(_player_data != null, "Player data is null!")
	_player_data = CreatePlayerSave(_player)
	_player_data.level = level;
	_player_data.checkpoint = checkpointKey;
	save_game();

func new_game():
	_player_data = NewPlayerSave();
	var gameScene = LevelGlobals.GetLevelScene(start_level);
	assert(gameScene != null, "Unknown level!");
	get_tree().change_scene_to(gameScene);
	get_tree().paused = true;
	var currentLevel = get_tree().get_current_scene();
	get_tree().paused = false;
	
func load_game():
	var saveFile = File.new()
	var player_data
	if saveFile.file_exists(save_path):
		var error = saveFile.open_encrypted_with_pass(save_path, File.READ, "33KJLDSF0AFKJ23LJA;DSFL3;OIDFJAODLASNCMCNVC320498203948WKLJFCJ230498ODISFASDF9A87DS0987AS6C09A6FA6G9D7S98G6A9DFSHG98DA98H06A87FDGADFV5ADSF98DSA87F65ADS98GA87G6A6A0D87F7SA0DC6A0S6A0DS786F")
		assert(error == OK, "ERROR: Failed to load game!!!")
		player_data = saveFile.get_var()
		saveFile.close()
		print(player_data)
		LevelGlobals.SetPlayerSaveData(player_data)
		load_checkpoint();
	else:
		new_game();
	
func load_checkpoint():    
	var playerData = LevelGlobals.GetPlayerSaveData()	
	assert(playerData != null, "Player save data is null!")
	var gameScene = LevelGlobals.GetLevelScene(playerData.level);
	assert(gameScene != null, "Unknown level!");
	get_tree().change_scene_to(gameScene);
	get_tree().paused = true;
	var currentLevel = get_tree().get_current_scene();
	get_tree().paused = false;
		
func FindSetLevelScene():
	_findSceneEntity()
	
func FindSetPlayerActor():
	_findPlayerEntity()

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
				_layerBitParamName : i-1,
				_layerValueParamName : pow(2, i-1)
			}
#	print(_layerDict)

func GetLayerBit(name: String) -> int:
	return _layerDict[name][_layerBitParamName]
	
func GetLayerValue(name: String) -> int:
	return _layerDict[name][_layerValueParamName]
