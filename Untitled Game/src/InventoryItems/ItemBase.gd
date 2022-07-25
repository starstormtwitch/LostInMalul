extends Node2D

var _player : Actor

func init(player : Actor, item : Node2D):
	_player = player;
	$CenterContainer/ItemContainer.add_child(item);
	return self;
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if(_player == null):
		_player = LevelGlobals.GetPlayerActor()
	assert(is_instance_valid(_player),"Player instance invalid")
		
func _on_InteractPromptArea_interactable_text_signal(text):
	var items = $CenterContainer/ItemContainer.get_children();
	assert(items.size() > 0, "DetachedItemBase has no item inside!!!")
	for item in items:
		assert(item is Node2D, "child in detached item base is not an item!")
		$CenterContainer/ItemContainer.remove_child(item);
		_player.add_item_to_inventory(item);
	queue_free();
