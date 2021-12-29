extends Enemy

const _GRAVITY = 10
const _JUMPFORCE = -160
const _JUMP_SPEED = 60

var _jumpVelocity = Vector2()
var _jumpDirection = Vector2()
var _spawner = preload("res://src/Helpers/Spawning/Spawner.tscn");
var _lightningBolt = preload("res://src/Actors/RatKing/LightningSpell.tscn");

# Called when the node enters the scene tree for the first time.
func _ready():
	_maxHealth = 30
	_health = _maxHealth
	_acceleration = 0.2
	_speed = 75
	_attack_range = 700
	_stun_duration = 0
	if($AnimationTree != null):
		$AnimationTree.active = true
		
#disabling attacking for now
func _physics_process(_delta: float) -> void:
	match _state:
		EnemyState.ATTACK_IN_PLACE:
			if !_isAttacking:
				_isAttacking = true
				var dist_to_target = self.global_position.distance_to(_target.global_position)
				if($AnimationTree != null):
					if(dist_to_target <= 40): #only do slam attack
						$AnimationTree.get("parameters/playback").travel("attack")
					else: #Do spell
						$AnimationTree.get("parameters/playback").travel("attack")
						var spellSpawner = _spawner.instance();
						spellSpawner.global_position = self.global_position; 
						get_parent().add_child(spellSpawner);
						spellSpawner.spawnMultipleInArea(_lightningBolt)
						
						

func _attack_done():
	_finishedAttack(10)

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		area.get_parent().take_damage(1, _velocity.normalized(), 100000)
