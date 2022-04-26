extends Node2D

onready var menuMusic: AudioStreamPlayer = $MenuMusicStreamPlayer
onready var normalBattleMusic: AudioStreamPlayer = $NormalBattleStreamPlayer

func playMenuMusic():
	normalBattleMusic.playing = false
	menuMusic.play()

func playNormalBattleMusic():
	normalBattleMusic.play()
	menuMusic.playing = false
