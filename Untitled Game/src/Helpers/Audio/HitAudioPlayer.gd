extends AudioStreamPlayer

class_name HitAudioPlayer

var _attackLoaded = false

func _ready():
	pass # Replace with function body.


func playerAttacks():
	#print("attack sounds loaded")
	_attackLoaded = true


func playHitSound():
	if _attackLoaded:
		#print("attack sounds played")
		self.play()
		_attackLoaded = false
