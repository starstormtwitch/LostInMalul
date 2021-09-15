extends Node2D

var _LABEL_POSITION_OFFSET = 100

var _startCountDown = 5
var _timerOn = false

onready var camera = $Camera2D
onready var player = $LirikYaki
onready var firstLockArea = $FirstRoomLockArea
onready var label = $CanvasLayer/Label
onready var leftFirstRoomCollider = $FirstRoomBattleBoundary/LeftSide
onready var rightFirstRoomCollider = $FirstRoomBattleBoundary/RightSide

onready var cameraManager: CameraManager
var firstArenaManager: ArenaRoomManager 


# Called when the node enters the scene tree for the first time.
func _ready():
	cameraManager = CameraManager.new(player, camera)
	var array = [leftFirstRoomCollider, rightFirstRoomCollider]
	firstArenaManager = ArenaRoomManager.new(cameraManager, firstLockArea, array, label)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cameraManager.followPlayerIfUnlocked()
	firstArenaManager.handleTimeUpdate(delta)


# Event when hitting the First Room lock area, will lock camera, and player to that area
func _on_FirstRoomLockArea_area_entered(area):
	print("first collision detect: " + area.name)
	# I use players position to lock the camera to, but it might be better to define
	# an actual space on the map/scene
	firstArenaManager.initiateRoomBattle(player.position)
