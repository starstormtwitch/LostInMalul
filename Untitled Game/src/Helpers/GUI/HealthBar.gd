extends HBoxContainer

export(Gradient) var healthGradient
const HealthPoint = preload("res://src/Helpers/GUI/HealthPoint.tscn")

var Health : float = 2
var MaxHealth : float = 10

func _ready():
	setup_health()
	pass
	
func setup_health():
	for _i in range(MaxHealth):
		add_child(HealthPoint.instance())
	update_color()
	pass
	
func update_health():
	var childCount = get_child_count()
	while(childCount > Health):
		if(childCount > 0):
			get_child(childCount-1).queue_free()
			childCount=childCount-1
			
	while(childCount < Health):
		if(childCount > 0):
			add_child(HealthPoint.instance())
			childCount=childCount+1
			
	update_color()
	pass
	
func update_color():
	for h in get_children():
		h.modulate = healthGradient.interpolate(float(h.get_index() / MaxHealth))
	pass
