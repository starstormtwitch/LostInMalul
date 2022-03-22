extends Node2D

var _player : Actor

func _init(player : Actor, item : Node2D):
	_player = player;
	$ItemContainer.add_child(item);
	pass;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if(_player == null):
		_player = LevelGlobals.GetPlayerActor()
	assert(is_instance_valid(_player),"Player instance invalid")
	assert($ItemContainer.get_child_count() > 0, "DetachedItemBase has no item!")
		
func _on_InteractPromptArea_interactable_text_signal(text):
	var items = $ItemContainer.get_children();
	assert(items.count() > 0, "DetachedItemBase has no item inside!!!")
	for item in items:
		assert(item is Node2D, "child in detached item base is not an item!")
		_player.AddItemToInventory(item);
		$ItemContainer.remove_child(item);
	queue_free();
