extends Node

class_name PauseMenu

signal show_settings
signal debug_settings_changed

onready var pauseMenuContainer: VBoxContainer = $PanelContainer/PauseMenuContainer
onready var exitMenuContainer: VBoxContainer = $PanelContainer/ExitMenuContainer
onready var debugMenuContainer: VBoxContainer = $PanelContainer/DebugMenuContainer
onready var container: PanelContainer = $PanelContainer

enum ShowMenuEnum {NONE = -1, PAUSE = 0, EXIT = 1, DEBUG = 2}

# Called when the node enters the scene tree for the first time.
func _ready():
	_switchMenu(ShowMenuEnum.PAUSE)

func _switchMenu(showMenu: int):
	pauseMenuContainer.visible = showMenu == ShowMenuEnum.PAUSE
	exitMenuContainer.visible = showMenu == ShowMenuEnum.EXIT
	debugMenuContainer.visible = showMenu == ShowMenuEnum.DEBUG
#	container.visible = !(showMenu == ShowMenuEnum.NONE)
	self.visible = !(showMenu == ShowMenuEnum.NONE)


func _on_RestartButton_pressed():
	MusicManager.playLastMusic()
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_ExitButton_pressed():
	_switchMenu(ShowMenuEnum.EXIT)

func _on_LoadSlimeLevelButton_pressed():
	MusicManager.playNormalBattleMusic()
	get_tree().paused = false
	get_tree().change_scene("res://src/Demos/PlaytestDemoFR.tscn")

func _on_LoadRatLevelButton_pressed():
	MusicManager.playNormalBattleMusic()
	get_tree().paused = false
	get_tree().change_scene("res://src/Demos/PlaytestDemoWithRats.tscn")

func _on_SettingsButton_pressed():
	emit_signal("show_settings")

func _on_LoadHouseLevelButton_pressed():
	MusicManager.playNormalBattleMusic()
	get_tree().paused = false
	get_tree().change_scene("res://src/Levels/House.tscn")

func _on_ResumeButton_pressed():	
	_resume()

func _resume():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	MusicManager.playLastMusic()	
	get_tree().paused = false
	_switchMenu(ShowMenuEnum.NONE)

func _on_DebugButton_pressed():
	_switchMenu(ShowMenuEnum.DEBUG)

func _on_VisibilityNotifier2D_draw():
	_switchMenu(ShowMenuEnum.PAUSE)

func _on_ExitMenuResumeButton_pressed():
	_switchMenu(ShowMenuEnum.PAUSE)
	_resume()

func _on_ExitMenuSaveButton_pressed():
	LevelGlobals.save_game()
	var gameScene = LevelGlobals.GetLevelScene("MainMenu");
	assert(gameScene != null, "Unknown level!");
	get_tree().change_scene_to(gameScene);
	_resume()

func _on_ExitMenuExitButton_pressed():
	get_tree().quit()


func _on_OkButton_pressed():
	emit_signal("debug_settings_changed")
	_resume()
