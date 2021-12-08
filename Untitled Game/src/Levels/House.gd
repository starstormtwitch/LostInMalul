extends Node2D

#onready var _camera = $Camera2D
var _player : Actor
onready var cameraManager: CustomCamera2D

onready var _cam_Delimiter_Bathroom: CustomDelimiter2D = get_node("LevelBackground/CameraPositions/Bathroom_Delimiter")
onready var _cam_Delimiter_Bedroom: CustomDelimiter2D = get_node("LevelBackground/CameraPositions/Bedroom_Delimiter")
onready var _cam_Delimiter_StreamingRooom: CustomDelimiter2D = get_node("LevelBackground/CameraPositions/StreamingRoom_Delimiter")
onready var _cam_Delimiter_LivingRoom: CustomDelimiter2D = get_node("LevelBackground/CameraPositions/LivingRoom_Delimiter")
onready var _cam_Delimiter_Kitchen: CustomDelimiter2D = get_node("LevelBackground/CameraPositions/Kitchen_Delimiter")
onready var _cam_Delimiter_Basement: CustomDelimiter2D = get_node("LevelBackground/CameraPositions/Basement_Delimeter")
onready var _cam_Delimiter_Foyer: CustomDelimiter2D = get_node("LevelBackground/CameraPositions/Foyer_Delimiter")
onready var _cam_Delimiter_Garage: CustomDelimiter2D = get_node("LevelBackground/CameraPositions/Garage_Delimiter")

onready var _teleport_Basement: Position2D = get_node("LevelBackground/Teleports/Basement_Teleport")
onready var _teleport_Bathroom: Position2D = get_node("LevelBackground/Teleports/Bathroom_Exit_Teleport")
onready var _teleport_Kitchen_Basement_Door: Position2D = get_node("LevelBackground/Teleports/Kitchen_Basement_Door_Teleport")
onready var _teleport_Bedroom_Entrance: Position2D = get_node("LevelBackground/Teleports/Bedroom_Entrance_Teleport")
onready var _teleport_Bedroom_Exit: Position2D = get_node("LevelBackground/Teleports/Bedroom_Exit_Teleport")
onready var _teleport_StreamRoom_Entrance: Position2D = get_node("LevelBackground/Teleports/Streaming_Entrance_Teleport")
onready var _teleport_StreamRoom_Exit: Position2D = get_node("LevelBackground/Teleports/Streaming_Exit_Teleport")
onready var _teleport_LivingRoom_Entrance: Position2D = get_node("LevelBackground/Teleports/LivingRoom_Entrance_Teleport")
onready var _teleport_LivingRoom_Exit: Position2D = get_node("LevelBackground/Teleports/LivingRoom_Exit_Teleport")
onready var _teleport_Kitchen_Entrance: Position2D = get_node("LevelBackground/Teleports/Kitchen_Entrance_Teleport")
onready var _teleport_Kitchen_Exit: Position2D = get_node("LevelBackground/Teleports/Kitchen_Exit_Teleport")
onready var _teleport_Foyer_Entrance: Position2D = get_node("LevelBackground/Teleports/Foyer_Entrance_Teleport")
onready var _teleport_Foyer_Garage_Door: Position2D = get_node("LevelBackground/Teleports/Foyer_Garage_Door_Teleport")
onready var _teleport_Garage_Entrance: Position2D = get_node("LevelBackground/Teleports/Garage_Teleport")

onready var _kitchen_Teleport_Area: Area2D = get_node("LevelBackground/AreaTransitions/Kitchen_To_Basement")
onready var _basement_Teleport_Area: Area2D = get_node("LevelBackground/AreaTransitions/Basement_To_Kitchen")
onready var _foyer_Teleport_Area: Area2D = get_node("LevelBackground/AreaTransitions/Foyer_To_Garage")
onready var _garage_Teleport_Area: Area2D = get_node("LevelBackground/AreaTransitions/Garage_To_Foyer")

