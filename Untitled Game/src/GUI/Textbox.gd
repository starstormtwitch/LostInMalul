extends Control

class_name TextBox

onready var label = $MarginContainer/MarginContainer/Label
onready var animationPlayer = $AnimationPlayer

var isShowing = false
var isAnimating = false

signal closed

# node to handle player input, and call the proper response
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(EventsList.UI_CANCEL_EVENT):
		_handleUICancelEvent()


# Call when the "UI_Cacnel" event is called. will close textboxes if open
func _handleUICancelEvent() -> void:
	if isAnimating:
		animationPlayer.stop()
		label.percent_visible = 1
		isAnimating = false
		get_tree().set_input_as_handled()
	elif isShowing:
		hideText()
		get_tree().set_input_as_handled()


func hideText():
	print("hide text")
	get_tree().paused = false
	self.visible = false
	isShowing = false
	label.text = ""
	emit_signal("closed")


func showText(text: String):
	print("show text")
	if(get_tree() != null):
		get_tree().paused = true
		self.visible = true
		isShowing = true
		isAnimating = true
		label.text = text
		animationPlayer.play("typewriter_effect")


func animationDone():
	isAnimating = false
