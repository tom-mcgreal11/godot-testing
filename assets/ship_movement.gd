extends CharacterBody3D

@onready var ground_speed := 10.0
@onready var health := 100
@onready var in_air_speed := 6.0
@export var gravity: float = -30.0
@export var jump_strength: float = 15.0
@onready var yaw_rate := 1
@onready var rotate_rate := 1
@onready var look_rate := 1
@onready var jump_count := 0
@export var camera: Node3D
@onready var speed = ground_speed
enum player_state {MOVING, SWORD, DEAD}
var current_state = player_state.MOVING

func _physics_process(delta: float) -> void:
	#look_at(camera.basis.z, Vector3.UP)
# Get camera forward/right, flattened
	match current_state:
		player_state.MOVING:
			move(delta)
		player_state.SWORD:
			sword()
		player_state.DEAD:
			kill()
	
	if Input.is_action_just_pressed("sword"):
		current_state = player_state.SWORD
	if Input.is_action_just_pressed("jump"):
		jump(delta)
	#velocity = direction * speed
	move_and_slide()
	
func kill():
	print("YOU DIED")

func sword():
	pass
	#anim_state.travel("sword")

func move(delta):
	var forward = camera.basis.z
	var right = camera.basis.x
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	# Build movement direction from input
	var input_dir = Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_forward", "move_backward")
	)

	var move_dir = (forward * input_dir.y + right * input_dir.x).normalized()

	if move_dir.length() > 0.1:
		var target_angle = atan2(-move_dir.x, -move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 10.0)
		
	# Apply speed
	velocity.x = move_dir.x * speed
	velocity.z = move_dir.z * speed
	if not is_on_floor():
		velocity.y += gravity * delta
	#rotate(Vector3.RIGHT, 1.0 * delta)
	#yaw_input = - Input.get_axis("yaw_left", "yaw_right") * yaw_rate
	#rotate(Vector3.UP, yaw_input * delta)
	#rotate_input = Input.get_axis("rotate_anticlockwise", "rotate_clockwise") * rotate_rate
	#rotate(Vector3.FORWARD, rotate_input * delta)
	#look_input = Input.get_axis("look_up", "look_down") * look_rate
	#rotate(Vector3.RIGHT, look_input * delta )

func jump(delta):	
	if not is_on_floor():
		while speed > in_air_speed:
			speed -= 0.01
		velocity.y += gravity * delta
		if jump_count <= 1 && Input.is_action_just_pressed("jump"):
			velocity.y = jump_strength
			jump_count+=1
	else:
		speed = ground_speed
		jump_count = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_strength
			jump_count+=1

func reset_state():
	current_state = player_state.MOVING

#temp func for onhit:
func on_hit(damage):
	health -= damage
	if health <= 0:
		current_state = player_state.DEAD
