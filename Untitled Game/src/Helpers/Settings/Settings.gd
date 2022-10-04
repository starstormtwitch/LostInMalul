extends Control

class_name Settings

const SETTINGS_DATA_PATH: String = "res://addons/GGS/settings_data.json"
const SETTINGS_SAVE_PATH: String = "user://settings_data.json"

var _parent: Node
var _functionName: String = ""

#class in charge of the getting specific setting values, that are handled by 
# Godot Game Settings (GGS) plugin. Most of the code will work of of the
# settings_data dictionary in the ggs_manager class that should be autoloaded.
#
# Class is also capable of taking taking its a parent node when instantiated and
# connecting it to the settings_changed signal found in 
# res://src/Helpers/GUI/Settings/SettingsMenu.gd

func connectNodeToSettingsChangedSignal(node: Node, functionName: String):
	var parent = node.get_parent()
	assert(parent, "No parent found. Needed to connect to signals.")
	
	var tree = parent.get_tree()
	var settings = tree.get_nodes_in_group("Settings")
	
	assert(settings.size() > 0, "No node in Settings group in parent tree. Needed to connect to signals.")
	var _settings = settings[0]
	print("Connecting settings signal to " + node.get_name())
	_settings.connect("settings_changed", node, functionName)


func connectNodeToDebugSettingsChangedSignal(node: Node, functionName: String):
	var parent = node.get_parent()
	assert(parent, "No parent found. Needed to connect to signals.")
	
	var tree = parent.get_tree()
	var settings = tree.get_nodes_in_group("DebugSettings")
	
	assert(settings.size() > 0, "No node in DebugSettings group in parent tree. Needed to connect to signals.")
	var _settings = settings[0]
	print("Connecting debug settings signal to" + node.get_name())
	_settings.connect("debug_settings_changed", node, functionName)


static func load_game_settings() -> GameSettings:
	var settings = ggsManager.settings_data
	var infiniteHealth = settings["3"]["current"]["value"]
	var infiniteDamage = settings["12"]["current"]["value"]
	return GameSettings.new(false, false)


static func GetScreenShakeDuration() -> float:
	return ggsManager.settings_data["0"]["current"]["value"]


static func GetScreenShakeFrecuency() -> float:
	return ggsManager.settings_data["1"]["current"]["value"]


static func GetScreenShakeAmplitude() -> float:
	return ggsManager.settings_data["2"]["current"]["value"]


static func GetScreenShakeIntensity() -> float:
	return ggsManager.settings_data["4"]["current"]["value"]


static func getCRTEnableValue() -> bool:
	return ggsManager.settings_data["13"]["current"]["value"]
