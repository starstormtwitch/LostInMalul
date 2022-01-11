extends Control

class_name PauseMenu

signal show_settings

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_RestartButton_pressed():
	MusicManager.playNormalBattleMusic()
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_ExitButton_pressed():
	get_tree().quit()


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


func _on_GoBackButton_pressed():
	MusicManager.playNormalBattleMusic()
	get_tree().paused = false
	self.visible = false
