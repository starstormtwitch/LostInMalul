extends KinematicBody2D
class_name Actor

# props of all objects in game
var _velocity: = Vector2.ZERO
var _acceleration = .2
var _inAir = false
var _speed = 0
var _health = 1
var _gravity = Vector2(0.0, 30.0)
var _groundPosition = self.position.y;
const MAXVELOCITY = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func getMovement(direction: Vector2, speed: float, acceleration: float) -> Vector2:
	var targetVelocity = (direction.normalized() * speed);
	
	
	var verticalAcceleration = acceleration
	var horizontalAcceleration = acceleration
	#make objects significantly more floaty in air
	if(_inAir):
		verticalAcceleration = verticalAcceleration * .1
	
	#max target velocity is 5000, modify acceleration instead on higher force targets
	if(targetVelocity.x > MAXVELOCITY || targetVelocity.y > MAXVELOCITY 
	|| targetVelocity.x < -MAXVELOCITY || targetVelocity.y < -MAXVELOCITY):
		var accelerationAddition = (((abs(targetVelocity.x) + abs(targetVelocity.y)) / 2) / MAXVELOCITY) / 100
		verticalAcceleration += accelerationAddition
		horizontalAcceleration += accelerationAddition
		targetVelocity = targetVelocity.normalized() * MAXVELOCITY;
		
	#for smoother movement ramping
	var resultingVelocity = Vector2.ZERO
	resultingVelocity.x = lerp(_velocity.x, targetVelocity.x, horizontalAcceleration)
	resultingVelocity.y = lerp(_velocity.y, targetVelocity.y, verticalAcceleration)
		
	#apply gravity while object is in the air
	if(_inAir):
		if(resultingVelocity.y > 0 && self.position.y >= _groundPosition):
			_inAir = false;
			self.position.y = _groundPosition
		else:
			resultingVelocity += _gravity
	else:
		_groundPosition = self.position.y
		
	#give the movement some friction
	if(resultingVelocity.x > 0):
		resultingVelocity.x = floor(resultingVelocity.x / 10) * 10
	else:
		resultingVelocity.x = ceil(resultingVelocity.x / 10) * 10
	if(resultingVelocity.y > 0):
		resultingVelocity.y = floor(resultingVelocity.y / 10) * 10
	else:
		resultingVelocity.y = ceil(resultingVelocity.y / 10) * 10
		
	return resultingVelocity
	
func take_damage(damage: int, direction: Vector2, force: float) -> void:
	if($AnimationTree != null):
		$AnimationTree.get("parameters/playback").travel("hurt")
	_health-=damage
	#knockback
	var knockbackVelocity = getMovement(direction, force, _acceleration)
	_velocity = move_and_slide(knockbackVelocity)
	if(_health <= 0):
		die()
		
func die() -> void:
	if($AnimationTree != null):
		$AnimationTree.get("parameters/playback").travel("die")
	set_physics_process(false)
	
func dispose() -> void:
	queue_free()

