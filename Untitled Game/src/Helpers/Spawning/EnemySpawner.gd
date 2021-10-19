extends "res://src/Helpers/Spawning/Spawner.gd"

const SLIME = preload("res://src/Actors/Slime.tscn");

func spawnSlime(level:int, amount:int):
	var position = Vector2.ZERO;
	spawn(SLIME, position);
	
	pass 

