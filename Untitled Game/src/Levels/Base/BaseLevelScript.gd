extends Node

class_name BaseLevelScript

var _cameraManager: CustomCamera2D
var _enteredAreas: Array
var settings

var areaLocked = false;
var currentSpawnersInLockOut: Array
var currentDelimiterForLockOut: CustomDelimiter2D
signal area_lock
signal lockout_finished

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

func LockOutFightStart(delimiterNode: CustomDelimiter2D, enemySpawners):
	if !areaLocked:
		areaLocked = true;
		emit_signal("area_lock", true)
		delimiterNode.ManualTransition_Enter();
		currentSpawnersInLockOut = enemySpawners;
		currentDelimiterForLockOut = delimiterNode;
		NextEnemySpawner();
		
func NextEnemySpawner():
	if areaLocked:
		var spawner = currentSpawnersInLockOut.pop_front()
		if is_instance_valid(spawner):
			spawner.spawn_enemies()
			spawner.connect("AllEnemiesDefeated", self, "NextEnemySpawner")
		else:
			LockOutFightFinish(currentDelimiterForLockOut);
		
func LockOutFightFinish(delimiterNode: CustomDelimiter2D):
	areaLocked = false;
	emit_signal("area_lock", false)
	delimiterNode.ManualTransition_Exit();
	emit_signal("lockout_finished", currentDelimiterForLockOut)

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
	_cameraManager.limitCameraToDelimiter(overlappingDelimiter, _cameraManager.TransitionTypeEnum.SMOOTH)


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
	
func StartupPlayerInPosition(position: Vector2, playFadeTime: float = 0) -> void:
	LevelGlobals.GetPlayerActor().position = position
	if playFadeTime > 0:
		_cameraManager._animationPlayer.playFadeOut(playFadeTime)
	get_tree().paused = false
	
func _on_Player_died():
	_cameraManager._animationPlayer.playFadeIn(5)
	yield(_cameraManager._animationPlayer._player, "animation_finished")
	LevelGlobals.load_checkpoint()
