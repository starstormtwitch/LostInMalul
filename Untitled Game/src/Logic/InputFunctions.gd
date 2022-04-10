extends Node

class_name InputFunctions

func _ready():
	pass # Replace with function body.

static func GetInputEventAsText(event: InputEvent) -> String:
	if event.get_class() == "InputEventMouseButton":
		return MouseButtonIndexToText(event.button_index)
	return event.as_text()

static func MouseButtonIndexToText(index: int) -> String:
	if index == BUTTON_LEFT || index == BUTTON_MASK_LEFT:
		return "Left Mouse Button"
	if index == BUTTON_RIGHT || index == BUTTON_MASK_RIGHT:
		return "Right Mouse Button"
	if index == BUTTON_MIDDLE || index == BUTTON_MASK_MIDDLE:
		return "Middle Mouse Button"
	if index == BUTTON_XBUTTON1 || index == BUTTON_MASK_XBUTTON1:
		return "Extra Mouse Button 1"
	if index == BUTTON_XBUTTON2 || index == BUTTON_MASK_XBUTTON2:
		return "Extra Mouse Button 2"
	if index == BUTTON_WHEEL_UP:
		return "Mouse Wheel Up"
	if index == BUTTON_WHEEL_DOWN:
		return "Mouse Wheel Down"
	if index == BUTTON_WHEEL_LEFT:
		return "Mouse Wheel Left"
	if index == BUTTON_WHEEL_RIGHT:
		return "Mouse Wheel Right"
	return ""
