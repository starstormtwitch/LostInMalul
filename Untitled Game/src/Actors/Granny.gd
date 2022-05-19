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
	pass
#	match _state:
#		EnemyState.ATTACK_IN_PLACE:


func _attack_done():
	_velocity = getMovement(Vector2.ZERO, 0, .5)
	#_velocity = move_and_slide(_velocity)
	_finishedAttack(2)

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(5, _velocity.normalized(), 5000)

func _on_InteractPromptArea_interactable_text_signal(text):
	if(_player.InventoryItem != null && _player.InventoryItem.name == "ComfySocks"):
		_player.delete_item_from_inventory()
		HasSocks = true;
		self.modulate =  Color(0,0,20,10) 
		_hitFlashTimer.start(3)
		stun(3)
	elif(_player.InventoryItem != null && _player.InventoryItem.name == "Trophy"):
		_player.delete_item_from_inventory()
		HasTrophy = true;
		self.modulate =  Color(0,0,100,10) 
		_hitFlashTimer.start(3)
		stun(3)
	elif(_player.InventoryItem != null && _player.InventoryItem.name == "Pillow"):
		_player.delete_item_from_inventory()
		HasPillow = true;
		self.modulate =  Color(0,0,100,10) 
		_hitFlashTimer.start(3)
		stun(3)
	elif(_player.InventoryItem != null && _player.InventoryItem.name == "Candle"):
		_player.delete_item_from_inventory()
		HasCandle = true;
		self.modulate =  Color(0,0,100,10) 
		_hitFlashTimer.start(3)
		stun(3)
		
	if(HasSocks && HasTrophy && HasPillow && HasCandle):
		die();
		
func _on_itemTimer_cooldown_timeout():
	_isStunned = false
	self.modulate =  Color(0,0,0,0) 
		
func _on_Attack_body_entered(body):
	if body.is_in_group("hurtbox") && body.get_parent() != null && body.get_parent().has_method("take_damage"):
		body.get_parent().take_damage(5, _velocity.normalized(), 1000)
