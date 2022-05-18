extends Enemy

onready var attackBox = $Attack/AttackBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_health = 9999
	_acceleration = 0.2
	_speed = 65
	_attack_range = 10
	attackBox.disabled = true
	if(get_node_or_null("AnimationTree") != null):
		$AnimationTree.active = true
		
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
		area.get_parent().take_damage(5, _velocity.normalized(), 1000)
