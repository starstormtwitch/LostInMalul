extends Node

#In charge of handling jump mechanics of 
class_name JumpHelper

const _GRAVITY = 30
const _JUMPFORCE = -900

var velocity = Vector2()
var _isJumping = false

var _kinematicBody: KinematicBody2D

func _init(kinematicBody: KinematicBody2D):
	assert(kinematicBody, "kinematicBody not found.")
	_kinematicBody = kinematicBody
	kinematicBody.move_and_slide(velocity)


func _physics_process(delta):
	if _isJumping:
		velocity.y -= _GRAVITY

func jump(): 
	if !_isJumping:
		_isJumping = true
		velocity.y = _JUMPFORCE
