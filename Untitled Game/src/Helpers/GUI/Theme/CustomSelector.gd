extends OptionButton

class_name CustomSelector

onready var SelectedItemLabel = $GridContainer/Item

func _ready():
	_setSelectedLabel()

func _on_Previous_pressed():
	self.selected -= 1
	_setSelectedLabel()

func _on_Next_pressed():
	self.selected += 1
	_setSelectedLabel()

func _on_CustomSelector_item_selected(index):
	_setSelectedLabel()

func _setSelectedLabel():
	SelectedItemLabel.text = self.get_item_text(self.selected)

