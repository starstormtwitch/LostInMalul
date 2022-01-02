extends Control

class_name SettingsMenu

signal settings_changed

#class in charge of the settings menu node

func _on_OkButton_pressed():
	self.visible = false
	emit_signal("settings_changed")


func show_settings():
	self.visible = true
