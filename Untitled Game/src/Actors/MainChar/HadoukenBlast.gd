extends KinematicBody2D

class_name HadoukenBlast

const _SPEED = 32
const _TIME = 1
const _DAMAGE = 4
var _direction = 1

var _isExploding = false

var _timer: Timer = Timer.new()

onready var animationTree: AnimationTree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	_timer.connect("timeout", self, "_dissapear") 
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(_TIME)


func _physics_process(delta):
	if !_isExploding:
		var velocity = Vector2(_SPEED * _direction, 0)
		move_and_slide(velocity)


func set_direction(direction: Vector2):
	if direction.x > 0:
		self.scale = Vector2(1, 1)
		_direction = 1
	elif direction.x < 0:
		self.scale = Vector2(-1, 1)
		_direction = -1


func _dissapear():
	animationTree.get("parameters/playback").travel("end")


func _explode():
	_isExploding = true
	animationTree.get("parameters/playback").travel("explosion")


func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		var directionVector = Vector2(_direction, 0)
		area.get_parent().take_damage(_DAMAGE, directionVector, AttackManager.MAX_DAMAGE_FORCE)
		_timer.stop()
		_explode()
