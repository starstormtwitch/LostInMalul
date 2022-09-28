extends Node2D

onready var menuMusic: AudioStreamPlayer = $MenuMusicStreamPlayer
onready var normalBattleMusic: AudioStreamPlayer = $NormalBattleStreamPlayer
onready var bossBattleMusic: AudioStreamPlayer = $BossMusicStreamPlayer

var menuPos = 0
var normalPos = 0

func playNoMusic():
	normalBattleMusic.stop()
	menuMusic.stop()
	bossBattleMusic.stop()
	
func playBossMusic():
	menuPos = menuMusic.get_playback_position()
	normalPos = normalBattleMusic.get_playback_position()
	normalBattleMusic.stop()
	menuMusic.stop()
	if(!bossBattleMusic.playing && !bossBattleMusic.stream_paused):
		bossBattleMusic.play()
	elif(!bossBattleMusic.playing):
		bossBattleMusic.stream_paused = false

func playMenuMusic():
	bossBattleMusic.stop()
	normalPos = normalBattleMusic.get_playback_position()
	normalBattleMusic.stop()
	if(!menuMusic.playing && !menuMusic.stream_paused):
		menuMusic.play()
		menuMusic.seek(menuPos)
	elif(!menuMusic.playing):
		menuMusic.stream_paused = false

func playNormalBattleMusic():
	menuPos = menuMusic.get_playback_position()
	bossBattleMusic.stop()
	menuMusic.stop()
	if(!normalBattleMusic.playing && !normalBattleMusic.stream_paused):
		normalBattleMusic.play()
		normalBattleMusic.seek(normalPos)
	elif(!normalBattleMusic.playing):
		normalBattleMusic.stream_paused = false
