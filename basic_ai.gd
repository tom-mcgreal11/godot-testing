extends CharacterBody3D

@onready var nav = $NavigationAgent3D as NavigationAgent3D
@export var patrol_points_root: Node3D

var patrol_points: Array[Node] = []
var patrol_index = 0
var speed := 5
var new_target: Vector3

func _ready() -> void:
	if patrol_points_root:
		patrol_points = patrol_points_root.get_children()
		if patrol_points.size() > 0:
			set_target(set_next_patrol())
			print(str(patrol_points[0].global_transform.origin))
		
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("target"):
		var random_position = Vector3.ZERO
		random_position.x = randf_range(-5.0, 5.0)
		random_position.z = randf_range(-5.0, 5.0)
		nav.set_target_position(random_position)
		
func _physics_process(delta: float) -> void:
	print("moving to target:" + str(nav.get_next_path_position()))
	if not nav.is_navigation_finished():
		var destination = nav.get_next_path_position()
		var local_destination = destination - global_position
		var distance = local_destination.normalized()
		velocity = distance * speed
		#set_velocity_to_target(new_target)
		move_and_slide()
	else:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		set_target(set_next_patrol())

func set_target(target):
	nav.set_target_position(target.global_transform.origin)

func set_next_patrol():
	var target_point = patrol_points[patrol_index]
	return target_point
