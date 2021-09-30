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
	setCameraToBathroom()

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




