extends Area2D

export var LevelName = "ChangeToLevelName"
export var CheckpointName = "ChangeToUniqueName"

func _on_Checkpoint_body_entered(body):
	if body.is_in_group("Player"):
		$CheckpointArea.set_deferred("disabled", true);
		LevelGlobals.SetCheckpoint(LevelName, CheckpointName);
		LevelGlobals.save_game();
