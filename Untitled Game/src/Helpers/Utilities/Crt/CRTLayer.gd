extends Control

class_name CRTLayer

var settings = Settings.new()

onready var crtEffect: TextureRect = $CRTEffect
onready var crtFrame: TextureRect = $CRTFrame


func _ready():
	settings.connectNodeToSettingsChangedSignal(self, "_checkCrtValues")
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
