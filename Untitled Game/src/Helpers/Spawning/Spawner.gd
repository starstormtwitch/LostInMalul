extends VisibilityNotifier2D

signal spawned(spawn)

export(bool) var only_off_screen = false
export(int) var duration_between_spawn = 0
export(int) var count = 1

var _countToSpawn = 1

var prime_off_screen_add = false;
var packed_scene;

func _ready():
	_countToSpawn = count;

func spawn(scene_spawn : PackedScene, position : Vector2):
	#node ignores it's parents transformations, only transforms to globalwa space
	#must find the highest ysort
	var parent = get_parent()
	while(parent != null && not parent is YSort):
		parent = parent.get_parent()
	assert(parent != null && parent is YSort, "No parent YSORT in scene")
	
	#create instance of the actor scene
	#add instance to spawner, defer call in case parent is still being setup
	if not only_off_screen || not is_on_screen():
		if(_countToSpawn > 0):
			_countToSpawn=_countToSpawn-1;
			var spawnling = scene_spawn.instance();
			parent.call_deferred("add_child", spawnling);
			spawnling.global_position = position; 
			emit_signal("spawned", spawnling);
			return spawnling;
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

func _on_Spawner_screen_exited():
	if(prime_off_screen_add && packed_scene != null):
		spawnMultipleInArea(packed_scene)
	pass # Replace with function body.
