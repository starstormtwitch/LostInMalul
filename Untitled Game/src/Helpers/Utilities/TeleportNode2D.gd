extends Node2D

const _interactionTimeout: float = 1.0

enum EndpointEnum {ALPHA = 0, BETA = 1} #used to validate target endpoint on teleport function

var _on_alpha: bool = false
var _on_beta: bool = false
var _on_cooldown: bool = false

##If enabled a promp with a key will be shown that needs to be pressed to trigger the teleport.
export var RequirePlayerAction: bool = true
##If enabled a fade in/out effect will play along with the teleport.
export var PlayFadeAnimation: bool = false

func _onready() -> void:
	$EndpointAlpha/PromptAlpha.visible = false
	$EndpointBeta/PromptBeta.visible = false

#capute user input events
func _input(event: InputEvent) -> void:
	if event.is_action("interact"):
		if _on_alpha:
			_teleportPlayerToEndpoint(EndpointEnum.ALPHA)
		elif _on_beta:
			_teleportPlayerToEndpoint(EndpointEnum.BETA)

#on enter alpha
func _on_EndpointAlpha_body_entered(body) -> void:
	if body == LevelGlobals.GetPlayerActor():
		if RequirePlayerAction:
			$EndpointAlpha/PromptAlpha.visible = true
			_on_alpha = true
		else:
			_teleportPlayerToEndpoint(EndpointEnum.BETA)

#on enter beta
func _on_EndpointBeta_body_entered(body) -> void:
	if body == LevelGlobals.GetPlayerActor():
		if RequirePlayerAction:
			$EndpointBeta/PromptBeta.visible = true
			_on_beta = true
		else:
			_teleportPlayerToEndpoint(EndpointEnum.ALPHA)

#on exit alpha
func _on_EndpointAlpha_body_exited(body) -> void:
	if body == LevelGlobals.GetPlayerActor():
		$EndpointAlpha/PromptAlpha.visible = false
		_on_alpha = false

#on exit beta
func _on_EndpointBeta_body_exited(body) -> void:
	if body == LevelGlobals.GetPlayerActor():
		$EndpointBeta/PromptBeta.visible = false
		_on_beta = false

#logic for endpoint teleport call
func _teleportPlayerToEndpoint(endpointEnumValue: int) -> void:
	if !_on_cooldown:
		var position = Vector2()
		if endpointEnumValue == EndpointEnum.ALPHA:
			position = $EndpointAlpha/TargetAlpha.get_global_position()
		elif endpointEnumValue == EndpointEnum.BETA:
			position = $EndpointBeta/TargetBeta.get_global_position()
		else:
			push_error("Invalid target endpoint.")
			return
		_startInteractionTimeout()
		TransitionsManager.TeleportPlayerToPosition(position, PlayFadeAnimation)

#cooldown for interaction
func _startInteractionTimeout() -> void:
	if !_on_cooldown:
		_on_cooldown = true
		yield(get_tree().create_timer(_interactionTimeout), "timeout")
		_on_cooldown = false
