extends Control

var mainMenu : PackedScene = preload("res://src/Levels/Menu/MainMenu.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)  
	MusicManager.playRatKingBossMusic()

func StartHit():
	get_tree().change_scene_to(mainMenu);

func _input(event) -> void:
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_ENTER or  event.scancode == KEY_KP_ENTER :
			StartHit();
