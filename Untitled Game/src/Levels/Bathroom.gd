extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	$Cam.limit_left = 0 #$Bathroom.position.x
#	$Cam.limit_right = $Bathroom.texture.get_width()
#	$Cam.limit_top = 0 #$Bathroom.position.y
#	$Cam.limit_bottom = $Bathroom.texture.get_height()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _add_Child_To_Sort(child):
	self.get_node("YSort").add_child(child)

func _set_Camera_To_Area(cam):
	print("set camera to " + self.name)
	cam.limit_left = self.position.x
	cam.limit_right = self.position.x + $BathroomSprite.texture.get_width()
	cam.limit_top = self.position.y
	cam.limit_bottom = self.position.y + $BathroomSprite.texture.get_height()
	print(cam.limit_left)
	print(cam.limit_right)
	print(cam.limit_top)
	print(cam.limit_bottom)
