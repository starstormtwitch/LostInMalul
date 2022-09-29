extends Node
class_name DestructibleObject

var maxHealth = 3

var _health
var _isDestroyed = false
signal health_changed
signal died
var _hitFlashTimer = Timer.new()
var _deathBlinkCountdown = Timer.new()
var _deathCountdown = Timer.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	_health = maxHealth;
	_deathBlinkCountdown.one_shot = true
	add_child(_deathBlinkCountdown)
	
	_deathCountdown.one_shot = true
	add_child(_deathCountdown)
	_deathCountdown.connect("timeout",self,"_death_countdown_timeout") 
	
	_hitFlashTimer.connect("timeout",self,"_on_hitFlash_cooldown_timeout") 
	_hitFlashTimer.one_shot = true
	add_child(_hitFlashTimer)
	
	
func _physics_process(_delta: float) -> void:
	var direction = Vector2.ZERO
	if _isDestroyed:
		if deathVisible(_deathBlinkCountdown.time_left):
			self.visible = true
		else:
			self.visible = false
	
func check_destruction_state():
	if(_health <= 0):
		$AnimationPlayer.play("broken")
	elif(_health <= maxHealth):
		$AnimationPlayer.play("destroyed")
		


func show_hit_marker(isKick: bool):
	pass

func deathVisible(countdownTimer) -> bool:
	var visibleTime = 3;
	if countdownTimer > visibleTime:
		return true
	else:
		return sin(pow(1000 - countdownTimer - visibleTime, 2) * 1/100) + .5 >= 0
			
func take_damage(damage: int, direction: Vector2, force: float) -> void:
	if !_isDestroyed:
		var newHealth = _health-damage
		emit_signal("health_changed", _health, newHealth, maxHealth)
		_health=newHealth
		self.modulate =  Color(10,10,10,10) 
		_hitFlashTimer.start(.2)
		#knockback
#		var knockbackVelocity = getMovement(direction, force, _acceleration)
#		_velocity = move_and_slide(knockbackVelocity)
		check_destruction_state();
		if(_health <= 0):
			_deathBlinkCountdown.start(5)
			die()
			
func _on_hitFlash_cooldown_timeout():
	self.modulate =  Color(1,1,1,1) 
		

func die() -> void:
	_isDestroyed = true
	_disableNodes(self)
	emit_signal("died")
	_deathCountdown.start(4)
	
func _death_countdown_timeout() -> void:
	queue_free();
	
func _disableNodes(parentNode : Node):
	if "disabled" in parentNode:
		parentNode.set_deferred("disabled", true);
	for node in parentNode.get_children():
		_disableNodes(node);

