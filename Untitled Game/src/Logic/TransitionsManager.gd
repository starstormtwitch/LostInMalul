extends Node

var _cameraManager: CustomCamera2D

func _ready():		
	_cameraManager = CustomCamera2D.new(LevelGlobals.GetPlayerActor(), true)

func CameraTransitionToDelimiter(delimiter: CustomDelimiter2D) -> void:
	_cameraManager.limitCameraToDelimiter(delimiter) 

func TeleportPlayerToPosition(position: Vector2, playFade: bool) -> void:
	if playFade:
		_cameraManager._animationPlayer.playFadeIn()
		yield(_cameraManager._animationPlayer._player, "animation_finished")
	LevelGlobals.GetPlayerActor().position = position
	if playFade:
		_cameraManager._animationPlayer.playFadeOut()
	
