extends Node

func _ready():
	pass

func main(value: Dictionary) -> void:
#	print("vsync: " + str(value["value"]))
	OS.vsync_enabled = value["value"]
