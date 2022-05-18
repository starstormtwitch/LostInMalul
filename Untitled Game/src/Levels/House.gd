extends BaseLevelScript

var basement_Key : PackedScene = preload("res://src/InventoryItems/BasementKey.tscn")
var plunger : PackedScene = preload("res://src/InventoryItems/Plunger.tscn")
var screwdriver : PackedScene = preload("res://src/InventoryItems/Screwdriver.tscn")
var socks : PackedScene = preload("res://src/InventoryItems/ComfySocks.tscn")
var trophy : PackedScene = preload("res://src/InventoryItems/Trophy.tscn")
var pillow : PackedScene = preload("res://src/InventoryItems/Pillow.tscn")
var candle : PackedScene = preload("res://src/InventoryItems/Candle.tscn")

var _player : Actor
const _MENU_EVENT: String = "Menu"
const _UI_CANCEL_EVENT: String = "ui_cancel"

var _menuOpen: bool = false
var _firstTimeEnteredKitchen: bool = false
var _sendKitchenCrash: bool = false
var _leftBasementDefeated: bool = false
var _pickedUpBasementKey: bool = false
var _toiletClogged: bool = true
var _pickedUpPlunger: bool = false
var _pickedUpTrophy: bool = false
var _pickedUpSocks: bool = false
var _pickedUpScrewdriver: bool = false
var _rightBasementDefeated: bool = false
var ratKing

signal area_lock

onready var _textBox: TextBox = $GUI/TextBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = LevelGlobals.GetPlayerActor()
	assert(is_instance_valid(_player),"Player instance invalid")
	_player.connect("coin_changed", self, "_on_Player_coin_changed")
	$GUI/PlayerGui/Coins.text = String(_player.Coins);
	if(_infiniteHealth):
		 _player._maxHealth = 20000
		 _player._health = 20000
	else:
		_player.connect("health_changed", self, "_on_Player_health_changed")
		_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)
	SetLevelCheckpointVariables(LevelGlobals.GetPlayerSaveData())
	
