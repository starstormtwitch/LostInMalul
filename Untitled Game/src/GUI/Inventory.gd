extends Node2D

var InventoryItem : Node2D setget setInventoryItem
	
func setInventoryItem(value):
	InventoryItem = value;
	var inventorySlot = get_node("CenterContainer/InventorySlot");
	for item in inventorySlot.get_children():
		inventorySlot.remove_child(item);
	if(value != null):
		inventorySlot.add_child(value);
