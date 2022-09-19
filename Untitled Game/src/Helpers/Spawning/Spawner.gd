extends VisibilityNotifier2D

signal spawned(spawn)
signal despawned

export(bool) var only_off_screen = false
export(int) var duration_between_spawn = 0
export(int) var count = 1
export(int) var maxSpawnedAtATime = 10;

var CurrentSpawnedCount = 0;

var _countToSpawn = 1

var spawnWhenDespawned = false;
var prime_off_screen_add = false;
var packed_scene;

class_name spawner

func _ready():
	_countToSpawn = count;

func spawnInstantiatedNode(node : Node2D, position : Vector2):
	#node ignores it's parents transformations, only transforms to globalwa space
	#must find the highest ysort
	var parent = get_parent()
	while(parent != null && not parent is YSort):
		parent = parent.get_parent()
	assert(parent != null && parent is YSort, "No parent YSORT in scene")
	
	#add instance to spawner, defer call in case parent is still being setup
	if(_countToSpawn > 0 && CurrentSpawnedCount < maxSpawnedAtATime):
		_countToSpawn=_countToSpawn-1;
		node.connect("tree_exiting", self, "_despawned")
		parent.call_deferred("add_child", node);
		node.global_position = position; 
		CurrentSpawnedCount = CurrentSpawnedCount + 1;
		emit_signal("spawned", node);
		return node;


func spawn(scene_spawn : PackedScene, position : Vector2):
	#node ignores it's parents transformations, only transforms to globalwa space
	#must find the highest ysort
	var parent = get_parent()
	while(parent != null && not parent is YSort):
		parent = parent.get_parent()
	assert(parent != null && parent is YSort, "No parent YSORT in scene")
	spawnWhenDespawned = false;
	prime_off_screen_add = false;
	
	#create instance of the actor scene
	#add instance to spawner, defer call in case parent is still being setup
	if (not only_off_screen || not is_on_screen()) && CurrentSpawnedCount < maxSpawnedAtATime:
		if(_countToSpawn > 0):
			_countToSpawn=_countToSpawn-1;
			var spawnling = scene_spawn.instance();
			parent.call_deferred("add_child", spawnling);
			spawnling.connect("tree_exiting", self, "_despawned")
			spawnling.global_position = position; 
			CurrentSpawnedCount = CurrentSpawnedCount + 1;
			emit_signal("spawned", spawnling);
			return spawnling;
	elif(CurrentSpawnedCount >= maxSpawnedAtATime):
		spawnWhenDespawned = true;
		packed_scene = scene_spawn;
		return null;
	else:
		prime_off_screen_add = true;
		packed_scene = scene_spawn;
		return null;
	
	
func spawnMultiple(scene_spawn : PackedScene):
	var spawnlings = []
	for i in _countToSpawn:
		var spawnling = spawn(scene_spawn, $Spawner.Position)
		spawnlings.append(spawnling)
	return spawnlings; 

func spawnMultipleInArea(scene_spawn : PackedScene):
	assert(scene_spawn != null, "scene is null!")
	var spawnlings = []
	var t = Timer.new()
	add_child(t)
	for i in _countToSpawn:
		#Change spawn location randomly
		var spawnPosition = self.global_position + Vector2(randf() * self.rect.size.x, randf() * self.rect.size.y)
		var spawnling = spawn(scene_spawn, spawnPosition)
		spawnlings.append(spawnling)
		#Delay after spawning
		if(duration_between_spawn > 0):
			t.set_wait_time(duration_between_spawn)
			t.set_one_shot(true)
			t.start()
			yield(t, "timeout")
	return spawnlings;
	
func _despawned():
	CurrentSpawnedCount = CurrentSpawnedCount - 1;
	emit_signal("despawned");
	if(prime_off_screen_add && packed_scene != null):
		spawnMultipleInArea(packed_scene)

func _on_Spawner_screen_exited():
	if(spawnWhenDespawned && packed_scene != null):
		spawnMultipleInArea(packed_scene)
	pass # Replace with function body.