func SetLevelCheckpointVariables(saveData):
	assert(saveData.has("checkpoint"))
	match(saveData["checkpoint"]):
		"Start":
			pass;
		"FirstEnemy":
			_toiletClogged = false;
			get_node("LevelBackground/Interactions/Bedroom/StreamRoomTooSoon/CollisionShape").set_deferred("disabled", true);
			get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
			get_node("LevelBackground/Interactions/Bathroom/Toilet/CollisionShape").set_deferred("disabled", true);
			StartupPlayerInPosition(Vector2(2325, 275), 5)
		"Boss":
			_toiletClogged = false;
			get_node("LevelBackground/Interactions/Bedroom/StreamRoomTooSoon/CollisionShape").set_deferred("disabled", true);
			get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
			get_node("LevelBackground/Interactions/Bathroom/Toilet/CollisionShape").set_deferred("disabled", true);
			_firstTimeEnteredKitchen = true
			_pickedUpBasementKey = true
			get_node("LevelBackground/Teleports/LivingRoom_Kitchen_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", false);
			get_node("LevelBackground/Teleports/Kitchen_Foyer_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
			StartupPlayerInPosition(Vector2(175, 575), 5)
		_:
			assert(false, "No matching checkpoint.")
	
func _on_Player_coin_changed():
	$GUI/PlayerGui/Coins.text = String(_player.Coins);
	
func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/PlayerGui/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()

func _on_InteractPromptArea_interactable_text_signal(text):
	_textBox.showText(text)

func _on_KitchenFirstTime_body_entered(body):
	if body == _player && _firstTimeEnteredKitchen == false:
		_firstTimeEnteredKitchen = true
		_textBox.showText("I think I know what that is... but how is it alive?! \n Left click to attack")
		get_node("LevelBackground/Teleports/LivingRoom_Kitchen_2WT/EndpointBeta/ToAlphaActivationArea").disabled = true;
		get_node("LevelBackground/Teleports/Kitchen_Foyer_2WT/EndpointAlpha/ToBetaActivationArea").disabled = true;
		get_node("YSort/Actors/FirstRat").spawnEnemy()
	pass # Replace with function body.

func _on_Toilet_interactable_text_signal(text):
	if($GUI/PlayerGui/Inventory.InventoryItem != null && $GUI/PlayerGui/Inventory.InventoryItem.name == "Plunger"):
		_sendKitchenCrash = true;
		_textBox.showText("*Unclogs toilet with plunger and takes morning poop*")
		$GUI/PlayerGui/Inventory.InventoryItem.queue_free()
		$GUI/PlayerGui/Inventory.InventoryItem = null; 
		_toiletClogged = false;
		get_node("LevelBackground/Interactions/Bedroom/StreamRoomTooSoon/CollisionShape").disabled = true;
		get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").disabled = false;
	elif(!_toiletClogged):
		_textBox.showText(text)
	else: 
		_textBox.showText("The toilet is clogged, I think I put a plunger underneath the sink.")

func _on_TextBox_closed():
	if(_sendKitchenCrash):
		_sendKitchenCrash = false
		_textBox.showText("*crashing noise* I better go check out what happened. Looks like the power shut off, I'll have to fire up my generator before I can turn on my pc...")

func _on_FirstRat_AllEnemiesDefeated():
	_textBox.showText("That was insane, it had to have come from the basement... and is that grandma's laugh I just heard?")
	ratKing = get_node("YSort/Actors/GrannySpawner").spawnEnemy()
	get_node("LevelBackground/Teleports/LivingRoom_Kitchen_2WT/EndpointBeta/ToAlphaActivationArea").disabled = false;
	get_node("LevelBackground/Teleports/Kitchen_Foyer_2WT/EndpointAlpha/ToBetaActivationArea").disabled = false;

func _on_BasementAttack_body_entered(body):
	if (body == _player):
		get_node("LevelBackground/Boundaries/Basement/Lockout").set_deferred("disabled", false);
		get_node("LevelBackground/Interactions/Basement/BasementAttack/BasementAttackCollision").set_deferred("disabled", true);
		_textBox.showText("That's a lot of rats, I have a bad feeling about this.")
		emit_signal("area_lock", true)
		get_node("LevelBackground/CameraPositions/Basement_Fight1").ManualTransition_Enter();
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
	emit_signal("area_lock", false)
	get_node("LevelBackground/CameraPositions/Basement_Fight1").ManualTransition_Exit();
	get_node("LevelBackground/Boundaries/Basement/BossSeperator").disabled = true;
	ratKing[0].connect("health_changed", self, "_on_Boss_health_changed")
	$GUI/BossGui/ProgressBar.set_deferred("value",   (ratKing[0]._health / ratKing[0]._maxHealth) * 100);
	
func _on_Boss_health_changed(_oldHealth, newHealth, maxHealth):
	var progressValue = (float(newHealth) / float(maxHealth)) * 100.00
	$GUI/BossGui/ProgressBar.set_value(progressValue);

func _on_BossEncounter_body_entered(body):
	if (body == _player):
		get_node("LevelBackground/Interactions/Basement/BossEncounter/BossEncounterCollision").set_deferred("disabled", true);
		_textBox.showText("Rat King: So... you think you can take your house back from me? I'm afraid that can't happen... you see, us rats are sick of living in this damp disgusting basement.  We will enjoy this house better than you ever did, and now I'll make sure you never hurt a rat again.")
		ratKing[0]._target = _player;
		ratKing[0]._mobSpawnArea = get_node("LevelBackground/SpecialZones/BossMobZone/CollisionShape");		
		$GUI/BossGui.set_deferred("visible", true);

func _on_RatKingSpawner_AllEnemiesDefeated():
	_textBox.showText("End Of Demo, please restart or choose another level.")

func _on_LirikYaki_item_pickup(item : Node2D):
	$GUI/PlayerGui/Inventory.InventoryItem = item;

func _on_FoyerEndTable_interactable_text_signal(text):
	_textBox.showText(text)
	if(!_pickedUpBasementKey):
		_player.add_item_to_inventory(basement_Key.instance())
		$LevelBackground/Interactions/Foyer/FoyerEndTable.interactableText = "Just a lamp."
	pass # Replace with function body.

func _on_BasementNeedKey_interactable_text_signal(text):
	if($GUI/PlayerGui/Inventory.InventoryItem != null && $GUI/PlayerGui/Inventory.InventoryItem.name == "BasementKey"):
		_textBox.showText("*Unlocks door with basement key*")
		$GUI/PlayerGui/Inventory.InventoryItem.queue_free()
		$GUI/PlayerGui/Inventory.InventoryItem = null; 
		get_node("LevelBackground/Interactions/Kitchen/BasementNeedKey/CollisionShape").disabled = true;
		get_node("LevelBackground/Teleports/Kitchen_Basement_2WT/EndpointAlpha/ToBetaActivationArea").disabled = false;
	else: 
		_textBox.showText(text)


func _on_Sink_interactable_text_signal(text):
	_textBox.showText(text)
	if(!_pickedUpPlunger):
		_pickedUpPlunger = true
		_player.add_item_to_inventory(plunger.instance())
		$LevelBackground/Interactions/Bathroom/Sink.interactableText = "I never really understood the appeal of a double sink."
	pass # Replace with function body.


func _on_WorkBench_interactable_text_signal(text):
	_textBox.showText(text)
	if(!_pickedUpScrewdriver):
		_pickedUpScrewdriver = true
		_player.add_item_to_inventory(screwdriver.instance())
		$LevelBackground/Interactions/Garage/Workbench.interactableText = "I have all these tools, and no idea how to use them."
	pass # Replace with function body.


func _on_Wardrobe_interactable_text_signal(text):
	_textBox.showText(text)
	if(!_pickedUpSocks):
		_pickedUpSocks = true
		_player.add_item_to_inventory(socks.instance())
		$LevelBackground/Interactions/Bedroom/Wardrobe.interactableText = "Some say it's cringe to wear your own merch, but I call it advertising."
	pass # Replace with function body.


func _on_OfficeCabinet_interactable_text_signal(text):
	_textBox.showText(text)
	if(!_pickedUpTrophy):
		_pickedUpTrophy = true
		_player.add_item_to_inventory(trophy.instance())
		$LevelBackground/Interactions/Office/OfficeCabinet.interactableText = "I have this big office cabinet, and nothing to put in it."
	pass # Replace with function body.


func _on_Drawer_interactable_text_signal(text):
	if($GUI/PlayerGui/Inventory.InventoryItem != null && $GUI/PlayerGui/Inventory.InventoryItem.name == "Screwdriver"):
		_sendKitchenCrash = true;
		_textBox.showText("*Wedges the screwdriver in the drawer and pops it open*"+ text)
		$GUI/PlayerGui/Inventory.InventoryItem.queue_free()
		$GUI/PlayerGui/Inventory.InventoryItem = null; 
		_pickedUpPillow = true
		_player.add_item_to_inventory(pillow.instance())
		$LevelBackground/Interactions/Kitchen/Drawer.disabled = true;
	else: 
		_textBox.showText("The drawer is stuck closed, maybe a screwdriver would help... but where did I put one...")

	_textBox.showText(text)
	if(!_pickedUpPillow):
		_pickedUpPillow = true
		_player.add_item_to_inventory(pillow.instance())
		$LevelBackground/Interactions/Office/OfficeCabinet.disabled = true;
	pass # Replace with function body.


func _on_TVStand_interactable_text_signal(text):
	_textBox.showText(text)
	if(!_pickedUpCandle):
		_pickedUpCandle = true
		_player.add_item_to_inventory(candle.instance())
		$LevelBackground/Interactions/LivingRoom/TVStand.disabled = true;
	pass # Replace with function body.


func _on_GarageAttack_body_entered(body):
	if (body == _player):
		get_node("LevelBackground/Interactions/Garage/GarageAttack/GarageAttackCollision").set_deferred("disabled", true);
		emit_signal("area_lock", true)
		get_node("LevelBackground/CameraPositions/Garage_Fight").ManualTransition_Enter();
		get_node("YSort/Actors/BasementL1").spawnEnemy()
