extends Node2D

class_name MusicManager

onready var menuMusic: AudioStreamPlayer = $MenuMusicStreamPlayer
onready var normalBattleMusic: AudioStreamPlayer = $NormalBattleStreamPlayer


func playMenuMusic():
	normalBattleMusic.playing = false
	menuMusic.play()

func playNormalBattleMusic():
	normalBattleMusic.play()
	menuMusic.playing = false
