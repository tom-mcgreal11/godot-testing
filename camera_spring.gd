extends SpringArm3D

@onready var mouse_sensitivity: float = 0.005

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	#if event is InputEventMouseMotion && Input.mouse_mode == 2:
	#	rotation.y -= event.relative.x * mouse_sensitivity
	#	rotation.y = wrapf(rotation.y, 0 , TAU) 
	#	rotation.x -= event.relative.y * mouse_sensitivity
	#	rotation.x = clamp(rotation.x, -PI/2, PI/4)

	if event.is_action_pressed("wheel_up"):
		spring_length -= 0.1
	if event.is_action_pressed("wheel_down"):
		spring_length += 0.1

	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
