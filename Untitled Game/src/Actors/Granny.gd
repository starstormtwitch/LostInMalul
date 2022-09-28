extends Enemy

onready var attackBox = $Attack/AttackBox

var HasSocks = false;
var HasTrophy = false;
var HasPillow = false;
var HasCandle = false;
var _player;
var _itemTimer = Timer.new()
var _textBox: TextBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = LevelGlobals.GetPlayerActor();
	_textBox = LevelGlobals.GetTextBox();
	_health = 9999
	_acceleration = 0.2
	_speed = 40
	_animationHandler = AnimationHandler.new()
	if(get_node_or_null("AnimationTree") != null):
		$AnimationTree.active = true
	
	_itemTimer.connect("timeout",self,"_on_itemTimer_cooldown_timeout") 
	_itemTimer.one_shot = true
	add_child(_itemTimer)
	
		
#disabling attacking for now
func _physics_process(_delta: float) -> void:
	var dist_to_target = self.global_position.distance_to(_target.global_position)
	var distanceToStartFadeIn = 150;
	var distanceFullyVisible = 125;
	if(dist_to_target < distanceToStartFadeIn) && dist_to_target > distanceFullyVisible:
		self.modulate.a = (distanceToStartFadeIn - dist_to_target) / (distanceToStartFadeIn - distanceFullyVisible)
	elif(dist_to_target <= distanceFullyVisible):
		self.modulate.a = .8;
	else:
		self.modulate.a = 0
	
#func _on_InteractPromptArea_interactable_text_signal(text):
#	if(!_isStunned):
#		if(is_instance_valid(_player.InventoryItem) && _player.InventoryItem.name == "ComfySocks"):
#			_player.delete_item_from_inventory()
#			HasSocks = true;
#			_textBox.showText("I am so warm and comfy with these nice socks.")
#		elif(is_instance_valid(_player.InventoryItem) && _player.InventoryItem.name == "Trophy"):
#			_player.delete_item_from_inventory()
#			HasTrophy = true;
#			_textBox.showText("What a shiny trophy, I am always so proud of you.")
#		elif(is_instance_valid(_player.InventoryItem) && _player.InventoryItem.name == "Pillow"):
#			_player.delete_item_from_inventory()
#			HasPillow = true;
#			_textBox.showText("This pillow is very weird, why would you think your poor granny would want this?")
#		elif(is_instance_valid(_player.InventoryItem) && _player.InventoryItem.name == "Candle"):
#			_player.delete_item_from_inventory()
#			HasCandle = true;
#			_textBox.showText("Thank you, the smell of this wonderful gamer candle makes your granny so happy.")
#		else:
#			_textBox.showText("Hey there sonny, I'm so cold and uncomfortable, can you please take care of your poor granny?")
#	if(HasSocks && HasTrophy && HasPillow && HasCandle):
#		die();
#		self.dispose();

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(3, _velocity.normalized(), 500)


func _on_itemTimer_cooldown_timeout():
	_isStunned = false
	self.modulate =  Color(1,1,1,1) 
	$Attack.set_deferred("disabled", false);
