extends Control

class_name SettingsMenu

signal settings_changed

onready var graphicsContainer: Container = $PanelContainer/GridContainer/VBoxContainer/GraphicsGrid
onready var audioContainer: Container = $PanelContainer/GridContainer/VBoxContainer/AudioGrid
onready var controlMappingContainer: Container = $PanelContainer/GridContainer/VBoxContainer/ControlMappingGridContainer
onready var advancedContainer: Container = $PanelContainer/GridContainer/VBoxContainer/AdvancedGridContainer

onready var graphicsButton: Button = $PanelContainer/GridContainer/VBoxContainer/NavigationContainer/MenuNavigationList/GraphicsLabel
onready var audioButton: Button = $PanelContainer/GridContainer/VBoxContainer/NavigationContainer/MenuNavigationList/AudioLabel
onready var controlsButton: Button = $PanelContainer/GridContainer/VBoxContainer/NavigationContainer/MenuNavigationList/ControlLabel
onready var advancedButton: Button = $PanelContainer/GridContainer/VBoxContainer/NavigationContainer/MenuNavigationList/AdvancedLabel

onready var buttonInUseDialog: AcceptDialog = $ButtonInUseDialog
onready var confirmMappingResetDialog: ConfirmationDialog = $ConfirmationDialog

enum ShowMenuEnum {GRAPHICS = 0, AUDIO = 1, CONTROLS = 2, ADVANCED = 3}
onready var maxMenuOptionValue: int = ShowMenuEnum.size() - 1
var currentMenu: int = 0
var allowKeyboardNavigation: bool = true

func _ready():
	_switchMenu(ShowMenuEnum.GRAPHICS)
	buttonInUseDialog.get_close_button().visible = false
	#editor anchor for dialog resets randomly... set anchors in code
	buttonInUseDialog.anchor_top = 0.5
	buttonInUseDialog.anchor_bottom = 0.5
	buttonInUseDialog.anchor_left = 0.5
	buttonInUseDialog.anchor_right = 0.5
	confirmMappingResetDialog.anchor_top = 0.5
	confirmMappingResetDialog.anchor_bottom = 0.5
	confirmMappingResetDialog.anchor_left = 0.5
	confirmMappingResetDialog.anchor_right = 0.5	

func _input(ev):
	if allowKeyboardNavigation && ev is InputEventKey:
		if ev.is_pressed() && ev.scancode == KEY_Q && currentMenu > 0:
			_switchMenu(currentMenu - 1)
		elif ev.is_pressed() && ev.scancode == KEY_E && currentMenu < maxMenuOptionValue:
			_switchMenu(currentMenu + 1)


func _switchMenu(showMenuValue: int):
	graphicsContainer.visible = showMenuValue == ShowMenuEnum.GRAPHICS
	audioContainer.visible = showMenuValue == ShowMenuEnum.AUDIO
	controlMappingContainer.visible = showMenuValue == ShowMenuEnum.CONTROLS
	advancedContainer.visible = showMenuValue == ShowMenuEnum.ADVANCED
	_updateButtonPressed(showMenuValue)
	currentMenu = showMenuValue

func _updateButtonPressed(showMenuValue: int):
	graphicsButton.pressed = showMenuValue == ShowMenuEnum.GRAPHICS
	audioButton.pressed = showMenuValue == ShowMenuEnum.AUDIO
	controlsButton.pressed = showMenuValue == ShowMenuEnum.CONTROLS
	advancedButton.pressed = showMenuValue == ShowMenuEnum.ADVANCED

func _on_OkButton_pressed():
	self.visible = false
	emit_signal("settings_changed")

func show_settings():
	self.visible = true

func _on_GraphicsLabel_toggled(button_pressed):
	pass
	if button_pressed:
		_switchMenu(ShowMenuEnum.GRAPHICS)

func _on_AudioLabel_toggled(button_pressed):
	if button_pressed:
		_switchMenu(ShowMenuEnum.AUDIO)

func _on_ControlLabel_toggled(button_pressed):
	if button_pressed:
		_switchMenu(ShowMenuEnum.CONTROLS)

func _on_AdvancedLabel_toggled(button_pressed):
	if button_pressed:
		_switchMenu(ShowMenuEnum.ADVANCED)


func _on_ControlMappingGridContainer_remap_open():
	allowKeyboardNavigation = false

func _on_ControlMappingGridContainer_remap_closed():
	allowKeyboardNavigation = true

func _on_ControlMappingGridContainer_remap_keyInUse():
	buttonInUseDialog.show()

func _on_ControlMappingGridContainer_remap_resetRequest():
	confirmMappingResetDialog.show()

func _on_ConfirmationDialog_confirmed():
	InputFunctions.ResetInputMapping()
	controlMappingContainer.RefreshControls()
