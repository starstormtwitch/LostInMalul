extends Node

class_name AreaFreeFight

onready var baseLevelScript  = load("res://src/Levels/Base/BaseLevelScript.gd")

var areaLocked = false;
var currentSpawnersInLockOut: Array


func _ready():
	#make sure there is a customdelimiter2d child for the node for the lock fight
	var children = self.get_children()
	
	#Make sure there is at least one spawner for enemies
	for child in children:
		if child is EnemySpawner:
			currentSpawnersInLockOut.append(child);
	assert(currentSpawnersInLockOut.size() > 0, "No enemy spawners in area lockout!")

func Disable():
	$StartArea/CollisionShape2D.set_deferred("disabled", true);
	
func Enable():
	$StartArea/CollisionShape2D.set_deferred("disabled", false);

func AreaFightStart():
	if !areaLocked:
		areaLocked = true
		NextEnemySpawner();
		
func NextEnemySpawner():
	if areaLocked:
		var spawner = currentSpawnersInLockOut.pop_front()
		if is_instance_valid(spawner):
			spawner.spawnEnemy()
			spawner.connect("AllEnemiesDefeated", self, "NextEnemySpawner")

func _on_StartArea_body_entered(body):
	if body == LevelGlobals.GetPlayerActor():
		$StartArea/CollisionShape2D.set_deferred("disabled", true);
		AreaFightStart();
