extends Position2D

signal spawned(spawn)
	
func spawn(scene_spawn : PackedScene, position : Vector2):
	#create instance of the actor scene
	var spawnling = scene_spawn.instance();
	
	#add instance to spawner
	add_child(spawnling);
	#node ignores it's parents transformations, only transforms to global space
	spawnling.set_as_toplevel(true);
	
	spawnling.global_position = position;
	
	emit_signal("spawned", spawnling);
	return spawnling;

func spawnOutsideVision(scene_spawn : PackedScene, position : Vector2, player : Object):
	pass
	
