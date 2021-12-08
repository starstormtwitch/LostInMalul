extends Node

var _cameraManager: CustomCamera2D

func _ready():
	if LevelGlobals.SceneHasPlayerActor():
		InitCameraManager()
		RegisterTeleporterSignals()
		RegisterDelimiterSignals()

func InitCameraManager() -> void:
	_cameraManager = CustomCamera2D.new(LevelGlobals.GetPlayerActor(), true)	

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
	print("Registered delimiters.")

func GetCameraManager() -> CustomCamera2D:
	return _cameraManager

func CameraTransitionToDelimiter(delimiter: CustomDelimiter2D) -> void:	
	_cameraManager.limitCameraToDelimiter(delimiter) 

func TeleportPlayerToPosition(position: Vector2, playFadeTime: float = 0) -> void:
	if playFadeTime > 0:
		_cameraManager._animationPlayer.playFadeIn(playFadeTime)
		yield(_cameraManager._animationPlayer._player, "animation_finished")
	LevelGlobals.GetPlayerActor().position = position
	if playFadeTime > 0:
		_cameraManager._animationPlayer.playFadeOut(playFadeTime)
	
