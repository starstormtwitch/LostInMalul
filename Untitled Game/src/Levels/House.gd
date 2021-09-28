extends Node2D

#onready var _camera = $Camera2D
onready var _player = get_node("YSort/Actors/LirikYaki")

onready var cameraManager: CustomCamera2D

onready var _camPos_Bathroom_TopLeft = get_node("LevelBackground/CameraPositions/Bathroom_Top_Left")
onready var _camPos_Bathroom_BottomRight = get_node("LevelBackground/CameraPositions/Bathroom_Bottom_Right")
onready var _camPos_Bedroom_TopLeft = get_node("LevelBackground/CameraPositions/Bedroom_Top_Left")
onready var _camPos_Bedroom_BottomRight = get_node("LevelBackground/CameraPositions/Bedroom_Bottom_Right")
onready var _camPos_Studio_TopLeft = get_node("LevelBackground/CameraPositions/Studio_Top_Left")
onready var _camPos_Studio_BottomRight = get_node("LevelBackground/CameraPositions/Studio_Bottom_Right")

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(_player, "Player Node does not exist.")
	#assert(_camera, "Camera2D Node does not exist")
	cameraManager = CustomCamera2D.new(_player, true)		
	setCameraToBathroom()

func _on_Transition_Bedroom_To_Bathroom_body_entered(body):
	if body == _player:
		setCameraToBathroom()

func _on_Transition_Bathroom_To_Bedroom_body_entered(body):
	if body == _player:
		setCameraToBedroom()

func _on_Bedroom_To_Studio_body_entered(body):
	if body == _player:
		setCameraToStudio()

func _on_Studio_To_Bedroom_body_entered(body):
	if body == _player:
		setCameraToBedroom()

func setCameraToBathroom():
	cameraManager.limitCameraToPositions(_camPos_Bathroom_TopLeft, _camPos_Bathroom_BottomRight) 

func setCameraToBedroom():
	cameraManager.limitCameraToPositions(_camPos_Bedroom_TopLeft, _camPos_Bedroom_BottomRight) 

func setCameraToStudio():
	cameraManager.limitCameraToPositions(_camPos_Studio_TopLeft, _camPos_Studio_BottomRight) 

func _on_VisibilityNotifier2D_screen_entered():
	cameraManager.panToTarget(get_node("YSort/Actors/Enemy/enemy"), 2)
	get_node("YSort/Actors/Enemy/VisibilityNotifier2D").queue_free()
