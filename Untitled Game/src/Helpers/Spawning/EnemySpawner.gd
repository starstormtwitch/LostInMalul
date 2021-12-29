extends "res://src/Helpers/Spawning/Spawner.gd"

#Names must match enum exactly
const enemyDict = {
	"Slime" : preload("res://src/Actors/Slime.tscn"),
	"SlimeFR" : preload("res://src/Actors/SlimeFR.tscn")
}  
export(String, "Slime", "SlimeFR") var enemy = "Slime"

export(int) var level = 1

func _ready():
	if(automatic):
		spawnEnemy();

func spawnEnemy():
	assert(enemy != null, "Must set enemy in spawner node")
	var enemyToSpawn = enemyDict[enemy]
	spawnMultipleInArea(enemyToSpawn)
	pass
