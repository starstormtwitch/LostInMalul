extends BaseLevelScript

var _player : Actor
const _MENU_EVENT: String = "Menu"
const _UI_CANCEL_EVENT: String = "ui_cancel"

var _menuOpen: bool = false
var _firstTimeEnteredKitchen: bool = false
var _sendKitchenCrash: bool = false
var _leftBasementDefeated: bool = false
var _rightBasementDefeated: bool = false
var ratKing

onready var _textBox: TextBox = $GUI/TextBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = LevelGlobals.GetPlayerActor()
	var valid = is_instance_valid(_player)
	if(!valid):
		print("Player instance invalid")
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)
	_player.connect("coin_changed", self, "_on_Player_coin_changed")
	$GUI/PlayerGui/Coins.text = String(_player.Coins);
	
func _on_Player_coin_changed():
	$GUI/PlayerGui/Coins.text = String(_player.Coins);
	
func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/PlayerGui/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()

func _on_InteractPromptArea_interactable_text_signal(text):
	_textBox.showText(text)

func _on_BasementEnc1_Delimiter_PlayerEnteredAreaDelimiter(delimiter):
	_textBox.showText("That's a lot of rats, I have a bad feeling about this.")
	get_node("YSort/Actors/BasementL1").spawnEnemy()
	get_node("YSort/Actors/BasementR1").spawnEnemy()

func _on_KitchenFirstTime_body_entered(body):
	if body == _player && _firstTimeEnteredKitchen == false:
		_firstTimeEnteredKitchen = true
		_textBox.showText("What in the world is that... it looks like some sort of rat... but what's wrong with it?!")
		get_node("LevelBackground/Teleports/LivingRoom_Kitchen_2WT/EndpointBeta/ToAlphaActivationArea").disabled = true;
		get_node("LevelBackground/Teleports/Kitchen_Foyer_2WT/EndpointAlpha/ToBetaActivationArea").disabled = true;
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
	get_node("LevelBackground/Teleports/LivingRoom_Kitchen_2WT/EndpointBeta/ToAlphaActivationArea").disabled = false;
	get_node("LevelBackground/Teleports/Kitchen_Foyer_2WT/EndpointAlpha/ToBetaActivationArea").disabled = false;

func _on_BasementAttack_body_entered(body):
	if (body == _player):
		get_node("LevelBackground/Interactions/Basement/BasementAttack/BasementAttackCollision").set_deferred("disabled", true);
		_textBox.showText("That's a lot of rats, I have a bad feeling about this.")
		get_node("LevelBackground/Boundaries/Basement/Lockout").set_deferred("disabled", false);
		get_node("YSort/Actors/BasementL1").spawnEnemy()
		get_node("YSort/Actors/BasementR1").spawnEnemy()


func _on_BasementL1_AllEnemiesDefeated():
	_leftBasementDefeated = true;
	if(_rightBasementDefeated):
		GetReadyForBossEncounter();
		
func _on_BasementR1_AllEnemiesDefeated():
	_rightBasementDefeated = true;
	if(_leftBasementDefeated):
		GetReadyForBossEncounter();
		
func GetReadyForBossEncounter():
	_textBox.showText("I think that's all of them.")
	ratKing = get_node("YSort/Actors/RatKingSpawner").spawnEnemy()
	get_node("LevelBackground/Boundaries/Basement/BossSeperator").disabled = true;
	

func _on_BossEncounter_body_entered(body):
	if (body == _player):
		get_node("LevelBackground/Interactions/Basement/BossEncounter/BossEncounterCollision").set_deferred("disabled", true);
		_textBox.showText("Rat King: So... you think you can take your house back from me? I'm afraid that can't happen... you see, us rats are sick of living in this damp disgusting basement.  We will enjoy this house better than you ever did, and now, I'll make sure you never hurt a rat again.")
		ratKing[0]._target = _player;
		ratKing[0]._mobSpawnArea = get_node("LevelBackground/SpecialZones/BossMobZone/CollisionShape2D");


func _on_RatKingSpawner_AllEnemiesDefeated():
	_textBox.showText("End Of Demo, please restart or choose another level.")
