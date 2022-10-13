extends Node2D


var listOfColor : Array = ["aqua","blue","fuchsia","green","lime","maroon","navy","purple","red","teal","yellow"]
var badText : Array = ["you sucks!", "i made a new account pls don't ban this one", "Next game please", "bro you are so cringe fr", "this is just a clone of an older game", "ples click this link -> definitelyavirus.com", "BOOBA pls show bobs"]
var goodText : Array = ["you are so pog", "hey man, i just wanted you to know my wife left me, she took the dog, the house, the kids, my gaming pc, everything, and you help me get through it cheers bud", "that is so poggers, can you please do that again so i can show my mom?", "I LOOOOOOVE THIS GAME", "Pog Pog Pog Pog Pog Pog", "KEKW My streamer", "did u check out the new star citizen update", "how do i check the vod, i cant find it", "i am 10", "get em!", "hahaha", "???", "HHUH", "oh my", "can som1 tell how sub???"]

const approveSound = preload("res://assets/audio/BubblePop.mp3")
const banSound = preload("res://assets/audio/thud.mp3")
const failSound = preload("res://assets/audio/ratSoldierDeath.mp3")
onready var line := $ChatterLine
var bestStreak = 0;
var currentStreak = 0; 
var lines := []
onready var _animationTree: AnimationTree = $KinematicSprite/AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicManager.playNoMusic()
	$CreditsContainer.rect_clip_content = true
	for i in 10:
		add_line()

var my_style = StyleBoxFlat.new()
func add_line():
	var new_line = line.duplicate()
	$CreditsContainer.add_child(new_line)
	new_line.Bad = randi() % 5 > 3
	my_style.set_bg_color(Color(1,.1,.1,.5))
	new_line.visible = true;	
	if(new_line.Bad == true):
		new_line.set("custom_styles/normal", my_style)
	var textToUse;
	if(new_line.Bad == true):
		textToUse = badText[randi() % badText.size()]
	else:
		textToUse = goodText[randi() % goodText.size()]
	new_line.bbcode_text = "[b][color=" + listOfColor[randi() % listOfColor.size()] + "]Some Chatter[/color]:" + textToUse + "[/b]";#get random text line here for banning
	lines.append(new_line)
	$CreditsContainer.add_child(new_line)
	$CreditsContainer.move_child(new_line,0)

func GetChatterLines():
	return $CreditsContainer.get_children();

func EndMiniGame():
	currentStreak = 0;
	$StreakCount.text = str(currentStreak);

func AddToStreak():
	currentStreak = currentStreak + 1;
	if(currentStreak > bestStreak):
		bestStreak = currentStreak;
		$StreakCount2.text = str(currentStreak);
	$StreakCount.text = str(currentStreak);

func _input(event: InputEvent) -> void:
	var topChatter = GetChatterLines().back()
	if (event.is_action_released("minigame_left")):
		_animationTree.get("parameters/playback").travel("SideSwipeRightKick")
		$KinematicSprite.position = $LeftPosition.position;
		$KinematicSprite/Sprite.flip_h = false;
		if(topChatter.Bad):
			SoundPlayer.playSound(self, failSound, 0)
			EndMiniGame();
		else:
			SoundPlayer.playSound(self, approveSound, 0)
			AddToStreak()
		add_line()
		topChatter.queue_free()
	elif (event.is_action_released("minigame_right")):
		_animationTree.get("parameters/playback").travel("SideSwipeRightKick")
		$KinematicSprite.position = $RightPosition.position;
		$KinematicSprite/Sprite.flip_h = true;
		if(topChatter.Bad):
			SoundPlayer.playSound(self, banSound, 0)
			AddToStreak()
		else:
			SoundPlayer.playSound(self, failSound, 0)
			EndMiniGame();
		add_line()
		topChatter.queue_free()
	elif (event.is_action_released("minigame_exit")):
		var gameScene = LevelGlobals.GetLevelScene("MainMenu");
		assert(gameScene != null, "Unknown level!");
		get_tree().change_scene_to(gameScene);
