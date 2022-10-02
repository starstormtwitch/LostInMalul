extends Node2D

class_name MainMenu

onready var settingsMenu: SettingsMenu = $CanvasLayer/CenterContainer/SettingsMenu
onready var menuContainer: PanelContainer = $CanvasLayer/CenterContainer/MainMenuContainer

signal show_settings

func _init():
	pass

func _ready():
	#center MainMenu node to viewport
#	var x = self.get_viewport().get_visible_rect().size.x / 2
#	var y = self.get_viewport().get_visible_rect().size.y / 2
#	self.position = Vector2(x,y);
	
	MusicManager.playRatKingBossMusic()
	settingsMenu.connect("hide", self, "_show_menu")
	
#	$VBoxContainer.modulate = Color(0.0, 100.0, 0.0, 1.0);
#	$VBoxContainer/TextureRect.modulate = Color(0.0, 100.0, 0.0, 1.0);

func _on_NewGameButton_pressed():
	#todo: ADD ARE YOU SURE YOU WISH TO START NEW GAME IF SAVE DATA FOUND.
	LevelGlobals.new_game();

func _on_LoadGameButton_pressed():
	LevelGlobals.load_game();

func _on_OptionsButton_pressed():
	menuContainer.hide()
	settingsMenu.show()
	
func _on_ExitButton_pressed():
	get_tree().quit()

func _show_menu():
	menuContainer.show()
