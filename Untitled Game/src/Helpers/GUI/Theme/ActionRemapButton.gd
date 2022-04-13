extends Button

class_name ActionRemapButton

export(String, "move_up", "move_down", "move_left", "move_right", "dodge", "special_attack", "side_swipe_attack", "attack_2") var action = "move_up"
export(String, "keyboard", "mouse", "joypad") var input_type = "keyboard"

var isEditing: bool = false
var localInputEvent: InputEvent = null

signal remap_open
signal remap_closed
signal remap_keyInUse

func _ready():
	assert(InputMap.has_action(action))
	add_to_group("RemapButton")
	display_current_key()

func _toggled(button_pressed):
	if isEditing:
		return
	if button_pressed:
		text = "..."
		isEditing = true
		release_focus()
		emit_signal("remap_open")
	else:
		display_current_key()

func _input(event: InputEvent) -> void:
	if event.is_pressed():
		if isEditing &&  _isEventControlType(event) && (!event.is_action_pressed("ui_cancel") || event is InputEventMouseButton && event.button_index == BUTTON_LEFT):
			remap_action_to(event)
		else:
			isEditing = false
			pressed = false

func _isEventControlType(event: InputEvent) -> bool:
	return ((event is InputEventKey && self.input_type == "keyboard")
		|| (event is InputEventMouseButton && self.input_type == "mouse")
		|| ((event is InputEventJoypadButton || event is InputEventJoypadMotion) && self.input_type == "joypad"))

func remap_action_to(event):
	if !_checkIsAlreadyInUse(event) && InputFunctions.CheckCanUseCustomMapping(event):
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		InputFunctions.CreateCustomMapping(action, event)
		display_current_key()
	else:
		emit_signal("remap_keyInUse")
	isEditing = false
	pressed = false

func _checkIsAlreadyInUse(event: InputEvent):
	var eventString = InputFunctions.GetInputEventValueAsString(event)
	for r in _getActionRemapButtons():
		var _rm: ActionRemapButton = r
		if eventString == InputFunctions.GetInputEventValueAsString(_rm.localInputEvent):
			return true
	return false

func _updateLocalInputEvent():
	localInputEvent = InputFunctions.GetCustomMapping(action, input_type)
	if localInputEvent == null:
		localInputEvent = InputFunctions.GetDefaultMapping(action, input_type)

func display_current_key():
	_updateLocalInputEvent()
	text = "%s" % InputFunctions.GetInputEventAsText(localInputEvent)

func _getActionRemapButtons() -> Array:
	return self.get_parent().get_tree().get_nodes_in_group("RemapButton")
