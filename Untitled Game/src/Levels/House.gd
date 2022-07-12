extends BaseLevelScript

var basement_Key : PackedScene = preload("res://src/InventoryItems/BasementKey.tscn")
var garage_Key : PackedScene = preload("res://src/InventoryItems/GarageKey.tscn")
var plunger : PackedScene = preload("res://src/InventoryItems/Plunger.tscn")
var screwdriver : PackedScene = preload("res://src/InventoryItems/Screwdriver.tscn")
var socks : PackedScene = preload("res://src/InventoryItems/ComfySocks.tscn")
var trophy : PackedScene = preload("res://src/InventoryItems/Trophy.tscn")
var pillow : PackedScene = preload("res://src/InventoryItems/Pillow.tscn")
var candle : PackedScene = preload("res://src/InventoryItems/Candle.tscn")
const dropped_item = preload("res://src/InventoryItems/DroppedItemBase.tscn")
const spawner = preload("res://src/Helpers/Spawning/Spawner.tscn")

var _player : Actor
const _MENU_EVENT: String = "Menu"
const _UI_CANCEL_EVENT: String = "ui_cancel"

var _menuOpen: bool = false
var _sendKitchenCrash: bool = false
var _leftBasementDefeated: bool = false
var _Garage2Defeated: bool = false
var _Garage3Defeated: bool = false
var _Garage4Defeated: bool = false
var _Garage5Defeated: bool = false
var _pickedUpBasementKey: bool = false
var _toiletClogged: bool = true
var _pickedUpPlunger: bool = false
var _pickedUpTrophy: bool = false
var _pickedUpSocks: bool = false
var _pickedUpPillow: bool = false
var _pickedUpCandle: bool = false
var _pickedUpScrewdriver: bool = false
var _rightBasementDefeated: bool = false
var ratKing

onready var _textBox: TextBox = $GUI/TextBox

# Called when the node enters the scene tree for the first time.
func _ready():
	_player = LevelGlobals.GetPlayerActor()
	assert(is_instance_valid(_player),"Player instance invalid")
	_player.connect("coin_changed", self, "_on_Player_coin_changed")
	$GUI/PlayerGui/Coins.text = String(_player.Coins);
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)
	SetLevelCheckpointVariables(LevelGlobals.GetPlayerSaveData())
	
