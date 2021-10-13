extends Node2D

#onready var _camera = $Camera2D
var _player : Actor
onready var cameraManager: CustomCamera2D

const _INTERACT_EVENT = "interact"

onready var _cam_Delimiter_Bathroom = get_node("LevelBackground/CameraPositions/Bathroom_Delimiter")
onready var _cam_Delimiter_Bedroom = get_node("LevelBackground/CameraPositions/Bedroom_Delimiter")
onready var _cam_Delimiter_StreamingRooom = get_node("LevelBackground/CameraPositions/StreamingRoom_Delimiter")
onready var _cam_Delimiter_LivingRoom = get_node("LevelBackground/CameraPositions/LivingRoom_Delimiter")
onready var _cam_Delimiter_Kitchen = get_node("LevelBackground/CameraPositions/Kitchen_Delimiter")
onready var _cam_Delimiter_Basement = get_node("LevelBackground/CameraPositions/Basement_Delimeter")
onready var _teleport_Basement = get_node("LevelBackground/Basement_Teleport")
onready var _teleport_Kitchen = get_node("LevelBackground/Kitchen_Teleport")
onready var _kitchen_Teleport_Area: Area2D = get_node("LevelBackground/AreaTransitions/Kitchen_To_Basement")
onready var _basement_Teleport_Area: Area2D = get_node("LevelBackground/AreaTransitions/Basement_To_Kitchen")

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
	setCameraToBathroom()
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)
	
	
	
func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/Control/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()

# node to handle player input, and call the proper response
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_INTERACT_EVENT):
		_handleInteractEvent()

# Call when the "Interact" event is called. Will check which area player is in to
# call the proper result
func _handleInteractEvent() -> void:
	if _kitchen_Teleport_Area.overlaps_body(_player):
		setCameraToBasement()
	elif _basement_Teleport_Area.overlaps_body(_player):
		setCameraToKitchenTeleport()

func _on_VisibilityNotifier2D_screen_entered():
	pass
#	cameraManager.panToTarget(get_node("YSort/Actors/Enemy/enemy"), 2)
#	get_node("YSort/Actors/Enemy/VisibilityNotifier2D").queue_free()

func _on_Bedroom_To_Bathroom_body_entered(body):
	if body == _player:
		setCameraToBathroom()

func _on_Bathroom_To_Bedroom_body_entered(body):
	if body == _player:
		setCameraToBedroom()

func _on_Bedroom_To_StreamingRoom_body_entered(body):
	if body == _player:
		setCameraToStreamingRoom()

func _on_StreamingRoom_To_Bedroom_body_entered(body):
	if body == _player:
		setCameraToBedroom()

func _on_Livingroom_To_StreamingRoom_body_entered(body):
	if body == _player:
		setCameraToStreamingRoom()

func _on_StreamingRoom_To_Livingroom_body_entered(body):
	if body == _player:
		setCameraToLivingRoom()

func _on_Kitchen_To_Livingroom_body_entered(body):
	if body == _player:
		setCameraToLivingRoom()

func _on_Livingroom_To_Kitchen_body_entered(body):
	if body == _player:
		setCameraToKitchen()

func setCameraToBathroom():
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_Bathroom) 

func setCameraToBedroom():
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_Bedroom) 

func setCameraToStreamingRoom():
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_StreamingRooom) 

func setCameraToLivingRoom():	
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_LivingRoom) 
	
func setCameraToKitchen():
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_Kitchen) 

func setCameraToBasement() -> void:
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_Basement)
	_player.position = _teleport_Basement.position

func setCameraToKitchenTeleport() -> void:
	setCameraToKitchen()
	_player.position = _teleport_Kitchen.position
