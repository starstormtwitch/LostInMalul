extends Control

class_name PauseMenu

signal start_rat_level
signal start_slime_level

var _menuOpen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func pauseAndShowMenu() -> void:
	_menuOpen = true
	get_tree().paused = true
	self.visible = true

func _unpauseAndHideMenu():
	_menuOpen = false
	get_tree().paused = false
	self.visible = false


func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_LoadSlimeLevelButton_pressed():
	emit_signal("start_slime_level")


func _on_LoadRatLevelButton_pressed():
	emit_signal("start_rat_level")
