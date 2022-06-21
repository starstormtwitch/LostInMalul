extends "res://src/Helpers/Spawning/Spawner.gd"

#Names must match enum exactly
const COIN = preload("res://src/Pickups/Coin.tscn")

const powerUpDict = {
	"Health" : preload("res://src/Pickups/Health.tscn"),
	"Defense" : preload("res://src/Pickups/Defense.tscn"),
	"Damage" : preload("res://src/Pickups/Damage.tscn"), 
	"SuperOrb": preload("res://src/Pickups/SuperOrb.tscn")
}  

export(int) var MinCoins = 1
export(int) var MaxCoins = 1
export(bool) var DropsPowerup = true
export(bool) var AutomaticOnDeath = true
export(int) var PowerupChance = 15

func _ready():
	count = 0
	_countToSpawn = 0
	assert(MinCoins <= MaxCoins, "Cannot have a min more than max")
	if(AutomaticOnDeath):
		var parent = get_parent()
		assert(parent != null && parent is Actor, "No parent actor in scene to check death of")
		parent.connect("died", self, "on_death_loot")

func spawnLoot():
	if(MaxCoins > 0):
		_countToSpawn += LevelGlobals.rng.randi_range(MinCoins, MaxCoins)
		spawnMultipleInArea(COIN)
	if(DropsPowerup == true):
		var spawnOrNotNum = LevelGlobals.rng.randi_range(0, 100)
		if(spawnOrNotNum < PowerupChance):
			_countToSpawn += 1
			var indexToSpawn = LevelGlobals.rng.randi_range(-6, powerUpDict.size()-1)
			if(indexToSpawn < 0): indexToSpawn = 0 #0 should be health so we can increase droprate
			var powerups = powerUpDict.keys()
			spawnMultipleInArea(powerUpDict[powerups[indexToSpawn]])

func on_death_loot():
	 spawnLoot()
	
