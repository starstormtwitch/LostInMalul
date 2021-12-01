extends Node

var _cameraManager: CustomCamera2D

func _ready():
	if LevelGlobals.SceneHasPlayerActor():
		InitCameraManager()
	
func InitCameraManager() -> void:
	_cameraManager = CustomCamera2D.new(LevelGlobals.GetPlayerActor(), true)

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
	
