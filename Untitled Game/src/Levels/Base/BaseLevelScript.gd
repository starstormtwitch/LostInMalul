extends Node

class_name BaseLevelScript

const LockOutFight = preload("res://src/Helpers/Interacts/AreaLockFight.gd")

var _cameraManager: CustomCamera2D
var _enteredAreas: Array
var settings

signal area_lock

func _ready():
	_setup()

func _setup():
#	MEGA IMPORTANT, PLAYER ALWAYS NEEDS TO BE REFRESHED IN EACH SCENE
	var player = LevelGlobals.GetPlayerActor()
	assert(is_instance_valid(player),"Player instance invalid")
	print(self.name + ': setup start.')
	player.connect("died", self, "_on_Player_died")
	InitCameraManager()
	RegisterTeleporterSignals()
	RegisterDelimiterSignals()

func InitCameraManager() -> void:
	_cameraManager = CustomCamera2D.new(LevelGlobals.GetPlayerActor(), true)
#	_cameraManager.connect_to_player_shake_signal(LevelGlobals.GetPlayerActor())
	var player = LevelGlobals.GetPlayerActor()
	assert(player.has_signal("player_hit_enemy"), "Player hit enemy signal not found.")
	player.connect("player_hit_enemy", _cameraManager, "shake")
	_cameraManager.connect_to_area_lock_signal(get_tree().get_current_scene())

func GetCameraManager() -> CustomCamera2D:
	return _cameraManager

func area_lock_handler(enabled):
	emit_signal("area_lock", enabled)

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
	print("Trasitioning to outer delimiter ")
	var thisDelimiter = _enteredAreas.pop_back();
	var overlappingDelimiter = _enteredAreas.pop_back();
	_enteredAreas.push_back(overlappingDelimiter);
	assert(overlappingDelimiter != null, "No overlapping area!!!")
	_cameraManager.limitCameraToDelimiter(overlappingDelimiter, _cameraManager.TransitionTypeEnum.SMOOTH)


func CameraTransitionToDelimiter(delimiter: CustomDelimiter2D, isAreaLock: bool) -> void:
	var transitionType = _cameraManager.TransitionTypeEnum.INSTANT
	if isAreaLock:
		transitionType = _cameraManager.TransitionTypeEnum.AREA_LOCK
	_cameraManager.limitCameraToDelimiter(delimiter, transitionType)
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
	
func StartupPlayerInPosition(position: Vector2, playFadeTime: float = 0) -> void:
	LevelGlobals.GetPlayerActor().position = position
	if playFadeTime > 0:
		_cameraManager._animationPlayer.playFadeOut(playFadeTime)
	get_tree().paused = false
	
func _on_Player_died():
	_cameraManager._animationPlayer.playFadeIn(5)
