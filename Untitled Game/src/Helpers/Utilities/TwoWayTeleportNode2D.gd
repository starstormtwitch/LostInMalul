extends Node2D

##Two way teleportation node class.
##To set it up you need to enable editable children in the editor.
##When using it if the shape needs to be changed or resized first select it and change it, make it or make it unique. 
##If not any edit to it will modify any other instance using the default shape.
class_name TwoWayTeleportNode2D

const _interactionTimeout: float = 1.0

enum EndpointEnum {ALPHA = 0, BETA = 1} #used to validate target endpoint on teleport function

var _on_alpha: bool = false
var _on_beta: bool = false
var _on_cooldown: bool = false

##If enabled a promp with a key will be shown that needs to be pressed to trigger the teleport.
export var RequirePlayerAction: bool = false
##Fade animation time for both steps of the animation (in and out).
export var FadeAnimationTime: float = 0.4

signal TeleportActivated(targetPosition, fadeAnimationTime)

func _init():
	add_to_group("TeleportNode")

func _onready():
	pass

#capute user input events
func _input(event: InputEvent) -> void:
	if event.is_action("interact"):
		if _on_alpha:
			_teleportPlayerToEndpoint(EndpointEnum.BETA)
		elif _on_beta:
			_teleportPlayerToEndpoint(EndpointEnum.ALPHA)

#on enter alpha
func _on_EndpointAlpha_body_entered(body) -> void:
	if body.is_in_group("Player"):
		if RequirePlayerAction:
			$EndpointAlpha/Prompt.visible = true
			_on_alpha = true
		else:
			_teleportPlayerToEndpoint(EndpointEnum.BETA)

#on enter beta
func _on_EndpointBeta_body_entered(body) -> void:
	if body.is_in_group("Player"):
		if RequirePlayerAction:
			$EndpointBeta/Prompt.visible = true
			_on_beta = true
		else:
			_teleportPlayerToEndpoint(EndpointEnum.ALPHA)

#on exit alpha
func _on_EndpointAlpha_body_exited(body) -> void:
	if body.is_in_group("Player"):
		$EndpointAlpha/Prompt.visible = false
		_on_alpha = false

#on exit beta
func _on_EndpointBeta_body_exited(body) -> void:
	if body.is_in_group("Player"):
		$EndpointBeta/Prompt.visible = false
		_on_beta = false

#logic for endpoint teleport call
func _teleportPlayerToEndpoint(targetEndpointEnumValue: int) -> void:
	if !_on_cooldown:
		var position = Vector2()
		if targetEndpointEnumValue == EndpointEnum.ALPHA:
			position = $EndpointAlpha/ToAlphaTeleportPosition.get_global_position()
		elif targetEndpointEnumValue == EndpointEnum.BETA:
			position = $EndpointBeta/ToBetaTeleportPosition.get_global_position()
		else:
			push_error("Invalid target endpoint.")
			return
		_startInteractionTimeout()
		emit_signal("TeleportActivated", position, FadeAnimationTime)
		#TransitionsManager.TeleportPlayerToPosition(position, FadeAnimationTime)

#cooldown for interaction
func _startInteractionTimeout() -> void:
	if !_on_cooldown:
		_on_cooldown = true
		yield(get_tree().create_timer(_interactionTimeout), "timeout")
		_on_cooldown = false
