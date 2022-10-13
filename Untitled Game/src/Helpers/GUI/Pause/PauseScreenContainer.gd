extends Control


# This classs in charge of handling all stuff do with the pause screen.
# Mostly handles communication between all the pause menu UI like main pause menu
# and settings menu UI

signal settings_changed

const _MENU_EVENT: String = "Menu"

var _menuOpen = false
var _dontOpenMenu = false # mostly used for when player is dying and screen goes black

onready var pause_menu: PauseMenu = $PauseMenu
onready var settings_menu: SettingsMenu = $SettingsMenu

enum ShowMenuEnum {NONE = -1, PAUSE = 0, SETTINGS = 1}

func _ready():
	_switchMenu(ShowMenuEnum.NONE)
	self.visible = true

func signalConnectionSetup():
	pass
	
func _switchMenu(showMenu: int):
	pause_menu.visible = showMenu == ShowMenuEnum.PAUSE
	settings_menu.visible = showMenu == ShowMenuEnum.SETTINGS

# node to handle player input, and call the proper response
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_MENU_EVENT) and !_isMenuOpen() and !_dontOpenMenu:
		_pauseAndShowMenu()
	elif event.is_action_pressed(_MENU_EVENT) and _isMenuOpen() and !_dontOpenMenu:
		_unpauseAndHideMenu()

func _pauseAndShowMenu() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	MusicManager.playMenuMusic()
	_menuOpen = true
	get_tree().paused = true
	_switchMenu(ShowMenuEnum.PAUSE)

func _unpauseAndHideMenu():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	MusicManager.playLastMusic()
	_menuOpen = false
	get_tree().paused = false
	_switchMenu(ShowMenuEnum.NONE)

func _on_show_settings():
	_switchMenu(ShowMenuEnum.SETTINGS)

func _on_settings_changed():
	emit_signal("settings_changed")
	_switchMenu(ShowMenuEnum.PAUSE)

func _isMenuOpen() -> bool:
	return pause_menu.visible || settings_menu.visible


func _on_player_died():
	_dontOpenMenu = true