onready var _textBox: TextBox = $GUI/TextBox

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

# node to handle player input, and call the proper response
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(EventsList.UI_CANCEL_EVENT):
		_handleUICancelEvent()
	elif event.is_action_pressed(EventsList.INTERACT_EVENT):
		_handleInteractEvent()

# Call when the "Interact" event is called. Will check which area player is in to
# call the proper result
func _handleInteractEvent() -> void:
	if _kitchen_Teleport_Area.overlaps_body(_player):
		setCameraToBasement()
	elif _basement_Teleport_Area.overlaps_body(_player):
		setCameraToKitchenTeleport()
	elif _foyer_Teleport_Area.overlaps_body(_player):
		setCameraToGarage()
	elif _garage_Teleport_Area.overlaps_body(_player):
		setCameraToFoyerTeleport()

# Call when the "UI_Cacnel" event is called. will close textboxes if open
func _handleUICancelEvent() -> void:
	if _textBox.isShowing:
		_hideTextBox()

func _hideTextBox(): 
	_textBox.hideText()
	get_tree().set_input_as_handled()

func _on_VisibilityNotifier2D_screen_entered():
	pass
#	cameraManager.panToTarget(get_node("YSort/Actors/Enemy/enemy"), 2)
#	get_node("YSort/Actors/Enemy/VisibilityNotifier2D").queue_free()

func _on_Bedroom_To_Bathroom_body_entered(body):
	if body == _player:
		setCameraToBathroom()
		_player.position = _teleport_Bathroom.position

func _on_Bathroom_To_Bedroom_body_entered(body):
	if body == _player:
		setCameraToBedroom()
		_player.position = _teleport_Bedroom_Entrance.position

func _on_Bedroom_To_StreamingRoom_body_entered(body):
	if body == _player:
		setCameraToStreamingRoom()
		_player.position = _teleport_StreamRoom_Entrance.position

func _on_StreamingRoom_To_Bedroom_body_entered(body):
	if body == _player:
		setCameraToBedroom()
		_player.position = _teleport_Bedroom_Exit.position

func _on_Livingroom_To_StreamingRoom_body_entered(body):
	if body == _player:
		setCameraToStreamingRoom()
		_player.position = _teleport_StreamRoom_Exit.position

func _on_StreamingRoom_To_Livingroom_body_entered(body):
	if body == _player:
		setCameraToLivingRoom()
		_player.position = _teleport_LivingRoom_Entrance.position

func _on_Kitchen_To_Livingroom_body_entered(body):
	if body == _player:
		setCameraToLivingRoom()
		_player.position = _teleport_LivingRoom_Exit.position

func _on_Livingroom_To_Kitchen_body_entered(body):
	if body == _player:
		setCameraToKitchen()
		_player.position = _teleport_Kitchen_Entrance.position
		
func _on_Kitchen_To_Foyer_body_entered(body):
	if body == _player:
		setCameraToFoyer()
		_player.position = _teleport_Foyer_Entrance.position

func _on_Foyer_To_Kitchen_body_entered(body):
	if body == _player:
		setCameraToKitchen()
		_player.position = _teleport_Kitchen_Exit.position

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

func setCameraToFoyer():
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_Foyer) 

func setCameraToBasement() -> void:
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_Basement)
	_player.position = _teleport_Basement.position

func setCameraToKitchenTeleport() -> void:
	setCameraToKitchen()
	_player.position = _teleport_Kitchen_Basement_Door.position

func setCameraToGarage() -> void:
	cameraManager.limitCameraToDelimiter(_cam_Delimiter_Garage)
	_player.position = _teleport_Garage_Entrance.position

func setCameraToFoyerTeleport() -> void:
	setCameraToFoyer()
	_player.position = _teleport_Foyer_Garage_Door.position

func _on_InteractPromptArea_interactable_text_signal(text):
	_textBox.showText(text)
