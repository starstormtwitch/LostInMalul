extends BaseLevelScript


const dropped_item = preload("res://src/InventoryItems/DroppedItemBase.tscn")
const spawner = preload("res://src/Helpers/Spawning/Spawner.tscn")
const _warning_sfx = preload("res://assets/audio/sfx_alarm_loop3.wav")

var _player : Actor
const _MENU_EVENT: String = "Menu"
const _UI_CANCEL_EVENT: String = "ui_cancel"

var _menuOpen: bool = false
var _playingWarningSound = false

onready var _textBox: TextBox = $GUI/TextBox

onready var _leftWarningSign = $GUI/Warnings/WarningSignLeft
onready var _rightWarningSign = $GUI/Warnings/WarningSignRight

# Called when the node enters the scene tree for the first time.
func _ready():
	._ready()
	_cameraManager.zoom = Vector2(.3,.3)
	_player = LevelGlobals.GetPlayerActor()
	assert(is_instance_valid(_player),"Player instance invalid")
	_player.connect("coin_changed", self, "_on_Player_coin_changed")
	$GUI/PlayerGui/Coins.text = String(_player.Coins);
	_player.connect("health_changed", self, "_on_Player_health_changed")
	_on_Player_health_changed(_player._health, _player._health, _player._maxHealth)
	SetLevelCheckpointVariables(LevelGlobals.GetPlayerSaveData())
	_cameraManager._isLevelTwo = true
	
func SetLevelCheckpointVariables(saveData):
	assert(saveData.has("checkpoint"))
	match(saveData["checkpoint"]):
		"Start":
			pass;
	
func _on_Player_coin_changed():
	$GUI/PlayerGui/Coins.text = String(_player.Coins);
	
func _on_Player_health_changed(_oldHealth, newHealth, maxHealth):
	var healthBar = get_node("GUI/PlayerGui/healthBar")
	healthBar.Health = newHealth
	healthBar.MaxHealth = maxHealth
	healthBar.update_health()

func _on_InteractPromptArea_interactable_text_signal(text):
	_textBox.showText(text)

func _on_TextBox_closed():
	pass

# func spawnCar():
	

func _on_LirikYaki_item_pickup(item : Node2D):
	$GUI/PlayerGui/Inventory.InventoryItem = item;

func _on_LirikYaki_item_delete():
	$GUI/PlayerGui/Inventory.InventoryItem.queue_free()
	$GUI/PlayerGui/Inventory.InventoryItem = null; 

func _play_warning_sound() -> void:
	if !_playingWarningSound:
		#print("play warning sounds")
		SoundPlayer.playSound(get_tree().get_current_scene(), _warning_sfx, 0)
		_playingWarningSound = true

func _stop_warning_sound() -> void:
	if _playingWarningSound:
		#print("turn off warning sounds")
		_playingWarningSound = false

func _on_TrafficSystemRight_SpawnWarning():
	#print("right warnign sign")
	_play_warning_sound()
	_rightWarningSign.visible = true
	yield(get_tree().create_timer(2), "timeout")
	_rightWarningSign.visible = false
	_stop_warning_sound()

func _on_TrafficSystemLeft_SpawnWarning():
	#print("left warnign sign")
	_play_warning_sound()
	_leftWarningSign.visible = true
	yield(get_tree().create_timer(2), "timeout")
	_leftWarningSign.visible = false
	_stop_warning_sound()
