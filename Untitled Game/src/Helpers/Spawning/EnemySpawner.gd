extends "res://src/Helpers/Spawning/Spawner.gd"

#Names must match enum exactly
const enemyDict = {
	"Slime" : preload("res://src/Actors/Slime.tscn"),
	"SlimeFR" : preload("res://src/Actors/SlimeFR.tscn")
}  
export(String, "Slime", "SlimeFR") var enemy = "Slime"

export(int) var level = 1
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
	for enemy in enemiesSpawned:
		enemy.connect("_exit_tree", self, "check_enemies_disposed")
	pass

func check_enemies_disposed():
	EnemiesLeft = EnemiesLeft - 1;
	if(EnemiesLeft == 0):
	 emit_signal("AllEnemiesDefeated")