func SetLevelCheckpointVariables(saveData):
	assert(saveData.has("checkpoint"))
	match(saveData["checkpoint"]):
		"Start":
			get_node("YSort/Actors/BedroomFight2").Disable()
			get_node("YSort/Actors/BedroomFight1").Disable()
			pass;
		"FirstEnemy":
			_toiletClogged = false;
			_pickedUpPlunger = true;
			_sendKitchenCrash = false;
			get_node("YSort/Actors/BedroomFight1").Disable()
			get_node("YSort/Actors/BedroomFight2").Disable()
			get_node("YSort/Actors/LivingFight2").Disable()
			get_node("YSort/Actors/LivingFight1").Disable()
			get_node("YSort/Actors/GarageFight2").Disable()
			get_node("YSort/Actors/GarageFight1").Disable()
			get_node("YSort/Actors/KitchenFight1").Disable()
			get_node("YSort/Actors/KitchenFight2").Disable()
			get_node("YSort/Actors/OfficeFight1").Disable()
			get_node("YSort/Actors/OfficeFight2").Disable()
			get_node("YSort/Actors/FoyerFight").Disable()
			get_node("YSort/Actors/BasementFight").Disable()
			get_node("LevelBackground/Interactions/Bedroom/StreamRoomTooSoon/CollisionShape").set_deferred("disabled", true);
			get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
			get_node("LevelBackground/Interactions/Bathroom/Toilet/CollisionShape").set_deferred("disabled", true);
			get_node("YSort/Actors/GrannySpawner").spawnEnemy()
			get_node("LevelBackground/Teleports/Streaming_LivingRoom_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
			get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", false);
			StartupPlayerInPosition(Vector2(1700, 275), 5)
		"Boss":
			get_node("LevelBackground/Boundaries/Basement/Lockout").set_deferred("disabled", false);
			StartupPlayerInPosition(Vector2(200, 575), 5)
			get_node("LevelBackground/Teleports/Kitchen_Basement_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", true);
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

func _on_Toilet_interactable_text_signal(text):
	if($GUI/PlayerGui/Inventory.InventoryItem != null && $GUI/PlayerGui/Inventory.InventoryItem.name == "Plunger"):
		_sendKitchenCrash = true;
		_textBox.showText("*Unclogs toilet with plunger and takes morning poop*")
		_player.delete_item_from_inventory()
		_toiletClogged = false;
		get_node("LevelBackground/Interactions/Bedroom/StreamRoomTooSoon/CollisionShape").set_deferred("disabled", true);
		get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
		get_node("YSort/Actors/BedroomFight1").Enable()
		get_node("YSort/Actors/BedroomFight2").Enable()
	elif(!_toiletClogged):
		_textBox.showText(text)
	else: 
		_textBox.showText("The toilet is clogged, I think I put a plunger underneath the sink.")

func _on_TextBox_closed():
	if(_sendKitchenCrash):
		_sendKitchenCrash = false
		_textBox.showText("*crashing noise* I better go check out what happened. Looks like the power shut off, I'll have to fire up my generator before I can turn on my pc...")

func _on_Boss_health_changed(_oldHealth, newHealth, maxHealth):
	var progressValue = (float(newHealth) / float(maxHealth)) * 100.00
	$GUI/BossGui/ProgressBar.set_value(progressValue);

func _on_LirikYaki_item_pickup(item : Node2D):
	$GUI/PlayerGui/Inventory.InventoryItem = item;
	
func _on_LirikYaki_item_delete():
	$GUI/PlayerGui/Inventory.InventoryItem.queue_free()
	$GUI/PlayerGui/Inventory.InventoryItem = null; 

func _on_FoyerEndTable_interactable_text_signal(text):
	_textBox.showText(text)
	if(!_pickedUpBasementKey):
		_pickedUpBasementKey = true;
		_player.add_item_to_inventory(garage_Key.instance())
		$LevelBackground/Interactions/Foyer/FoyerEndTable.interactableText = "Just a lamp."
	pass # Replace with function body.

func _on_BasementNeedKey_interactable_text_signal(text):
	if($GUI/PlayerGui/Inventory.InventoryItem != null && $GUI/PlayerGui/Inventory.InventoryItem.name == "BasementKey"):
		_textBox.showText("*Unlocks door with basement key*")
		_player.delete_item_from_inventory()
		get_node("LevelBackground/Interactions/Kitchen/BasementNeedKey/CollisionShape").set_deferred("disabled", true);
		get_node("LevelBackground/Teleports/Kitchen_Basement_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
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
		$LevelBackground/Interactions/Garage/WorkBench.interactableText = "I have all these tools, and no idea how to use them."
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
		_textBox.showText("*Wedges the screwdriver in the drawer and pops it open*"+ text)
		_player.delete_item_from_inventory()
		_pickedUpPillow = true
		_player.add_item_to_inventory(pillow.instance())
		get_node("LevelBackground/Interactions/Kitchen/Drawer/CollisionShape").set_deferred("disabled", true);
	else: 
		_textBox.showText("The drawer is stuck closed, maybe a screwdriver would help... but where did I put one...")


func _on_TVStand_interactable_text_signal(text):
	_textBox.showText(text)
	if(!_pickedUpCandle):
		_pickedUpCandle = true
		_player.add_item_to_inventory(candle.instance())
		get_node("LevelBackground/Interactions/LivingRoom/TVStand/CollisionShape").set_deferred("disabled", true);
	pass # Replace with function body.

func _on_GarageNeedKey_interactable_text_signal(text):
	if($GUI/PlayerGui/Inventory.InventoryItem != null && $GUI/PlayerGui/Inventory.InventoryItem.name == "GarageKey"):
		_textBox.showText("*Unlocks door with garage key*")
		$GUI/PlayerGui/Inventory.InventoryItem.queue_free()
		$GUI/PlayerGui/Inventory.InventoryItem = null; 
		get_node("LevelBackground/Interactions/Foyer/GarageNeedKey/CollisionShape").set_deferred("disabled", true);
		get_node("LevelBackground/Teleports/Foyer_Garage_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
	else: 
		_textBox.showText(text)

func GetReadyForBossEncounter():
	_textBox.showText("I think that's all of them.")
	get_node("YSort/Actors/RatKingSpawner").call_deferred("spawnEnemy")
	get_node("LevelBackground/Boundaries/Basement/BossSeperator").set_deferred("disabled", true);

func _on_GrannySpawner_AllEnemiesDefeated():
	_textBox.showText("Grandma has faded away comfy, and she left you a little something.")
	_player.add_item_to_inventory(basement_Key.instance())

func AllDefeatedGarage():
	get_node("YSort/Actors/BathroomSpawner").spawnEnemy()
	get_node("YSort/Actors/BedroomSpawner").spawnEnemy()
	get_node("YSort/Actors/OfficeSpawner").spawnEnemy()
	get_node("YSort/Actors/LivingRoomSpawner").spawnEnemy()
	get_node("YSort/Actors/KitchenSpawner").spawnEnemy()
	get_node("YSort/Actors/FoyerSpawner").spawnEnemy()
	get_node("YSort/Actors/GarageSpawner").spawnEnemy()
	get_node("LevelBackground/Teleports/Foyer_Garage_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", false);

func _on_BossEncounter_body_entered(body):
	if (body == _player):
		get_node("GUI/PlayerGui/ContinueRight").stop_blinking()
		get_node("LevelBackground/Interactions/Basement/BossEncounter/BossEncounterCollision").set_deferred("disabled", true);
		_textBox.showText("Rat King: So... you think you can take your house back from me? I'm afraid that can't happen... you see, us rats are sick of living in this damp disgusting basement.  We will enjoy this house better than you ever did, and now I'll make sure you never hurt a rat again.")
		ratKing._target = _player;
		ratKing._mobSpawnArea = get_node("LevelBackground/SpecialZones/BossMobZone/CollisionShape");		
		$GUI/BossGui.set_deferred("visible", true);

func _on_RatKingSpawner_spawned(spawn):
	ratKing = spawn
	spawn.connect("health_changed", self, "_on_Boss_health_changed")
	$GUI/BossGui/ProgressBar.set_deferred("value",   (spawn._health / spawn._maxHealth) * 100);

func _on_RatKingSpawner_AllEnemiesDefeated():
	LevelGlobals.SetCheckpoint("Streets", "Start");
	LevelGlobals.save_game();
	LevelGlobals.load_checkpoint();

func _on_BedroomFight1_lockout_started():
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()
	_textBox.showText("I think I know what that is... but how is it alive?! \n Left click to attack")
	get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", true);
	get_node("LevelBackground/Teleports/Bathroom_Bedroom_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", true);

func _on_BedroomFight1_lockout_finished():
	_textBox.showText("That was insane, it had to have come from the basement...")
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()
	
func _on_BedroomFight2_lockout_started():
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()

func _on_BedroomFight2_lockout_finished():
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()
	get_node("LevelBackground/Teleports/Bathroom_Bedroom_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", false);
	get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
	
func _on_OfficeFight1_lockout_started():
	get_node("LevelBackground/Teleports/Streaming_LivingRoom_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", true);
	get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", true);
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()
	
func _on_OfficeFight1_lockout_finished():
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()

func _on_OfficeFight2_lockout_started():
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()

func _on_OfficeFight2_lockout_finished():
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()
	get_node("LevelBackground/Teleports/Streaming_LivingRoom_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", false);
	get_node("LevelBackground/Teleports/Bedroom_Streaming_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);

func _on_LivingFight1_lockout_started():
	get_node("LevelBackground/Teleports/LivingRoom_Kitchen_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", true);
	get_node("LevelBackground/Teleports/Streaming_LivingRoom_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", true);
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()
	
func _on_LivingFight1_lockout_finished():
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()

func _on_LivingFight2_lockout_started():
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()
	
func _on_LivingFight2_lockout_finished():
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()
	get_node("LevelBackground/Teleports/LivingRoom_Kitchen_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
	get_node("LevelBackground/Teleports/Streaming_LivingRoom_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", false);

func _on_KitchenFight1_lockout_started():
	get_node("LevelBackground/Teleports/Kitchen_Foyer_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", true);
	get_node("LevelBackground/Teleports/LivingRoom_Kitchen_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", true);
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()
	
func _on_KitchenFight1_lockout_finished():
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()

func _on_KitchenFight2_lockout_started():
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()

func _on_KitchenFight2_lockout_finished():
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()
	get_node("LevelBackground/Teleports/Kitchen_Foyer_2WT/EndpointAlpha/ToBetaActivationArea").set_deferred("disabled", false);
	get_node("LevelBackground/Teleports/LivingRoom_Kitchen_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", false);

func _on_FoyerFight_lockout_started():
	get_node("LevelBackground/Teleports/Kitchen_Foyer_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", true);
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()
	
func _on_FoyerFight_lockout_finished():
	_textBox.showText("I need to find the basement key now that the house is cleared out... I think it might be in the garage.")
	get_node("LevelBackground/Teleports/Kitchen_Foyer_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", false);
	get_node("LevelBackground/Interactions/Foyer/GarageNeedKey/CollisionShape").set_deferred("disabled", false);

func _on_GarageFight1_lockout_started():
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()
	get_node("LevelBackground/Teleports/Foyer_Garage_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", true);

func _on_GarageFight1_lockout_finished():
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()

func _on_GarageFight2_lockout_started():
	get_node("GUI/PlayerGui/ContinueRight").stop_blinking()

func _on_GarageFight2_lockout_finished():
	get_node("LevelBackground/Teleports/Foyer_Garage_2WT/EndpointBeta/ToAlphaActivationArea").set_deferred("disabled", false);
	get_node("YSort/Actors/GrannySpawner").spawnEnemy()
	_textBox.showText("Is that grandma's laugh I just heard? She has the key to the basement. I better find some comfy items to give to grandma to make her happy.")
	AllDefeatedGarage();
	
func _on_BasementFight_lockout_started():
	_textBox.showText("That's a lot of rats, I have a bad feeling about this.")
	
func _on_BasementFight_lockout_finished():
	get_node("GUI/PlayerGui/ContinueRight").start_blinking()
	GetReadyForBossEncounter();

