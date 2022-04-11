extends Button

export(String, "move_up", "move_down", "move_left", "move_right", "dodge", "special_attack", "side_swipe_attack", "attack_2") var action = "move_up"
export(String, "keyboard", "mouse", "controller") var input_type = "keyboard"

var isEditing: bool = false

signal remap_open
signal remap_closed
signal remap_keyInUse

func _ready():
	assert(InputMap.has_action(action))
	display_current_key()
	add_to_group("RemapButton")
	print(InputMap.get_action_list(action))

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
	if isEditing && event.is_pressed() && _isEventControlType(event):
		if event.is_action_pressed("ui_cancel"):
			isEditing = false
			pressed = false
		else:
			remap_action_to(event)

func _isEventControlType(event: InputEvent) -> bool:
	return ((event is InputEventKey && self.input_type == "keyboard")
		|| (event is InputEventMouseButton && self.input_type == "mouse")
		|| (event is InputEventJoypadButton && self.input_type == "joypad"))

func _createMapping(event):
	InputFunctions.CreateCustomMapping(action, event)

func remap_action_to(event):
	if InputFunctions.CheckCanUseCustomMapping(event):
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		_createMapping(event)
		display_current_key()
	else:
		emit_signal("remap_keyInUse")
	isEditing = false
	pressed = false

func display_current_key():
#	var inputMap: InputEvent = InputMap.get_action_list(action)[0]
	var inputMap = InputFunctions.GetCustomMapping(action, input_type)
	text = "%s" % InputFunctions.GetInputEventAsText(inputMap)
