extends CharacterBody3D

@onready var speed := 20
@export var gravity: float = -300.0
@export var jump_strength: float = 150.0
@onready var yaw_rate := 1
@onready var rotate_rate := 1
@onready var look_rate := 1
@onready var jump_count := 0

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	var yaw_input := 0
	var rotate_input := 0
	var look_input := 0
	var max_jump:= 2
	velocity = -(-transform.basis.z * Input.get_axis("move_forward", "move_backward") \
	-transform.basis.x * Input.get_axis("move_left", "move_right"))
	velocity.x *= speed
	velocity.z *= speed
	#rotate(Vector3.RIGHT, 1.0 * delta)
	#yaw_input = - Input.get_axis("yaw_left", "yaw_right") * yaw_rate
	#rotate(Vector3.UP, yaw_input * delta)
	#rotate_input = Input.get_axis("rotate_anticlockwise", "rotate_clockwise") * rotate_rate
	#rotate(Vector3.FORWARD, rotate_input * delta)
	#look_input = Input.get_axis("look_up", "look_down") * look_rate
	#rotate(Vector3.RIGHT, look_input * delta )
	
	if not is_on_floor():
		velocity.y += gravity * delta
		if jump_count <= 1 && Input.is_action_just_pressed("jump"):
			jump()
			
	else:
		jump_count = 0
		if Input.is_action_just_pressed("jump"):
			jump()
	#velocity = direction * speed
	move_and_slide()
	
func jump():
	velocity.y = jump_strength
	jump_count+=1
