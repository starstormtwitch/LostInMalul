extends KinematicBody2D

export (int) var speed = 100.0
var state_machine

#car horn audio 
var AudioPlayer = AudioStreamPlayer.new();
var first_time = true
var is_playing = false



func _process(delta):
	var movement_direction := Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		movement_direction.y = -1
	if Input.is_action_pressed("move_down"):
		movement_direction.y = 1
	if Input.is_action_pressed("move_left"):
		movement_direction.x = -1
	if Input.is_action_pressed("move_right"):
		movement_direction.x = 1
		
	
	
	movement_direction = movement_direction.normalized()
	move_and_slide(movement_direction * speed)
	
	if Input.is_action_pressed("interact"):
		if  first_time:
			self.add_child(AudioPlayer);
			AudioPlayer.stream = load("res://assets/Mogno/Race/car horn.mp3");
			first_time = false
		if not AudioPlayer.playing :
			AudioPlayer.play(true);			
			is_playing = true
			


