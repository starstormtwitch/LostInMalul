extends Object

class_name ErrorLogger


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func assertNodeNotNull(node: Node, nameOfNode: String, parentNode: Node):
	var errorMessage = "Make sure " + nameOfNode + " exists in " + parentNode.get_name()
	assert(node, errorMessage)
