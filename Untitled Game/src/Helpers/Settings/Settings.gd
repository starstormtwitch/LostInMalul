extends Control

class_name Settings

const SETTINGS_DATA_PATH: String = "res://addons/GGS/settings_data.json"
const SETTINGS_SAVE_PATH: String = "user://settings_data.json"

#class in charge of the getting setting values, that are handled by 
# Godot Game Settings (GGS) plugin. Most of the code here will be static 
# version of the logic that is contained in the ggs_manager.gd


#static version of the function in the ggs_manager
static func load_settings_data() -> Dictionary:
	var file: File = File.new()
	if OS.is_debug_build():
		if file.file_exists(SETTINGS_DATA_PATH):
			return GGSUtils.load_json(SETTINGS_DATA_PATH)
		else:
			printerr("GGS - returning empty settings, doesnt exist yet")
			return {} #return empty settings
	else:
		if file.file_exists(SETTINGS_SAVE_PATH):
			return GGSUtils.load_json(SETTINGS_SAVE_PATH)
		elif file.file_exists(SETTINGS_DATA_PATH):
			return GGSUtils.load_json(SETTINGS_DATA_PATH)
		else:
			printerr("GGS - Load Data: Failed to load settings data.")
			return {} #return empty settings


static func load_screen_shake_settings() -> ScreenShakeSettings:
	var settings = load_settings_data()
	var duration = settings["0"]["current"]["value"]
	var frequency = settings["1"]["current"]["value"]
	var amplitude = settings["2"]["current"]["value"]
	
	#print("values found are: " + String(duration) + " " + String(frequency) + " " + String(amplitude))
	return ScreenShakeSettings.new(duration, frequency, amplitude)
