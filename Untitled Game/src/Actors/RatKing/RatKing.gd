extends Enemy

var _enemySpawner = load("res://src/Helpers/Spawning/EnemySpawner.tscn");
var _spawner = load("res://src/Helpers/Spawning/Spawner.tscn");
var _lightningBolt = preload("res://src/Actors/RatKing/LightningSpell.tscn");
var _ratSoldier = preload("res://src/Actors/RatSoldier.tscn");

const castSound = preload("res://assets/audio/BossCast.mp3")
const thudSound = preload("res://assets/audio/thud.mp3")

#staff knockback info
var KNOCKBACK_COOLDOWN = 5;

#rat spawn
var _ratSpawnCooldownTimer = Timer.new()
var _canDoRatSpawn = true;
var _mobSpawnArea;
var _ratSpawnCooldown = 14;

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
	_maxHealth = 150
	_health = _maxHealth
	_acceleration = .5
	_speed = 25
	_attack_range = 700
	_stun_duration = 0
	_minDistanceToStayFromPlayer = 90;
	_maxDistanceToStayFromPlayer = 120;
	_canTakeKnockup = false;
	_canBeStunned = false;
	_flocks = false;
	_target = null;
	
	
	_animationHandler = NodeStateMachineAnimationHandler.new($AnimationTree)
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
	
	_lightningBetweenStrike.connect("timeout",self,"_on_lightning_between_timeout") 
	_lightningBetweenStrike.one_shot = true
	add_child(_lightningBetweenStrike)
	
		
	
	
		
#disabling attacking for now
func _physics_process(_delta: float) -> void:
	if(!isDying):
		_maxDistanceToStayFromPlayer = 120;
		if(!_lightningPhase && _health < (_maxHealth / 2)):
			_lightningPhase = true;
		if(!_enragePhase && _health < (_maxHealth / 5)):
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
							SoundPlayer.playSound(get_tree().get_current_scene(), castSound, 5)
							_lightning_spell();
						elif(_canDoRatSpawn && !_doingLightningAttack):
							_canDoRatSpawn = false;
							_isAttacking = true
							var ratsToSpawn = ceil(rand_range(2,5));
							$AnimationTree.get("parameters/playback").travel("attack")
							SoundPlayer.playSound(get_tree().get_current_scene(), castSound, 5)
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
	var ratSpawner = _enemySpawner.instance();
	ratSpawner.automatic = false;
	ratSpawner.global_position = _mobSpawnArea.global_position;
	ratSpawner.set_rect(Rect2(Vector2.ZERO, _mobSpawnArea.shape.extents));
	ratSpawner.duration_between_spawn = 1
	ratSpawner.count = amount;
	ratSpawner.enemy = "RatSoldier"
	ratSpawner.connect("AllEnemiesDefeated", self, "_on_rats_Defeated");
	get_parent().add_child(ratSpawner);
	ratSpawner.spawnEnemy();

func _on_rats_Defeated():
	_ratSpawnCooldownTimer.start(_ratSpawnCooldown);
	
func _attack_done():
	_finishedAttack(KNOCKBACK_COOLDOWN)

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		var directionOfKnockback = Vector2.ZERO;
		directionOfKnockback.x = _directionFacing;
		directionOfKnockback.y = rand_range(-1,1);
		area.get_parent().take_damage(2, directionOfKnockback, 100000)
		
		
func _on_lightning_while_timeout():
	_doingLightningAttack = false;
	_lightningCooldownTimer.start(_lightningCooldown);
	
func _on_lightning_cooldown_timeout():
	_canDoLightningAttack = true;
	
func _on_ratspawn_cooldown_timeout():
	_canDoRatSpawn = true;
	
func _on_lightning_between_timeout():
	_doNextStrike = true;

func die() -> void:
	.die()
	var children = get_parent().get_children();
	for child in children:
		if(child.is_in_group("enemy")):
			if("isDying" in child && !child.isDying):
				child.die()
#		elif(child.is_in_group("EnemySpawner")):
#			child.queue_free()
	

func _on_FlockBox_area_entered(area):
	if(area.get_parent().is_in_group("enemy")):
		add_to_flock(area.get_parent())

func _on_FlockBox_area_exited(area):
	if(area.get_parent().is_in_group("enemy")):
		remove_from_flock(area.get_parent())
