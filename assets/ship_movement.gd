extends CharacterBody3D

@onready var speed := 20
@onready var gravity := 9.8
@onready var jump_strength := 10

func _physics_process(delta: float) -> void:
	var direction = Vector3.ZERO
	
	direction.z = Input.get_axis("move_forward", "move_backward") * speed
	direction.x = Input.get_axis("move_left", "move_right") * speed

	
	if not is_on_floor():
		direction.y -= gravity * delta
	else:
		if Input.is_action_pressed("jump"):
			direction.y += jump_strength	
	velocity = direction
	move_and_slide()
