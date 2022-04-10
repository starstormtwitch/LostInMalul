extends ScrollContainer

signal remap_open
signal remap_closed
signal remap_keyInUse

func _ready():
	var remapers = self.get_parent().get_tree().get_nodes_in_group("RemapButton")
	for _rm in remapers:
		assert(_rm.has_signal("remap_open"), "RemapButton has no remap_open signal.")
		assert(_rm.has_signal("remap_closed"), "RemapButton has no remap_close signal.")
		_rm.connect("remap_open", self, "_remap_open")
		_rm.connect("remap_close", self, "_remap_closed")
		_rm.connect("remap_keyInUse", self, "_remap_keyInUse")
	print("Registered remapers.")

func _remap_open():
	emit_signal("remap_open")

func _remap_closed():
	emit_signal("remap_closed")

func _remap_keyInUse():
	emit_signal("remap_keyInUse")
