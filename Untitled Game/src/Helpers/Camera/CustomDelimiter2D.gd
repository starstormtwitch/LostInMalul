extends Node2D

class_name CustomDelimiter2D

##If enabled the camera will transition automatically to the delimiter area when the player enters it.
export var AutomaticTransition: bool = true

## If enabled, will change how delim
export var IsAreaLockDelimeter: bool = false

##If enabled the camera will transition automatically to an overlapping delimiter area when the player exit it.
export var TransitionToOverlappingDelimiterOnExit: bool = false

signal PlayerEnteredAreaDelimiter(delimiter, IsAreaLock)
signal PlayerExitedAreaDelimiter(delimiter)

func _init():
	add_to_group("DelimiterNode")

func _ready():
	assert(getLeft() < getRight(), "Invalid X coordinates.")
	assert(getTop() < getBottom(), "Invalid Y coordinates.")
	
	if AutomaticTransition:
		_configureAutomaticTransitionArea2D()

func getTop() -> float:
	return self.get_global_position().y

func getLeft() -> float:
	return self.get_global_position().x

func getBottom() -> float:
	return $BottomRight.get_global_position().y

func getRight() -> float:
	return $BottomRight.get_global_position().x

func _configureAutomaticTransitionArea2D() -> void:
	#This instantiation can be done in the editor but this way I avoid a problem I encountered
	# where sometimes on _onready the $Area2D object could be null
	var area: Area2D = Area2D.new()
	var coll: CollisionShape2D = CollisionShape2D.new()
	var rect: RectangleShape2D = RectangleShape2D.new()
	coll.shape = rect
	area.add_child(coll)
	self.add_child(area)
	#Calculate a rectangle that covers the area between the two position nodes.
	#BottomRight node positions are local and relative to the parent node (aka TopLeft)
	var x = $BottomRight.position.x
	var y = $BottomRight.position.y
	var area_center = Vector2(x / 2, y / 2)
	area.position = area_center
	#The rectangle's half extents. The width and height of this shape is twice the half extents.
	rect.extents = Vector2(x - area_center.x, y - area_center.y)
	#Connect signal
	area.connect("body_entered", self, "_on_AutomaticTransition_Area2D_body_entered")

func ManualTransition_Enter() -> void:
	print("Delimiter triggered: " + self.name)
	emit_signal("PlayerEnteredAreaDelimiter", self, IsAreaLockDelimeter)
	
func ManualTransition_Exit() -> void:
	print("Delimiter triggered: " + self.name)
	emit_signal("PlayerExitedAreaDelimiter", self)

func _on_AutomaticTransition_Area2D_body_entered(body) -> void:
	if AutomaticTransition && body.is_in_group("Player"):
		print("Delimiter triggered: " + self.name)
		emit_signal("PlayerEnteredAreaDelimiter", self, IsAreaLockDelimeter)
		#TransitionsManager.CameraTransitionToDelimiter(self)
		
func _on_AutomaticTransition_Area2D_body_exited(body) -> void:
	if TransitionToOverlappingDelimiterOnExit && AutomaticTransition && body.is_in_group("Player"):
		print("Delimiter triggered: " + self.name)
		emit_signal("PlayerExitedAreaDelimiter", self)
		#TransitionsManager.CameraTransitionToDelimiter(self)
