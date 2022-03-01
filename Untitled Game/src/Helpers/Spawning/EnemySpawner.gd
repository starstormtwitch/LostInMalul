extends "res://src/Helpers/Spawning/Spawner.gd"

#Names must match enum exactly
const enemyDict = {
	"Slime" : preload("res://src/Actors/Slime.tscn"),
	"SlimeFR" : preload("res://src/Actors/SlimeFR.tscn"),
	"RatSoldier" : preload("res://src/Actors/RatSoldier.tscn"),
	"RatKing" : preload("res://src/Actors/RatKing/RatKing.tscn")
}  
export(String, "Slime", "SlimeFR", "RatSoldier", "RatKing") var enemy = "Slime"

export(int) var level = 1
export(bool) var automatic = true
signal AllEnemiesDefeated

var EnemiesLeft = 1;

func _ready():
	EnemiesLeft = count;
	if(automatic):
		spawnEnemy();

func spawnEnemy():
	assert(enemy != null, "Must set enemy in spawner node")
	var enemyToSpawn = enemyDict[enemy]
	var enemiesSpawned = spawnMultipleInArea(enemyToSpawn)
	return enemiesSpawned
	

func _despawned():
	EnemiesLeft = EnemiesLeft - 1;
	if(EnemiesLeft < 1):
		emit_signal("AllEnemiesDefeated")
	
	
