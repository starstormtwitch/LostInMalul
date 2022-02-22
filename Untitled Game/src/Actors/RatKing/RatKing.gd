extends Enemy

var _spawner = preload("res://src/Helpers/Spawning/Spawner.tscn");
var _lightningBolt = preload("res://src/Actors/RatKing/LightningSpell.tscn");
var _ratSoldier = preload("res://src/Actors/RatSoldier.tscn");

#staff knockback info
var KNOCKBACK_COOLDOWN = 5;

#rat spawn
var _ratSpawnCooldownTimer = Timer.new()
var _canDoRatSpawn = true;
var _mobSpawnArea;
var _ratSpawnCooldown = 20;

#lightning attack info
var _lightningPhase = false;
var _lightningCooldownTimer = Timer.new()
var _lightningWhileTimer = Timer.new()
var _lightningBetweenStrike = Timer.new()
var _canDoLightningAttack = true;
var _doingLightningAttack = false;
var _doNextStrike = true;
var _lightningDuration = 15;
var _lightningDurationBetweenStrikes = .50;
var _lightningCooldown = 30;

var _enragePhase = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	_maxHealth = 200
	_health = _maxHealth
	_acceleration = .5
	_speed = 25
	_attack_range = 700
	_stun_duration = 0
	_minDistanceToStayFromPlayer = 90;
	_maxDistanceToStayFromPlayer = 120;
	_canTakeKnockup = false;
	_target = null;
	
	if($AnimationTree != null):
		$AnimationTree.active = true
	_lightningCooldownTimer.connect("timeout",self,"_on_lightning_cooldown_timeout") 
	_lightningCooldownTimer.one_shot = true
	add_child(_lightningCooldownTimer)
	
	_ratSpawnCooldownTimer.connect("timeout",self,"_on_ratspawn_cooldown_timeout") 
	_ratSpawnCooldownTimer.one_shot = true
	add_child(_ratSpawnCooldownTimer)
	
	_lightningWhileTimer.connect("timeout",self,"_on_lightning_while_timeout") 
	_lightningWhileTimer.one_shot = true
	add_child(_lightningWhileTimer)
	
	_lightningWhileTimer.connect("timeout",self,"_on_lightning_while_timeout") 
	_lightningWhileTimer.one_shot = true
	add_child(_lightningWhileTimer)
	
	_lightningBetweenStrike.connect("timeout",self,"_on_lightning_between_timeout") 
	_lightningBetweenStrike.one_shot = true
	add_child(_lightningBetweenStrike)
	
		
	
	
		
#disabling attacking for now
func _physics_process(_delta: float) -> void:
		_maxDistanceToStayFromPlayer = 120;
		if(!_lightningPhase && _health < 50):
			_lightningPhase = true;
		if(!_enragePhase && _health < 15):
			_enragePhase = true;
			_lightningDuration = 30;
			_lightningDurationBetweenStrikes = .10;
			_lightningCooldown = 10;
			_canDoLightningAttack = true;
		if(_doingLightningAttack && _doNextStrike):
			_doNextStrike = false;
			_lightning_spell();
			_lightningBetweenStrike.start(_lightningDurationBetweenStrikes)
		match _state:
			EnemyState.ATTACK_IN_PLACE:
				if !_isAttacking:
					var dist_to_target = self.global_position.distance_to(_target.global_position)
					if($AnimationTree != null):
						if(_lightningPhase && _canDoLightningAttack): #Do lightning spell
							_lightningWhileTimer.start(_lightningDuration)
							_doingLightningAttack = true;
							_canDoLightningAttack = false;
							_isAttacking = true
							$AnimationTree.get("parameters/playback").travel("attack")
							_lightning_spell();
						elif(_canDoRatSpawn && !_doingLightningAttack):
							_canDoRatSpawn = false;
							_isAttacking = true
							var ratsToSpawn = rand_range(2,5);
							$AnimationTree.get("parameters/playback").travel("attack")
							_ratSpawnCooldownTimer.start(_ratSpawnCooldown);
							_spawn_rats(ratsToSpawn);
						elif(dist_to_target <= 40): #only do slam attacak
							_isAttacking = true
							$AnimationTree.get("parameters/playback").travel("attack")
						else:
							_finishedAttack(KNOCKBACK_COOLDOWN)
			

func _lightning_spell():
	var spellSpawner = _spawner.instance();
	spellSpawner.global_position = _target.global_position; 
	spellSpawner.global_position.y = (spellSpawner.global_position.y - 20) + rand_range(-20,20);
	spellSpawner.global_position.x = spellSpawner.global_position.x + rand_range(-100,100);
	get_parent().add_child(spellSpawner);
	spellSpawner.spawnMultipleInArea(_lightningBolt)

func _spawn_rats(amount):
	assert(_mobSpawnArea != null, "Mob spawn area must be set in parent scene")
	
	var ratSpawner = _spawner.instance();
	ratSpawner.global_position = _mobSpawnArea.global_position;
	ratSpawner.set_rect(Rect2(Vector2.ZERO, _mobSpawnArea.shape.extents));
	ratSpawner.duration_between_spawn = 1
	ratSpawner.count = amount;
	get_parent().add_child(ratSpawner);
	ratSpawner.spawnMultipleInArea(_ratSoldier)

func _attack_done():
	_finishedAttack(KNOCKBACK_COOLDOWN)

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		var directionOfKnockback = Vector2.ZERO;
		directionOfKnockback.x = _directionFacing;
		directionOfKnockback.y = rand_range(-1,1);
		area.get_parent().take_damage(1, directionOfKnockback, 100000)
		
		
func _on_lightning_while_timeout():
	_doingLightningAttack = false;
	_lightningCooldownTimer.start(_lightningCooldown);
	
func _on_lightning_cooldown_timeout():
	_canDoLightningAttack = true;
	
func _on_ratspawn_cooldown_timeout():
	_canDoRatSpawn = true;
	
func _on_lightning_between_timeout():
	_doNextStrike = true;
	
