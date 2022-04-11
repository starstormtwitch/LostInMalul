extends Node

class_name InputFunctions

const _inputTypeName_Keyboard: String = "keyboard"
const _inputTypeName_Mouse: String = "mouse"
const _inputTypeName_Joypad: String = "joypad"


static func GetCustomMapping(action: String, inputType: String) -> InputEvent:
	var data: Dictionary = GetCustomMappingData()
	if data.has(action) && data[action].has(inputType):
		return NewInputEventFrom(action, inputType, str(data[action][inputType]))
	return null

static func GetDefaultMapping(action: String, inputType: String) -> InputEvent:
	var events = InputMap.get_action_list(action)
	var customMap = GetCustomMapping(action, inputType)
	for e in events:
		if ((e != customMap) &&
			((inputType == _inputTypeName_Keyboard && e is InputEventKey)
			|| (inputType == _inputTypeName_Mouse && e is InputEventMouseButton)
			|| (inputType == _inputTypeName_Joypad && e is InputEventJoypadButton))):
				return e
	return null

static func CreateCustomMapping(action: String, event: InputEvent):
	var data: Dictionary = GetCustomMappingData()
	if !data.has(action):
		data[action] = {}
	if event is InputEventKey:
		data[action][_inputTypeName_Keyboard] = OS.get_scancode_string(event.scancode)
	elif event is InputEventMouseButton:
		data[action][_inputTypeName_Mouse] = event.button_index
	elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
		push_error("Not implemented.")
	SaveCustomMappingData(data)

static func CheckCanUseCustomMapping(event: InputEvent) -> bool:
	var data: Dictionary = GetCustomMappingData()
	var eventString = GetInputEventValueAsString(event)
	for actionName in data.keys():
		for inputType in data[actionName]:
			if str(data[actionName][inputType]) == eventString:
				return false
	return true

static func GetInputEventValueAsString(event: InputEvent) -> String:
	var result = ""
	if event is InputEventKey:
		result = OS.get_scancode_string(event.scancode)
	elif event is InputEventMouseButton:
		result = str(event.button_index)
	elif event is InputEventJoypadButton || event is InputEventJoypadMotion:
		push_error("Not implemented.")
	return result

static func LoadCustomMappings() -> void:
	var data: Dictionary = GetCustomMappingData()
	for actionName in data.keys():
		#InputMap.action_erase_events(actionName)
		for inputTypeName in data[actionName]:
			var inputEventValue: String = str(data[actionName][inputTypeName])
			if !inputEventValue.empty():
				var inputEvent = NewInputEventFrom(actionName, inputTypeName, inputEventValue)
				if inputEvent != null:
					InputMap.action_add_event(actionName, inputEvent)

static func NewInputEventFrom(action: String, inputType: String, inputEventValue: String) -> InputEvent:
	var inputEvent = null
	if inputType == _inputTypeName_Keyboard:
		inputEvent = InputEventKey.new()
		inputEvent.set_scancode(OS.find_scancode_from_string(str(inputEventValue)))
	elif inputType == _inputTypeName_Mouse:
		inputEvent = InputEventMouseButton.new()
		inputEvent.button_index = int(inputEventValue)
	elif inputType == _inputTypeName_Joypad:
		push_error("Not implemented.")
	return inputEvent

static func GetInputEventAsText(event: InputEvent) -> String:
	if event == null:
		return ""
	elif event is InputEventMouseButton:
		return MouseButtonIndexToText(event.button_index)
	return event.as_text()

static func MouseButtonIndexToText(index: int) -> String:
	if index == BUTTON_LEFT || index == BUTTON_MASK_LEFT:
		return "LMB" #"Left Mouse Button"
	if index == BUTTON_RIGHT || index == BUTTON_MASK_RIGHT:
		return "RMB" #"Right Mouse Button"
	if index == BUTTON_MIDDLE || index == BUTTON_MASK_MIDDLE:
		return "MMB" #"Middle Mouse Button"
	if index == BUTTON_XBUTTON1 || index == BUTTON_MASK_XBUTTON1:
		return "Thumb 1" #"Extra Mouse Button 1"
	if index == BUTTON_XBUTTON2 || index == BUTTON_MASK_XBUTTON2:
		return "Thumb 2" #"Extra Mouse Button 2"
	if index == BUTTON_WHEEL_UP:
		return "Wheel Up" #"Mouse Wheel Up"
	if index == BUTTON_WHEEL_DOWN:
		return "Wheel Down" #"Mouse Wheel Down"
	if index == BUTTON_WHEEL_LEFT:
		return "Wheel Left" #"Mouse Wheel Left"
	if index == BUTTON_WHEEL_RIGHT:
		return "Wheel Right" #"Mouse Wheel Right"
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
