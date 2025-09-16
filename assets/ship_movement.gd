extends CharacterBody3D

@onready var speed := 20
@onready var gravity := 9.8
@onready var jump_strength := 10
@onready var yaw_rate := 1
@onready var rotate_rate := 1
@onready var look_rate := 1

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	var yaw_input := 0
	var rotate_input := 0
	var look_input := 0
	direction = -(-transform.basis.z * Input.get_axis("move_forward", "move_backward") \
	-transform.basis.x * Input.get_axis("move_left", "move_right"))
	#rotate(Vector3.RIGHT, 1.0 * delta)
	yaw_input = - Input.get_axis("yaw_left", "yaw_right") * yaw_rate
	rotate(Vector3.UP, yaw_input * delta)
	rotate_input = Input.get_axis("rotate_anticlockwise", "rotate_clockwise") * rotate_rate
	rotate(Vector3.FORWARD, rotate_input * delta)
	look_input = Input.get_axis("look_up", "look_down") * look_rate
	rotate(Vector3.RIGHT, look_input * delta )
	
	if not is_on_floor():
		direction.y -= gravity * delta
	else:
		if Input.is_action_pressed("jump"):
			direction.y += jump_strength	
	velocity = direction * speed
	move_and_slide()
