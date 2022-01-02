extends Node2D

var _player : Actor

const _MENU_EVENT: String = "Menu"
const _UI_CANCEL_EVENT: String = "ui_cancel"

var _menuOpen: bool = false
onready var _gameMenu: PauseMenu = get_node("GUI/PauseMenu")

onready var _textBox: TextBox = $GUI/TextBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = LevelGlobals.GetPlayerActor()
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)

func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/PlayerGui/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()

func _on_InteractPromptArea_interactable_text_signal(text):
	_textBox.showText(text)

# node to handle player input, and call the proper response
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_MENU_EVENT) and !_menuOpen:
		_pauseAndShowMenu()
	elif event.is_action_pressed(_MENU_EVENT) and _menuOpen:
		_unpauseAndHideMenu()


func _pauseAndShowMenu() -> void:
	_menuOpen = true
	get_tree().paused = true
	_gameMenu.visible = true


func _unpauseAndHideMenu():
	_menuOpen = false
	get_tree().paused = false
	_gameMenu.visible = false


func loadRatDemo():
	get_tree().paused = false
	get_tree().change_scene("res://src/Demos/PlaytestDemoWithRats.tscn")


func loadSlimeDemo():
	get_tree().paused = false
	get_tree().change_scene("res://src/Demos/PlaytestDemoFR.tscn")


func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_GoBackButton_pressed():
	_unpauseAndHideMenu()
