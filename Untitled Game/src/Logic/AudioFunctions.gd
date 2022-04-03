extends Node

class_name AudioFunctions

#https://docs.godotengine.org/en/stable/tutorials/audio/audio_buses.html
const audioMinDb: int = -12
const audioMaxDb: int = 0

static func CalculateNormalizedAudioVolume(percentage: float) -> float:
	percentage = max(0, min(percentage, 100))
	var dbValue = range_lerp(percentage, 0, 100, audioMinDb, audioMaxDb)
	return dbValue

static func ChangeAudioBusVolumePercentage(busName: String, percentage: float) -> void:
	var busIdx = AudioServer.get_bus_index(busName)
	assert(busIdx >= 0, "Audio bus " + busName + " not found.")
	if percentage > 0:
		var dbValue = CalculateNormalizedAudioVolume(percentage)
		AudioServer.set_bus_volume_db(busIdx, dbValue)
		if AudioServer.is_bus_mute(busIdx):
			AudioServer.set_bus_mute(busIdx, false)
			print("Audio bus unmuted: " + str(busName))
	elif !AudioServer.is_bus_mute(busIdx):
		AudioServer.set_bus_mute(busIdx, true)
		print("Audio bus muted: " + str(busName))
