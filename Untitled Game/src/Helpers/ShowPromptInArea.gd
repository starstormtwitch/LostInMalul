extends Area2D

const _PLAYER_NAME: String = "LirikYaki"

onready var _prompt: Sprite = $F_Prompt


# signal event to show the prompt, if player walks in the area
func _show_prompt_if_player_within_body(body: PhysicsBody2D) -> void:
	#print("body entered: " + body.name)
	if body.name == _PLAYER_NAME:
		_prompt.visible = true


# signal event to hide the prompt, if player leaves the area
func _hide_prompt_if_player_leaves_body(body: PhysicsBody2D) -> void:
	#print("body exited: " + body.name)
	if body.name == _PLAYER_NAME:
		_prompt.visible = false
