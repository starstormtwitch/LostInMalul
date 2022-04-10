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

static func GetScreenShakeDuration() -> float:
	return ggsManager.settings_data["0"]["current"]["value"]

static func GetScreenShakeFrecuency() -> float:
	return ggsManager.settings_data["1"]["current"]["value"]

static func GetScreenShakeAmplitude() -> float:
	return ggsManager.settings_data["2"]["current"]["value"]

static func GetScreenShakeIntensity() -> float:
	return ggsManager.settings_data["4"]["current"]["value"]

static func GetCustomMapping(action, inputType) -> InputEventKey:
	var data: Dictionary = GetCustomMappingData()
	if !data.has(action) || !data[action].has(inputType):
		return null
	var key = data[action][inputType]
	var inputEvent = InputEventKey.new()
	inputEvent.set_scancode(OS.find_scancode_from_string(key))
	return inputEvent

static func SaveCustomMapping(action, event, inputType):
	var data: Dictionary = GetCustomMappingData()
	if !data.has(action):
		data[action] = {}
	data[action][inputType] = OS.get_scancode_string(event.scancode)
	SaveCustomMappingData(data)

static func GetCustomMappingData() -> Dictionary:
	var data = ggsManager.settings_data["11"]["current"]["value"]
	if data == null:
		data = {}
	return data

static func SaveCustomMappingData(data) -> void:
	ggsManager.settings_data["11"]["current"]["value"] = data
	ggsManager.save_settings_data()

static func LoadCustomMappings() -> void:
	var data: Dictionary = GetCustomMappingData()
	print(data)
	for actionName in data.keys():
		InputMap.action_erase_events(actionName)
		for inputType in data[actionName]:
			var inputEvent = InputEventKey.new()
			inputEvent.set_scancode(OS.find_scancode_from_string(data[actionName][inputType]))
			InputMap.action_add_event(actionName, inputEvent)
