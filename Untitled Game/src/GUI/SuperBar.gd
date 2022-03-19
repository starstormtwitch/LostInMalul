extends HBoxContainer

class_name SuperBar

var orb_full = preload("res://assets/GUI/orb_blue.png")
var orb_empty = preload("res://assets/GUI/orb_blue_transparent.png")

onready var one: TextureRect = $"1"
onready var two: TextureRect = $"2"
onready var three: TextureRect = $"3"

func update_bar(value):
	for i in get_child_count():
		if value > i:
			get_child(i).texture = orb_full
		else:
			get_child(i).texture = orb_empty
