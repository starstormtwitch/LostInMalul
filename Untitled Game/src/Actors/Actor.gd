extends KinematicBody2D
class_name Actor

# props of all objects in game
const MAXVELOCITY = 1500
const _BOUNDARY_COLLISON_MASK_BIT = 0
const HURTBOX_POSITION_OFFSET = 20

var _velocity: = Vector2.ZERO
var _acceleration = .2
var _inAir = false
var isDying = false
var _speed = 0
var _health = 1
var _maxHealth = 1
var _gravity = Vector2(0.0, 2.0)
var _groundPosition = self.position.y;

#jump mechanic stuff
var _lastYPostionOnGround = 0
var _originalHurtBoxPosition: Vector2 = Vector2.ZERO

var errorLogger = ErrorLogger.new()

signal health_changed
signal died

onready var kinematicSprite: KinematicBody2D = $KinematicSprite
onready var hurtbox: Area2D = $HurtBox

# Called when the node enters the scene tree for the first time.
func _ready():
	errorLogger.assertNodeNotNull(kinematicSprite, "KinematicSprite", self)
	errorLogger.assertNodeNotNullNonCrashing(hurtbox, "HurtBox", self)
	if hurtbox != null:
		_originalHurtBoxPosition = hurtbox.position


func _physics_process(delta):
	if(_inAir && _velocity.y > 0 && kinematicSprite.global_position.y >= _groundPosition):
		_landOnGround()
	if !_inAir:
		_groundPosition = self.global_position.y
	else:
		hurtbox.global_position.y = kinematicSprite.global_position.y - HURTBOX_POSITION_OFFSET;


func _landOnGround():
	_inAir = false;
	self.global_position.y = _groundPosition;
	kinematicSprite.global_position.y = _groundPosition;
	hurtbox.position = _originalHurtBoxPosition;


#This is to move sprite only vertically, to make it look like its knockbacked.
func moveKinematicSprite(gravityVelocity: Vector2) -> Vector2:
	var yVelocity = Vector2(0, gravityVelocity.y) 
	return kinematicSprite.move_and_slide(yVelocity)


#this is to move whole node only horizonatally. 
func moveParent(gravityVelocity: Vector2) -> Vector2:
	if _inAir and self.is_on_wall():
		_velocity.x *= -1
		gravityVelocity.x *= -1
	var xVelocity = Vector2(gravityVelocity.x, 0)
	return self.move_and_slide(xVelocity)


func setColliderStatusDisabled(disable: bool):
	set_collision_mask_bit(_BOUNDARY_COLLISON_MASK_BIT, disable)


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
		
	#give the movement some frictionas
	if(resultingVelocity.x > 0):
		resultingVelocity.x = floor(resultingVelocity.x / 5) * 5
	else:
		resultingVelocity.x = ceil(resultingVelocity.x / 5) * 5
	if(resultingVelocity.y > 0):
		resultingVelocity.y = floor(resultingVelocity.y / 5) * 5
	else:
		resultingVelocity.y = ceil(resultingVelocity.y / 5) * 5
		
	return resultingVelocity
	
func take_damage(damage: int, direction: Vector2, force: float) -> void:
	if !isDying:
		if($AnimationTree != null):
			$AnimationTree.get("parameters/playback").travel("Hurt")
		var newHealth = _health-damage
		emit_signal("health_changed", _health, newHealth, _maxHealth)
		_health=newHealth
		#knockback
		var knockbackVelocity = getMovement(direction, force, _acceleration)
		_velocity = move_and_slide(knockbackVelocity)
		if(_health <= 0):
			die()
		
func die() -> void:
	isDying = true
	_disableNodes(self)
	if($AnimationTree != null):
		$AnimationTree.get("parameters/playback").travel("die")
	emit_signal("died")
	
func dispose() -> void:
	queue_free()

func _disableNodes(parentNode : Node):
	if "disabled" in parentNode:
		parentNode.set_deferred("disabled", true);
	for node in parentNode.get_children():
		_disableNodes(node);
