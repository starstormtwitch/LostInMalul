extends Node2D

class_name CustomDelimiter2D

##If enabled the camera will transition automatically to the delimiter area when the player enters it.
export var AutomaticTransition: bool = true

func _ready():
	assert($TopLeft.position.x < $BottomRight.position.x, "Invalid X coordinates.")
	assert($TopLeft.position.y < $BottomRight.position.y, "Invalid Y coordinates.")
	
	if AutomaticTransition:
		#Calculate a rectangle that covers the area between the two position nodes.
		var x = $TopLeft.position.x + $BottomRight.position.x
		var y = $TopLeft.position.y + $BottomRight.position.y
		var area_center = Vector2(x / 2, y / 2)
		$AutomaticTransition_Area2D.position = area_center
		var rect: RectangleShape2D = $AutomaticTransition_Area2D/CollisionShape2D.shape
		rect.extents = Vector2(x - area_center.x, y - area_center.y)

func getTop() -> float:
	return $TopLeft.get_global_position().y

func getLeft() -> float:
	return $TopLeft.get_global_position().x

func getBottom() -> float:
	return $BottomRight.get_global_position().y

func getRight() -> float:
	return $BottomRight.get_global_position().x

func _on_AutomaticTransition_Area2D_body_entered(body) -> void:
	if AutomaticTransition && body == LevelGlobals.GetPlayerActor():
		TransitionsManager.CameraTransitionToDelimiter(self)
