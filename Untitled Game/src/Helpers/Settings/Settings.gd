extends Control

class_name Settings

const SETTINGS_DATA_PATH: String = "res://addons/GGS/settings_data.json"
const SETTINGS_SAVE_PATH: String = "user://settings_data.json"

#class in charge of the getting specific setting values, that are handled by 
# Godot Game Settings (GGS) plugin. Most of the code will work of of the
# settings_data dictionary in the ggs_manager class that should be autoloaded.

static func load_game_settings() -> GameSettings:
	var settings = ggsManager.settings_data
	var infiniteHealth = settings["3"]["current"]["value"]
	return GameSettings.new(infiniteHealth)

static func load_screen_shake_settings() -> ScreenShakeSettings:
	var settings = ggsManager.settings_data
	var duration = settings["0"]["current"]["value"]
	var frequency = settings["1"]["current"]["value"]
	var amplitude = settings["2"]["current"]["value"]
	
	#print("values found are: " + String(duration) + " " + String(frequency) + " " + String(amplitude))
	return ScreenShakeSettings.new(duration, frequency, amplitude)
