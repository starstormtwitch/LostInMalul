extends Node2D

class_name CustomDelimiter2D

func _ready():
	assert($TopLeft.position.x < $BottomRight.position.x, "Invalid X coordinates.")
	assert($TopLeft.position.y < $BottomRight.position.y, "Invalid Y coordinates.")

func getTop() -> float:
	return $TopLeft.get_global_position().y

func getLeft() -> float:
	return $TopLeft.get_global_position().x

func getBottom() -> float:
	return $BottomRight.get_global_position().y

func getRight() -> float:
	return $BottomRight.get_global_position().x
