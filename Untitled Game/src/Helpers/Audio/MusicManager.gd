extends Node2D

onready var menuMusic: AudioStreamPlayer = $MenuMusicStreamPlayer
onready var normalBattleMusic: AudioStreamPlayer = $NormalBattleStreamPlayer
onready var ratKingBossBattleMusic: AudioStreamPlayer = $RatKingBossMusicStreamPlayer
onready var bossBattleMusic: AudioStreamPlayer = $BossMusicStreamPlayer

var menuPos = 0
var normalPos = 0
var lastPlayed
var playing

func playLastMusic():
	if(lastPlayed == "Boss"):
		playBossMusic();
	elif(lastPlayed == "RatBoss"):
		playRatKingBossMusic();
	elif(lastPlayed == "Menu"):
		playMenuMusic();
	elif(lastPlayed == "Normal"):
		playNormalBattleMusic();

func playNoMusic():
	normalBattleMusic.stop()
	menuMusic.stop()
	bossBattleMusic.stop()
	ratKingBossBattleMusic.stop()
	
func playBossMusic():
	lastPlayed = playing;
	playing = "Boss";
	menuPos = menuMusic.get_playback_position()
	normalPos = normalBattleMusic.get_playback_position()
	normalBattleMusic.stop()
	menuMusic.stop()
	if(!bossBattleMusic.playing && !bossBattleMusic.stream_paused):
		bossBattleMusic.play()
	elif(!bossBattleMusic.playing):
		bossBattleMusic.stream_paused = false

func playRatKingBossMusic():
	lastPlayed = playing;
	playing = "RatBoss";
	menuPos = menuMusic.get_playback_position()
	normalPos = normalBattleMusic.get_playback_position()
	normalBattleMusic.stop()
	menuMusic.stop()
	bossBattleMusic.stop()
	if(!ratKingBossBattleMusic.playing && !ratKingBossBattleMusic.stream_paused):
		ratKingBossBattleMusic.play()
	elif(!ratKingBossBattleMusic.playing):
		ratKingBossBattleMusic.stream_paused = false

func playMenuMusic():
	lastPlayed = playing;
	playing = "Menu";
	bossBattleMusic.stop()
	ratKingBossBattleMusic.stop()
	normalPos = normalBattleMusic.get_playback_position()
	normalBattleMusic.stop()
	if(!menuMusic.playing && !menuMusic.stream_paused):
		menuMusic.play()
		menuMusic.seek(menuPos)
	elif(!menuMusic.playing):
		menuMusic.stream_paused = false

func playNormalBattleMusic():
	lastPlayed = playing;
	playing = "Normal";
	menuPos = menuMusic.get_playback_position()
	bossBattleMusic.stop()
	ratKingBossBattleMusic.stop()
	menuMusic.stop()
	if(!normalBattleMusic.playing && !normalBattleMusic.stream_paused):
		normalBattleMusic.play()
		normalBattleMusic.seek(normalPos)
	elif(!normalBattleMusic.playing):
		normalBattleMusic.stream_paused = false
