extends Control


# This classs in charge of handling all stuff do with the pause screen.
# Mostly handles communication between all the pause menu UI like main pause menu
# and settings menu UI

signal settings_changed

const _MENU_EVENT: String = "Menu"

var _menuOpen = false

onready var settings_menu: SettingsMenu = $SettingsMenu
onready var pause_menu: PauseMenu = $PauseMenu

func _ready():
	pass

func signalConnectionSetup():
	pass

# node to handle player input, and call the proper response
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_MENU_EVENT) and !_menuOpen:
		pauseAndShowMenu()
	elif event.is_action_pressed(_MENU_EVENT) and _menuOpen:
		_unpauseAndHideMenu()

func pauseAndShowMenu() -> void:
	MusicManager.playMenuMusic()
	_menuOpen = true
	get_tree().paused = true
	pause_menu.visible = true

func _unpauseAndHideMenu():
	MusicManager.playNormalBattleMusic()
	_menuOpen = false
	get_tree().paused = false
	pause_menu.visible = false


func _on_show_settings():
	pause_menu.visible = false
	settings_menu.visible = true


func _on_settings_changed():
	emit_signal("settings_changed")
	settings_menu.visible = false
	pause_menu.visible = true
	
