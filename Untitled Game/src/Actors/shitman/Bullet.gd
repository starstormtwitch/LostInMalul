extends KinematicBody2D

class_name Bullet


const _SPEED = 96
const _TIME = 1.4
const _DAMAGE = 1
var _direction = 1


var _isMoving = false

var _timer: Timer = Timer.new()

onready var animationTree: AnimationTree = $AnimationTree
onready var queueFreeTimer: Timer = $QueueFreeTimer


# Called when the node enters the scene tree for the first time.
func _ready():
	_timer.connect("timeout", self, "_dissapear") 
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(_TIME)


func _physics_process(delta):
	if !_isMoving:
		var velocity = Vector2(_SPEED * _direction, 0)
		move_and_slide(velocity)


func set_direction(direction: int):
	if direction > 0:
		self.scale = Vector2(1, 1)
		_direction = 1
	elif direction < 0:
		self.scale = Vector2(-1, 1)
		_direction = -1


func startMoving():
	_isMoving = true


func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		queueFreeTimer.start()


func _on_QueueFreeTimer_timeout():
	queue_free()


func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		var directionVector = Vector2(_direction, 0)
		area.get_parent().take_damage(_DAMAGE, directionVector, AttackManager.MAX_DAMAGE_FORCE)
		queue_free()
