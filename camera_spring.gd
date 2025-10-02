extends SpringArm3D

@export var zoom_speed: float = 1.0
@export var mouse_sensitivity: float = 0.001

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Horizontal rotation (yaw) around player
		rotate_y(-event.relative.x * mouse_sensitivity)
		
		# Vertical rotation (pitch), clamp between -90 and 45 deg
		rotation.x = clamp(rotation.x - event.relative.y * mouse_sensitivity, -PI/2, PI/4)

	if event.is_action_pressed("wheel_up"):
		spring_length = max(1.0, spring_length - zoom_speed)
	if event.is_action_pressed("wheel_down"):
		spring_length += zoom_speed

	if event.is_action_pressed("toggle_mouse_capture"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
