extends Control

class_name TextBox

onready var label = $MarginContainer/MarginContainer/Label

var isShowing = false

func hideText():
	print("hide text")
	get_tree().paused = false
	self.visible = false
	isShowing = false
	label.text = ""


func showText(text: String):
	print("show text")
	get_tree().paused = true
	self.visible = true
	isShowing = true
	label.text = text
