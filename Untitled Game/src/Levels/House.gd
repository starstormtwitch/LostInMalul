extends BaseLevelScript

var _player : Actor
const _MENU_EVENT: String = "Menu"
const _UI_CANCEL_EVENT: String = "ui_cancel"

var _menuOpen: bool = false
onready var _gameMenu: PauseMenu = get_node("GUI/PauseMenu")
var _firstTimeEnteredKitchen: bool = false
var _sendKitchenCrash: bool = false
onready var _textBox: TextBox = $GUI/TextBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = LevelGlobals.GetPlayerActor()
	var valid = is_instance_valid(_player)
	if(!valid):
		print("Player instance invalid")
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)


func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/PlayerGui/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()

func _on_InteractPromptArea_interactable_text_signal(text):
	_textBox.showText(text)


# node to handle player input, and call the proper response
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(_MENU_EVENT) and !_menuOpen:
		_pauseAndShowMenu()
	elif event.is_action_pressed(_MENU_EVENT) and _menuOpen:
		_unpauseAndHideMenu()


func _pauseAndShowMenu() -> void:
	_menuOpen = true
	get_tree().paused = true
	_gameMenu.visible = true


func _unpauseAndHideMenu():
	_menuOpen = false
	get_tree().paused = false
	_gameMenu.visible = false


func loadRatDemo():
	get_tree().paused = false
	get_tree().change_scene("res://src/Demos/PlaytestDemoWithRats.tscn")


func loadSlimeDemo():
	get_tree().paused = false
	get_tree().change_scene("res://src/Demos/PlaytestDemoFR.tscn")


func _on_RestartButton_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_ExitButton_pressed():
	get_tree().quit()


func _on_GoBackButton_pressed():
	_unpauseAndHideMenu()
	

func _on_BasementEnc1_Delimiter_PlayerEnteredAreaDelimiter(delimiter):
	_textBox.showText("That's a lot of rats, I have a bad feeling about this.")
	get_node("YSort/Actors/BasementL1").spawnEnemy()
	get_node("YSort/Actors/BasementR1").spawnEnemy()

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

