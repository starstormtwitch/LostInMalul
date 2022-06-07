extends ScrollContainer

signal remap_open
signal remap_closed
signal remap_keyInUse
signal remap_resetRequest

func _ready():
	for r in _getActionRemapButtons():
		var _rm: ActionRemapButton = r
		assert(_rm.has_signal("remap_open"), "RemapButton has no remap_open signal.")
		assert(_rm.has_signal("remap_closed"), "RemapButton has no remap_close signal.")
		assert(_rm.has_signal("remap_keyInUse"), "RemapButton has no remap_keyInUse signal.")
		_rm.connect("remap_open", self, "_remap_open")
		_rm.connect("remap_closed", self, "_remap_closed")
		_rm.connect("remap_keyInUse", self, "_remap_keyInUse")
	print("Registered remapers.")

func _remap_open():
	emit_signal("remap_open")

func _remap_closed():
	emit_signal("remap_closed")

func _remap_keyInUse():
	emit_signal("remap_keyInUse")

func _on_ResetButton_pressed():
	emit_signal("remap_resetRequest")

func RefreshControls():
	for r in _getActionRemapButtons():
		var _rm: ActionRemapButton = r
		_rm.display_current_key()

func _getActionRemapButtons() -> Array:
	return self.get_parent().get_tree().get_nodes_in_group("RemapButton")
