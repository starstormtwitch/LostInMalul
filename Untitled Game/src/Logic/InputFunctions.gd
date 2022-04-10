extends Node

class_name InputFunctions

const _inputTypeName_Keyboard: String = "keyboard"
const _inputTypeName_Mouse: String = "mouse"
const _inputTypeName_Joypad: String = "joypad"


static func GetInputEventAsText(event: InputEvent) -> String:
	if event is InputEventMouseButton:
		return MouseButtonIndexToText(event.button_index)
	return event.as_text()
	
static func GetCustomMapping(action, inputType) -> InputEventKey:
	var data: Dictionary = GetCustomMappingData()
	if !data.has(action) || !data[action].has(inputType):
		return null
	var key = data[action][inputType]
	var inputEvent = InputEventKey.new()
	inputEvent.set_scancode(OS.find_scancode_from_string(key))
	return inputEvent

static func SaveCustomMapping(action, event):
	var data: Dictionary = GetCustomMappingData()
#	if !data.has(action): #for multi mapping
	data[action] = {}
	if event is InputEventKey:
		data[action][_inputTypeName_Keyboard] = OS.get_scancode_string(event.scancode)
	elif event is InputEventMouseButton:
		data[action][_inputTypeName_Mouse] = event.button_index
	elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
		push_error("Not implemented.")
	SaveCustomMappingData(data)

static func LoadCustomMappings() -> void:
	var data: Dictionary = GetCustomMappingData()
	for actionName in data.keys():
		InputMap.action_erase_events(actionName)
		for inputTypeName in data[actionName]:
			var inputEventValue: String = str(data[actionName][inputTypeName])
			if !inputEventValue.empty():
				if inputTypeName == _inputTypeName_Keyboard:
					var inputEvent: InputEventKey = InputEventKey.new()
					inputEvent.set_scancode(OS.find_scancode_from_string(inputEventValue))
					InputMap.action_add_event(actionName, inputEvent)
				elif inputTypeName == _inputTypeName_Mouse:
					var inputEvent: InputEventMouseButton = InputEventMouseButton.new()
					inputEvent.button_index = int(inputEventValue)
					InputMap.action_add_event(actionName, inputEvent)
				elif inputTypeName == _inputTypeName_Joypad:
					push_error("Not implemented.")

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

static func ResetInputMapping() -> void:
	SaveCustomMappingData(null)
	InputMap.load_from_globals()
	
static func GetCustomMappingData() -> Dictionary:
	var data = ggsManager.settings_data["11"]["current"]["value"]
	if !(data is Dictionary):
		data = {}
	return data

static func SaveCustomMappingData(data) -> void:
	ggsManager.settings_data["11"]["current"]["value"] = data
	ggsManager.save_settings_data()
