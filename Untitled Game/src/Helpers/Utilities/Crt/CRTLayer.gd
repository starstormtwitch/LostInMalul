extends Control

class_name CRTLayer

onready var crtEffect: TextureRect = $CRTEffect
onready var crtFrame: TextureRect = $CRTFrame


func _ready():
	_connect_to_settings_changed_signal()
	_checkCrtValues()


func _hideCRT():
	crtFrame.visible = false
	crtEffect.visible = false


func _showCRT():
	crtFrame.visible = false
	crtEffect.visible = true


func _checkCrtValues():
	if Settings.getCRTEnableValue():
		_showCRT()
	else:
		_hideCRT()


func _connect_to_settings_changed_signal():
	var parent = get_parent()
	assert(parent, "No parent found. Needed to connect to signals.")
	
	var tree = parent.get_tree()
	var settings = tree.get_nodes_in_group("Settings")
	
	assert(settings.size() > 0, "No node in Settings group in parent tree. Needed to connect to signals.")
	var _settings = settings[0]
	print("Connecting settings signal to camera2d")
	_settings.connect("settings_changed", self, "_checkCrtValues")
