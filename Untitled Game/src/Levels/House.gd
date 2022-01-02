extends Node2D

var _player : Actor

var _firstTimeEnteredKitchen: bool = false
var _sendKitchenCrash: bool = false
var _sentKitchenCrash: bool = false

onready var _textBox: TextBox = $GUI/TextBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = LevelGlobals.GetPlayerActor()
	var valid = is_instance_valid(_player)
	if(!valid):
		print("Player instance invalid")
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)
	TransitionsManager.setup()

func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/Control/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()

func _on_InteractPromptArea_interactable_text_signal(text):
	_textBox.showText(text)


func _on_KitchenFirstTime_body_entered(body):
	if body == _player && _firstTimeEnteredKitchen == false:
		_firstTimeEnteredKitchen = true
		_textBox.showText("What in the world is that... it looks like some sort of rat... but what's wrong with it?!")
		get_node("YSort/Actors/KitchenRat").spawnEnemy()
	pass # Replace with function body.


func _on_player_toilet_used():
	#play weird rat noise
	_textBox.showText("*crashing noise* I better go check out that noise. It was probably just one of the cats making a mess.  It sounded like it came from the kitchen.")
	get_node("LevelBackground/Interactions/Bedroom/StreamRoomTooSoon/CollisionShape").disabled = true;
	get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").disabled = false;
	pass # Replace with function body.


func _on_Toilet_interactable_text_signal(text):
	_sendKitchenCrash = true;
	get_node("LevelBackground/Interactions/Bathroom/Toilet/CollisionShape").disabled = true;


func _on_TextBox_closed():
	if(_sendKitchenCrash):
		_sendKitchenCrash = false
		_on_player_toilet_used()


func _on_KitchenRat_AllEnemiesDefeated():
	_textBox.showText("That was insane, it had to have come from the basement. I should go down there... but I should mentally prepare myself for what could possibly be down there first.")
	get_node("LevelBackground/Teleports/Kitchen_Basement_2WT/EndpointAlpha/ToBetaActivationArea").disabled = false;
