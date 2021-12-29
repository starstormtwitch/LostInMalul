extends Control

class_name TextBox

onready var label = $MarginContainer/MarginContainer/Label

var isShowing = false

# node to handle player input, and call the proper response
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(EventsList.UI_CANCEL_EVENT):
		_handleUICancelEvent()


# Call when the "UI_Cacnel" event is called. will close textboxes if open
func _handleUICancelEvent() -> void:
	if isShowing:
		hideText()
		get_tree().set_input_as_handled()


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
