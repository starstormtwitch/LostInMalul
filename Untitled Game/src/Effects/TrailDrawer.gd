extends Line2D


class_name TrailDrawer


var target: Node2D
var point: Vector2

export(NodePath) var targetPath
export var trailLength = 0

var turnOn = false


# Called when the node enters the scene tree for the first time.
func _ready():
	target = get_node(targetPath)


func _process(delta):
	if turnOn:
		global_position = Vector2.ZERO
		global_rotation = 0
		point = target.global_position
		add_point(point)
		while get_point_count() > trailLength:
			remove_point(0)

func turnTrailOn():
	turnOn = true
