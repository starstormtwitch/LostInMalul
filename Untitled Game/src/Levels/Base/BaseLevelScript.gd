extends Node

class_name BaseLevelScript

var _cameraManager: CustomCamera2D
var _infiniteHealth: bool;
var _enteredAreas: Array
var save_path = "user://save.dat"

func _ready():
	_setup()

func _setup():
	if LevelGlobals.SceneHasPlayerActor():
		print(self.name + ': setup start.')
		InitCameraManager()
		RegisterTeleporterSignals()
		RegisterDelimiterSignals()
		print(self.name + ': setup end.')
	else:
		print(self.name + ': player actor not available.')
	_get_game_settings()
	
	
func save_game():
	var player_data = CreatePlayerSave(LevelGlobals.GetPlayerActor());
	LevelGlobals.SetPlayerSaveData(player_data)
	var saveFile = File.new();
	var error = saveFile.open_encrypted_with_pass(save_path, File.WRITE, "33KJLDSF0AFKJ23LJA;DSFL3;OIDFJAODLASNCMCNVC320498203948WKLJFCJ230498ODISFASDF9A87DS0987AS6C09A6FA6G9D7S98G6A9DFSHG98DA98H06A87FDGADFV5ADSF98DSA87F65ADS98GA87G6A6A0D87F7SA0DC6A0S6A0DS786F")
	assert(error == OK, "ERROR: Failed to save game!!!")
	print(player_data)
	saveFile.store_var(player_data);
	saveFile.close();
	
func CreatePlayerSave(player : Actor) -> Dictionary:
	var playerSaveData = {
		"coins" : player.Coins,
		"health" : player._health,
		"inventoryItem" : player.InventoryItem,
		"checkpoint" : player._checkPoint,
		"level" : player._level
		};
	
	return playerSaveData;

func SetCheckpoint(level, checkpointKey):
	var playerData = LevelGlobals.GetPlayerActor()	
	assert(playerData != null, "Player is null!")
	playerData._level = level;
	playerData._checkPoint = checkpointKey;
	save_game();

func load_game():
	var saveFile = File.new()
	var player_data
	if saveFile.file_exists(save_path):
		var error = saveFile.open_encryp(save_path, File.READ, "33KJLDSF0AFKJ23LJA;DSFL3;OIDFJAODLASNCMCNVC320498203948WKLJFCJ230498ODISFASDF9A87DS0987AS6C09A6FA6G9D7S98G6A9DFSHG98DA98H06A87FDGADFV5ADSF98DSA87F65ADS98GA87G6A6A0D87F7SA0DC6A0S6A0DS786F")
		assert(error == OK, "ERROR: Failed to load game!!!")
		player_data = saveFile.get_var()
		saveFile.close()
		print(player_data)
		LevelGlobals.SetPlayerSaveData(player_data)
	return player_data;
	
func load_checkpoint():
	get_tree().paused = true;
	var playerData = LevelGlobals.GetPlayerActor()	
	assert(playerData != null, "Player is null!")
	var gameScene = LevelGlobals.GetLevelScene(playerData._level);
	assert(gameScene != null, "Unknown level!");
	get_tree().change_scene(gameScene);
	get_tree().paused = true;
	var currentLevel = get_tree().current_scene;
	assert(currentLevel.has_method("SetLevelCheckpointVariables"), "script is missing mandatory load method")
	currentLevel.SetLevelCheckpointVariables(playerData._checkPoint)
	get_tree().paused = false;
	
		
func _get_game_settings():
	var values = Settings.load_game_settings()
	_set_game_settings(values.infiniteHealth)
	
func _set_game_settings(infiniteHealth: bool):
	_infiniteHealth = infiniteHealth

func InitCameraManager() -> void:
	_cameraManager = CustomCamera2D.new(LevelGlobals.GetPlayerActor(), true)
	_cameraManager.connect_to_player_shake_signal(LevelGlobals.GetPlayerActor())
	_cameraManager.connect_to_area_lock_signal(get_tree().get_current_scene())

func GetCameraManager() -> CustomCamera2D:
	return _cameraManager

func RegisterTeleporterSignals() -> void:
	var teleporters = self.get_parent().get_tree().get_nodes_in_group("TeleportNode")
	for _tp in teleporters:
		#var tp: TwoWayTeleportNode2D = _tp
		assert(_tp.has_signal("TeleportActivated"), "Teleport node has no TeleportActivated signal.")
		_tp.connect("TeleportActivated", self, "TeleportPlayerToPosition")
	print("Registered teleporters.")

func RegisterDelimiterSignals() -> void:
	var delimiters = self.get_parent().get_tree().get_nodes_in_group("DelimiterNode")
	for _dl in delimiters:
		#var dl: CustomDelimiter2D = _dl
		assert(_dl.has_signal("PlayerEnteredAreaDelimiter"), "Delimiter node has no PlayerEnteredAreaDelimiter signal.")
		_dl.connect("PlayerEnteredAreaDelimiter", self, "CameraTransitionToDelimiter")
		assert(_dl.has_signal("PlayerExitedAreaDelimiter"), "Delimiter node has no PlayerExitedAreaDelimiter signal.")
		_dl.connect("PlayerExitedAreaDelimiter", self, "CameraTransitionToOuterDelimiter")
	print("Registered delimiters.")

func CameraTransitionToOuterDelimiter(delimiter: CustomDelimiter2D) -> void:	
	var thisDelimiter = _enteredAreas.pop_back();
	var overlappingDelimiter = _enteredAreas.pop_back();
	_enteredAreas.push_back(overlappingDelimiter);
	assert(overlappingDelimiter != null, "No overlapping area!!!")
	_cameraManager.limitCameraToDelimiter(overlappingDelimiter) 
	
	
func CameraTransitionToDelimiter(delimiter: CustomDelimiter2D) -> void:	
	_cameraManager.limitCameraToDelimiter(delimiter) 
	_enteredAreas.push_back(delimiter);

func TeleportPlayerToPosition(position: Vector2, playFadeTime: float = 0) -> void:
	get_tree().paused = true
	if playFadeTime > 0:
		_cameraManager._animationPlayer.playFadeIn(playFadeTime)
		yield(_cameraManager._animationPlayer._player, "animation_finished")
	LevelGlobals.GetPlayerActor().position = position
	if playFadeTime > 0:
		_cameraManager._animationPlayer.playFadeOut(playFadeTime)
	get_tree().paused = false
