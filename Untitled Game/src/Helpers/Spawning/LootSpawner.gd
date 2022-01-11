extends "res://src/Helpers/Spawning/Spawner.gd"

#Names must match enum exactly
const COIN = preload("res://src/Pickups/Coin.tscn")

#const powerUpDict = {
#	"Health" : preload("res://src/Actors/SlimeFR.tscn"),
#	"Defense" : preload("res://src/Actors/SlimeFR.tscn"),
#	"Damage" : preload("res://src/Actors/SlimeFR.tscn")
#}  

export(int) var MinCoins = 1
export(int) var MaxCoins = 1
export(bool) var DropsPowerup = true
export(bool) var AutomaticOnDeath = true

var EnemiesLeft = 1;

func _ready():
	count = 0
	_countToSpawn = 0
	assert(MinCoins <= MaxCoins, "Cannot have a min more than max")
	if(AutomaticOnDeath):
		var parent = get_parent()
		assert(parent != null && parent is Actor, "No parent actor in scene to check death of")
		parent.connect("died", self, "on_death_loot")

func spawnLoot():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if(MaxCoins > 0):
		_countToSpawn += rng.randi_rand(MinCoins, MaxCoins)
		spawnMultipleInArea(COIN)
#	if(DropsPowerup == true):
#		_countToSpawn += 1
#		var indexToSpawn = rng.randi_rant(0, powerUpDict.size()-1)
#		var powerups = powerUpDict.values()
#		spawnMultipleInArea(powerUpDict[powerups[indexToSpawn]])

func on_death_loot():
	 spawnLoot()
	
