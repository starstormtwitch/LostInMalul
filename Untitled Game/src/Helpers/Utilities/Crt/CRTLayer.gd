extends Control

class_name CRTLayer

onready var crtEffect: TextureRect = $CRTEffect
onready var crtFrame: TextureRect = $CRTFrame

func hideCRT():
	crtFrame.visible = false
	crtEffect.visible = false

func showCRT():
	crtFrame.visible = true
	crtEffect.visible = true
