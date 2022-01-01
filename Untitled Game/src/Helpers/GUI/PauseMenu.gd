extends Control

class_name PauseMenu

const _MENU_EVENT: String = "Menu"

signal show_settings
signal menu_hidden

var _menuOpen = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# node to handle player input, and call the proper response
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_MENU_EVENT) and !_menuOpen:
		pauseAndShowMenu()
	elif event.is_action_pressed(_MENU_EVENT) and _menuOpen:
		_unpauseAndHideMenu()

func pauseAndShowMenu() -> void:
	_menuOpen = true
	get_tree().paused = true
	self.visible = true

func _unpauseAndHideMenu():
	_menuOpen = false
	get_tree().paused = false
	self.visible = false
	emit_signal("menu_hidden")


func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_LoadSlimeLevelButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://src/Demos/PlaytestDemoFR.tscn")


func _on_LoadRatLevelButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://src/Demos/PlaytestDemoWithRats.tscn")


func _on_SettingsButton_pressed():
	emit_signal("show_settings")


func _on_LoadHouseLevelButton_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://src/Levels/House.tscn")
