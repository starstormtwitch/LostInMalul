extends Button

export(String, "move_up", "move_down", "move_left", "move_right", "dodge", "special_attack", "side_swipe_attack", "attack_2") var action = "move_up"
export(String, "mouseAndKeyboard", "controller") var input_type = "mouseAndKeyboard"

var isEditing: bool = false

signal remap_open
signal remap_closed
signal remap_keyInUse

func _ready():
	assert(InputMap.has_action(action))
#	set_process_unhandled_key_input(false)
	display_current_key()
	add_to_group("RemapButton")

func _toggled(button_pressed):
	if isEditing:
		return
		
	set_process_unhandled_input(button_pressed)
	if button_pressed:
		text = "input key..."
		isEditing = true
		release_focus()
		emit_signal("remap_open")
	else:
		display_current_key()

func _input(event: InputEvent) -> void:
	if isEditing && event.is_pressed():
		print(event)
		if false: # event.is_action_pressed("ui_cancel"):
			print("cancel")
			isEditing = false
			pressed = false
		else:
			remap_action_to(event)
		

#func _unhandled_key_input(event):
#	print(event)
#	# Note that you can use the _input callback instead, especially if
#	# you want to work with gamepads.
#	if isEditing:
#		if event.is_action_pressed(EventsList.UI_CANCEL_EVENT):
#			isEditing = false
#		else:
#			remap_action_to(event)
#		pressed = false

func _checkEventIsInUse(event) -> bool:
	var actions = InputMap.get_actions()
	for action in actions:
		if InputMap.action_has_event(action, event):
			print("event in use")
			return true
	print("event not in use")
	return false

func _saveMapping(event):
	InputFunctions.SaveCustomMapping(action, event)

func remap_action_to(event):
	if !_checkEventIsInUse(event):
		print("map event")
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)
		_saveMapping(event)
		display_current_key()
	else:
		print("key in use")
		emit_signal("remap_keyInUse")
	isEditing = false
	pressed = false

func display_current_key():
	var inputMap: InputEvent = InputMap.get_action_list(action)[0]
	text = "%s" % InputFunctions.GetInputEventAsText(inputMap)
