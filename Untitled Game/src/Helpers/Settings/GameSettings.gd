extends Object

class_name GameSettings

# Declare member variables here. Examples:
var infiniteHealth: float
var infiniteDamage: float

func _init(_infiniteHealth: bool, _infiniteDamage: bool):
	infiniteHealth = _infiniteHealth
	infiniteDamage = _infiniteDamage
