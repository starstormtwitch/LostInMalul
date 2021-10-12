extends Node2D

#onready var _camera = $Camera2D
var _player : Actor
onready var cameraManager: CustomCamera2D

onready var _cam_Delimiter_Bathroom = get_node("LevelBackground/CameraPositions/Bathroom_Delimiter")
onready var _cam_Delimiter_Bedroom = get_node("LevelBackground/CameraPositions/Bedroom_Delimiter")
onready var _cam_Delimiter_StreamingRooom = get_node("LevelBackground/CameraPositions/StreamingRoom_Delimiter")
onready var _cam_Delimiter_LivingRoom = get_node("LevelBackground/CameraPositions/LivingRoom_Delimiter")
onready var _cam_Delimiter_Kitchen = get_node("LevelBackground/CameraPositions/Kitchen_Delimiter")

# Called when the node enters the scene tree for the first time.
func _ready():
	var parent = get_parent()
	if(parent != null):
		var tree = parent.get_tree()
		var players = tree.get_nodes_in_group("Player")
		if(players.size() > 0):
			_player = players[0]
	assert(_player, "Player Node does not exist.")
	#assert(_camera, "Camera2D Node does not exist")
	cameraManager = CustomCamera2D.new(_player, true)		
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_Bathroom) 	
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)		

func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/Control/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()

func _on_Bedroom_To_Bathroom_body_entered(body):
	if body == _player:
		cameraManager.limitCameraToDelimiter(_cam_Delimiter_Bathroom, cameraManager.TransitionTypeEnum.INSTANT) #snap

func _on_Bathroom_To_Bedroom_body_entered(body):
	if body == _player:
		cameraManager.limitCameraToDelimiter(_cam_Delimiter_Bedroom, cameraManager.TransitionTypeEnum.INSTANT)  #snap

func _on_Bedroom_To_StreamingRoom_body_entered(body):
	if body == _player:
		cameraManager.limitCameraToDelimiter(_cam_Delimiter_StreamingRooom, cameraManager.TransitionTypeEnum.SMOOTH)  #smooth

func _on_StreamingRoom_To_Bedroom_body_entered(body):
	if body == _player:
		cameraManager.limitCameraToDelimiter(_cam_Delimiter_Bedroom, cameraManager.TransitionTypeEnum.SMOOTH) #smooth

func _on_Livingroom_To_StreamingRoom_body_entered(body):
	if body == _player && !cameraManager.compareCameraLimitIsEqualToDelimiter(_cam_Delimiter_StreamingRooom):
		cameraManager.limitCameraToDelimiter(_cam_Delimiter_StreamingRooom, cameraManager.TransitionTypeEnum.FADE) #fade

func _on_StreamingRoom_To_Livingroom_body_entered(body):
	if body == _player && !cameraManager.compareCameraLimitIsEqualToDelimiter(_cam_Delimiter_LivingRoom):
		cameraManager.limitCameraToDelimiter(_cam_Delimiter_LivingRoom, cameraManager.TransitionTypeEnum.FADE) #fade

func _on_Kitchen_To_Livingroom_body_entered(body):
	if body == _player:
		cameraManager.limitCameraToDelimiter(_cam_Delimiter_LivingRoom) 

func _on_Livingroom_To_Kitchen_body_entered(body):
	if body == _player:
		cameraManager.limitCameraToDelimiter(_cam_Delimiter_Kitchen) 

func _on_VisibilityNotifier2D_viewport_entered(viewport):
	var panTarget = cameraManager.CustomCamera2DPanTarget.new(get_node("VisibilityNotifier2D"), 5)
	cameraManager.panToTarget(panTarget)
	yield(cameraManager, "pan_finished")
	get_node("VisibilityNotifier2D").queue_free()
