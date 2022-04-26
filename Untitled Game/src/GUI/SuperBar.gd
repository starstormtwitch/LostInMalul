extends HBoxContainer

class_name SuperBar

const _orb_full = preload("res://assets/GUI/orb_blue.png")
const _orb_empty = preload("res://assets/GUI/orb_blue_transparent.png")

onready var one: TextureRect = $"1"
onready var two: TextureRect = $"2"
onready var three: TextureRect = $"3"


func _ready():
	_connectToPlayer()


func _connectToPlayer():
	var player: LirikYaki = LevelGlobals.GetPlayerActor()
	player.connect("super_charge_change", self, "update_bar")
	update_bar(LirikYaki.STARTING_SUPER_CHARGES)


func update_bar(value: int):
	for i in get_child_count():
		if value > i:
			get_child(i).texture = _orb_full
		else:
			get_child(i).texture = _orb_empty
