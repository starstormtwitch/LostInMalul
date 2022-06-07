extends Node


func main(value: Dictionary) -> void:
	print("CRT: " + str(value["value"]))
	#OS.vsync_enabled = value["value"]
