extends TextureRect

var blink_timer

func _ready():
	blink_timer = Timer.new()
	blink_timer.connect("timeout", self, "_on_blink_timeout")
	add_child(blink_timer)
	hide()
	
func _on_blink_timeout():
	if is_visible():
		hide()
	else:
		show()
		
func start_blinking():
	blink_timer.set_wait_time(.8)
	blink_timer.start()
	
func stop_blinking():
	blink_timer.stop()
	hide()
