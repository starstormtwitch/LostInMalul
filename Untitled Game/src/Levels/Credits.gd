extends Node2D

const section_time := 3.0
const line_time := 1
const base_speed := 25
const speed_up_multiplier := 10.0
const title_color := Color.lightblue

var scroll_speed := base_speed
var speed_up := false

onready var line := $CreditsContainer/Line
var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"Lost In Malul"
	],[
		"This is a game by and for Lirik's community",
	],[
		"Project Lead/Lead Pepega",
		"StarStorm"
	],[
		"Lead Programmer",
		"SLGeneration"
	],[
		"Lead Artist",
		"Weelqa"
	],[
		"Artist",
		"placeholder"
	],[
		"Sound and Music",
		"placeholder"
	],[
		"Testers",
		"placeholder",
	],[
		"Tools used",
		"Developed with Godot Engine",
		"https://godotengine.org/license",
		"",
		"Art created with",
		"Krita",
		"Aseprite",
		"",
		"Free sounds from",
		"ZapSplat.com",
	],[
		"Special thanks",
		"Charlemagne420, for always being there.",
	]
]

func _ready():
	MusicManager.playMenuMusic()

func _process(delta):
	var scroll_speed = base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.rect_position.y -= scroll_speed
			if l.rect_position.y < -l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()


func finish():
	if not finished:
		finished = true
		var gameScene = LevelGlobals.GetLevelScene("MainMenu");
		assert(gameScene != null, "Unknown level!");
		get_tree().change_scene_to(gameScene);


func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		new_line.add_color_override("font_color", title_color)
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false
