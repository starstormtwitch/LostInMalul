extends KinematicBody2D

class_name chatting


const _SPEED = 96
const _TIME = 10
const _DAMAGE = 1
var _direction = 1

const attackSound = preload("res://assets/audio/ShitmanBullet.mp3")

var _isMoving = false

var _timer: Timer = Timer.new()

onready var animationPlayer: AnimationPlayer = $AnimationPlayer
onready var trail: TrailDrawer = $Trail
onready var trailTracker: Position2D = $TrailTracker


# Called when the node enters the scene tree for the first time.
func _ready():
	_timer.connect("timeout", self, "_dispose") 
	_timer.one_shot = true
	add_child(_timer)
	_timer.start(_TIME)
	animationPlayer.play("Bullet")
	_flipTracker()


func _physics_process(delta):
	if _isMoving:
		var velocity = Vector2(_SPEED * _direction, 0)
		move_and_slide(velocity)


func _flipTracker():
	if _direction == 1:
		trailTracker.position.x = abs(trailTracker.position.x)
	else:
		trailTracker.position.x = -abs(trailTracker.position.x)


func set_direction(isFacingDirectionLeft: bool):
	if !isFacingDirectionLeft:
		self.scale = Vector2(1, 1)
		_direction = 1
	else:
		self.scale = Vector2(-1, 1)
		_direction = -1


func startMoving():
	_isMoving = true
	SoundPlayer.playSound(get_tree().get_current_scene(), attackSound, -5)

func _dispose():
	queue_free()

func _on_Attack_area_entered(area):
	if area.is_in_group("hurtbox") && area.get_parent() != null && area.get_parent().has_method("take_damage"):
		var directionVector = Vector2(_direction, 0)
		area.get_parent().take_damage(_DAMAGE, directionVector, AttackManager.MAX_DAMAGE_FORCE)
