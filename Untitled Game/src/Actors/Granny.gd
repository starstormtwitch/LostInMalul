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
	_player = LevelGlobals.GetPlayerActor()
	_health = 9999
	_acceleration = 0.1
	_speed = 90
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
	
func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(5, _velocity.normalized(), 500)
		_isStunned = true;
		_itemTimer.start(30)
		self.modulate =  Color(0,0,1,1) 


func _on_itemTimer_cooldown_timeout():
	_isStunned = false
	self.modulate =  Color(1,1,1,1) 
	$Attack.set_deferred("disabled", false);
