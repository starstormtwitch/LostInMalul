extends Control

class_name SettingsMenu

signal settings_changed

onready var gameplayContainer: GridContainer = $PanelContainer/GridContainer/VBoxContainer/GameplayGrid
onready var graphicsContainer: GridContainer = $PanelContainer/GridContainer/VBoxContainer/GraphicsGrid
onready var audioContainer: GridContainer = $PanelContainer/GridContainer/VBoxContainer/AudioGrid
onready var controlsContainer: GridContainer = $PanelContainer/GridContainer/VBoxContainer/ControlsGrid

onready var gameplayButton: Button = $PanelContainer/GridContainer/VBoxContainer/NavigationContainer/OptionList/GameplayLabel
onready var graphicsButton: Button = $PanelContainer/GridContainer/VBoxContainer/NavigationContainer/OptionList/GraphicsLabel
onready var audioButton: Button = $PanelContainer/GridContainer/VBoxContainer/NavigationContainer/OptionList/AudioLabel
onready var controlsButton: Button = $PanelContainer/GridContainer/VBoxContainer/NavigationContainer/OptionList/ControlLabel

enum ShowMenuEnum {GAMEPLAY = 0, GRAPHICS = 1, AUDIO = 2, CONTROLS = 3}
onready var maxMenuOptionValue: int = ShowMenuEnum.size() - 1
var currentMenu: int = 0

func _ready():
	_switchMenu(ShowMenuEnum.GAMEPLAY)
	
func _input(ev):
	if ev is InputEventKey:
		if ev.is_pressed() && ev.scancode == KEY_Q && currentMenu > 0:
			_switchMenu(currentMenu - 1)
		elif ev.is_pressed() && ev.scancode == KEY_E && currentMenu < maxMenuOptionValue:
			_switchMenu(currentMenu + 1)
	
func _switchMenu(showMenuValue: int):
	_updateButtonPressed(showMenuValue)
	gameplayContainer.visible = showMenuValue == ShowMenuEnum.GAMEPLAY
	graphicsContainer.visible = showMenuValue == ShowMenuEnum.GRAPHICS
	audioContainer.visible = showMenuValue == ShowMenuEnum.AUDIO
	controlsContainer.visible = showMenuValue == ShowMenuEnum.CONTROLS
	currentMenu = showMenuValue

func _updateButtonPressed(showMenuValue: int):
	gameplayButton.pressed = showMenuValue == ShowMenuEnum.GAMEPLAY
	graphicsButton.pressed = showMenuValue == ShowMenuEnum.GRAPHICS
	audioButton.pressed = showMenuValue == ShowMenuEnum.AUDIO
	controlsButton.pressed = showMenuValue == ShowMenuEnum.CONTROLS

func _on_OkButton_pressed():
	self.visible = false
	emit_signal("settings_changed")

func show_settings():
	self.visible = true

func _on_GameplayLabel_toggled(button_pressed):
	if button_pressed:
		_switchMenu(ShowMenuEnum.GAMEPLAY)

func _on_GraphicsLabel_toggled(button_pressed):
	if button_pressed:
		_switchMenu(ShowMenuEnum.GRAPHICS)

func _on_AudioLabel_toggled(button_pressed):
	if button_pressed:
		_switchMenu(ShowMenuEnum.AUDIO)

func _on_ControlLabel_toggled(button_pressed):
	if button_pressed:
		_switchMenu(ShowMenuEnum.CONTROLS)
