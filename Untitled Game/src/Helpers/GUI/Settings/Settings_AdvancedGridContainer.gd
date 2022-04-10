extends ScrollContainer

onready var dx12 = $AdvancedGrid/DX12_Checkbox
onready var rayTracing = $AdvancedGrid/RT_CheckBox
onready var rayTracingShadows = $AdvancedGrid/RTShadows_CheckBox
onready var rayTracingRays = $AdvancedGrid/RTShadowRay_Checkbox

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func _on_DX12_Checkbox_toggled(button_pressed):
	_valdiateRayTracingSettings()

func _on_RT_CheckBox_toggled(button_pressed):
	_valdiateRayTracingSettings()

func _on_RTShadows_CheckBox_toggled(button_pressed):
	_valdiateRayTracingSettings()
	
func _valdiateRayTracingSettings():
	rayTracing.disabled = !dx12.pressed
	rayTracing.pressed = rayTracing.pressed && dx12.pressed
	rayTracingShadows.pressed = rayTracingShadows.pressed && rayTracing.pressed
	rayTracingRays.pressed = rayTracingRays.pressed && rayTracing.pressed
	rayTracingShadows.disabled = !rayTracing.pressed
	rayTracingRays.disabled = !rayTracing.pressed
