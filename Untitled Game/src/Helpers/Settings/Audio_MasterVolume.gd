extends Node

func _ready():
	pass

func main(value: Dictionary) -> void:
	AudioFunctions.ChangeAudioBusVolumePercentage("Master", value["value"])
