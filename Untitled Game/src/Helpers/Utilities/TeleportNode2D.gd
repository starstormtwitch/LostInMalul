extends Node2D

class_name TeleportNode2D

const _interactionTimeout: float = 1.0

var _on_activation_area: bool = false
var _on_cooldown: bool = false

##If enabled a promp with a key will be shown that needs to be pressed to trigger the teleport.
export var RequirePlayerAction: bool = true
##Fade animation time for both steps of the animation (in and out).
export var FadeAnimationTime: float = 0.4

signal TeleportActivated(targetPosition, fadeAnimationTime)

func _init():
	add_to_group("TeleportNode")

func _onready():
	pass

#capute user input events
func _input(event: InputEvent) -> void:
	if event.is_action("interact") && _on_activation_area:
		_teleportPlayerToEndpoint()

func _on_Endpoint_body_entered(body):
	if body.is_in_group("Player"):
		if RequirePlayerAction:
			$Endpoint/Prompt.visible = true
			_on_activation_area = true
		else:
			_teleportPlayerToEndpoint()

func _on_Endpoint_body_exited(body):
	if body.is_in_group("Player"):
		$Endpoint/Prompt.visible = false
		_on_activation_area = false

#logic for endpoint teleport call
func _teleportPlayerToEndpoint() -> void:
	if !_on_cooldown:
		_startInteractionTimeout()
		emit_signal("TeleportActivated", $Endpoint/Target.get_global_position(), FadeAnimationTime)
		#TransitionsManager.TeleportPlayerToPosition($Endpoint/Target.get_global_position(), FadeAnimationTime)

#cooldown for interaction
func _startInteractionTimeout() -> void:
	if !_on_cooldown:
		_on_cooldown = true
		yield(get_tree().create_timer(_interactionTimeout), "timeout")
		_on_cooldown = false
