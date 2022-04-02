extends GridContainer

class_name CustomSlider

func _ready():
	_setLabelText()

func _on_ggsSlider_value_changed(value):
	_setLabelText()
	
func _setLabelText():
	if $Label == null:
		yield(self, "ready")
	$Label.text = str(round($ggsSlider.value))+'%'
