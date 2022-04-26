extends GridContainer

class_name CustomSlider

signal value_changed

func _ready():
	_setLabelText()

func _on_HSlider_value_changed(value):
	_setLabelText()
	emit_signal("value_changed")
	
func _setLabelText():
	if $Label == null || $HSlider == null:
		yield(self, "ready")
	$Label.text = str(round($HSlider.value))+'%'



