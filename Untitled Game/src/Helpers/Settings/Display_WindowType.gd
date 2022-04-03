extends Node



func _ready():
	pass

func main(value: Dictionary) -> void:
	var windowType: int = value["value"]
	print("window type: " + str(windowType))
	if windowType == 0: #fullscreen
		OS.window_fullscreen = true
		OS.window_borderless = false
	elif windowType == 1: #borderless
		OS.window_fullscreen = false
		OS.window_borderless = true
		OS.set_window_maximized(true)
	elif windowType == 2: #windowed
		OS.window_borderless = false
		OS.window_fullscreen = false
		OS.set_window_maximized(false)
