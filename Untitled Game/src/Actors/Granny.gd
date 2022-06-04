extends Enemy

onready var attackBox = $Attack/AttackBox

var HasSocks = false;
var HasTrophy = false;
var HasPillow = false;
var HasCandle = false;
var _player;
var _itemTimer = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = LevelGlobals.GetPlayerActor();
	$InteractPromptArea.playerNodePath = _player.get_path()
	$InteractPromptArea._player = _player
	_health = 9999
	_acceleration = 0.2
	_speed = 50
	_attack_range = 10
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
	

func _attack_done():
	_velocity = getMovement(Vector2.ZERO, 0, .5)
	#_velocity = move_and_slide(_velocity)
	_finishedAttack(2)

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage") && _isStunned == false:
		area.get_parent().take_damage(5, _velocity.normalized(), 50000)

func _on_InteractPromptArea_interactable_text_signal(text):
	if(!_isStunned):
		if(is_instance_valid(_player.InventoryItem) && _player.InventoryItem.name == "ComfySocks"):
			_player.delete_item_from_inventory()
			HasSocks = true;
			self.modulate =  Color(0,0,20,.5) 
			$Attack.set_deferred("disabled", true);
			stun(5)
			_hitFlashTimer.start(5)
		elif(is_instance_valid(_player.InventoryItem) && _player.InventoryItem.name == "Trophy"):
			_player.delete_item_from_inventory()
			HasTrophy = true;
			self.modulate =  Color(0,0,1,.5) 
			$Attack.set_deferred("disabled", true);
			stun(5)
			_hitFlashTimer.start(5)
		elif(is_instance_valid(_player.InventoryItem) && _player.InventoryItem.name == "Pillow"):
			_player.delete_item_from_inventory()
			HasPillow = true;
			self.modulate =  Color(0,0,1,.5) 
			$Attack.set_deferred("disabled", true);
			stun(5)
			_hitFlashTimer.start(5)
		elif(is_instance_valid(_player.InventoryItem) && _player.InventoryItem.name == "Candle"):
			_player.delete_item_from_inventory()
			HasCandle = true;
			self.modulate =  Color(0,0,1,.5) 
			$Attack.set_deferred("disabled", true);
			stun(5)
			_hitFlashTimer.start(5)
		else:
			self.modulate =  Color(2,2,2,.5) 
			stun(5)
			$Attack.set_deferred("disabled", true);
			_hitFlashTimer.start(5)
	if(HasSocks && HasTrophy && HasPillow && HasCandle):
		die();
		self.dispose();
		
func _on_itemTimer_cooldown_timeout():
	_isStunned = false
	self.modulate =  Color(1,1,1,.8) 
	$Attack.set_deferred("disabled", false);
