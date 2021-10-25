extends Node2D

var player

func _ready():
  $Timer.connect("timeout", self, "remove_trail")

func remove_trail():
  player._trail.erase(self)
  queue_free()
