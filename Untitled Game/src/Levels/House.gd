extends Node2D

#onready var _camera = $Camera2D
onready var _player = get_node("YSort/Actors/LirikYaki")

onready var cameraManager: CustomCamera2D

onready var _camPos_Bathroom_TopLeft = get_node("LevelBackground/CameraPositions/Bathroom_Top_Left")
onready var _camPos_Bathroom_BottomRight = get_node("LevelBackground/CameraPositions/Bathroom_Bottom_Right")
onready var _camPos_Bedroom_TopLeft = get_node("LevelBackground/CameraPositions/Bedroom_Top_Left")
onready var _camPos_Bedroom_BottomRight = get_node("LevelBackground/CameraPositions/Bedroom_Bottom_Right")
onready var _camPos_StreamingRoom_TopLeft = get_node("LevelBackground/CameraPositions/StreamingRoom_Top_Left")
onready var _camPos_StreamingRoom_BottomRight = get_node("LevelBackground/CameraPositions/StreamingRoom_Bottom_Right")
onready var _camPos_LivingRoom_TopLeft = get_node("LevelBackground/CameraPositions/LivingRoom_Top_Left")
onready var _camPos_LivingRoom_BottomRight = get_node("LevelBackground/CameraPositions/LivingRoom_Bottom_Right")
onready var _camPos_Kitchen_TopLeft = get_node("LevelBackground/CameraPositions/Kitchen_Top_Left")
onready var _camPos_Kitchen_BottomRight = get_node("LevelBackground/CameraPositions/Kitchen_Bottom_Right")

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(_player, "Player Node does not exist.")
	#assert(_camera, "Camera2D Node does not exist")
	cameraManager = CustomCamera2D.new(_player, true)		
	setCameraToBathroom()

func _on_VisibilityNotifier2D_screen_entered():
	cameraManager.panToTarget(get_node("YSort/Actors/Enemy/enemy"), 2)
	get_node("YSort/Actors/Enemy/VisibilityNotifier2D").queue_free()

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
	cameraManager.limitCameraToPositions(_camPos_Bathroom_TopLeft, _camPos_Bathroom_BottomRight) 

func setCameraToBedroom():
	cameraManager.limitCameraToPositions(_camPos_Bedroom_TopLeft, _camPos_Bedroom_BottomRight) 

func setCameraToStreamingRoom():
	cameraManager.limitCameraToPositions(_camPos_StreamingRoom_TopLeft, _camPos_StreamingRoom_BottomRight) 

func setCameraToLivingRoom():	
	cameraManager.limitCameraToPositions(_camPos_LivingRoom_TopLeft, _camPos_LivingRoom_BottomRight) 
	
func setCameraToKitchen():
	cameraManager.limitCameraToPositions(_camPos_Kitchen_TopLeft, _camPos_Kitchen_BottomRight) 




