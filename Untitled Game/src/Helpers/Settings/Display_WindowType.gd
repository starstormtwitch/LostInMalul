extends Node



func _ready():
	pass

func main(value: Dictionary) -> void:
	var windowType: int = value["value"]
	print("window type: " + str(windowType))
	if windowType == 0:
		OS.window_fullscreen = true
	if windowType == 1:
		OS.window_fullscreen = false
