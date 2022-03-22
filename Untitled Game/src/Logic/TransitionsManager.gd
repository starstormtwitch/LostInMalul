extends Node

var _cameraManager: CustomCamera2D
var _enteredAreas: Array

func _ready():
	setup()

func setup():
	if LevelGlobals.SceneHasPlayerActor():
		InitCameraManager()
		RegisterTeleporterSignals()
		RegisterDelimiterSignals()

func InitCameraManager() -> void:
	_cameraManager = CustomCamera2D.new(LevelGlobals.GetPlayerActor(), true)
	_cameraManager.connect_to_player_shake_signal(LevelGlobals.GetPlayerActor())

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

func GetCameraManager() -> CustomCamera2D:
	return _cameraManager

func CameraTransitionToDelimiter(delimiter: CustomDelimiter2D) -> void:	
	_cameraManager.limitCameraToDelimiter(delimiter) 
	_enteredAreas.push_back(delimiter);

func CameraTransitionToOuterDelimiter(delimiter: CustomDelimiter2D) -> void:	
	var thisDelimiter = _enteredAreas.pop_back();
	var overlappingDelimiter = _enteredAreas.back();
	assert(overlappingDelimiter != null, "No overlapping area!!!")
	_cameraManager.limitCameraToDelimiter(overlappingDelimiter) 
	
	
func TeleportPlayerToPosition(position: Vector2, playFadeTime: float = 0) -> void:
	get_tree().paused = true
	if playFadeTime > 0:
		_cameraManager._animationPlayer.playFadeIn(playFadeTime)
		yield(_cameraManager._animationPlayer._player, "animation_finished")
	LevelGlobals.GetPlayerActor().position = position
	if playFadeTime > 0:
		_cameraManager._animationPlayer.playFadeOut(playFadeTime)
	get_tree().paused = false
	
