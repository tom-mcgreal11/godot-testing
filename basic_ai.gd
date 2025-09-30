extends CharacterBody3D

@onready var nav = $NavigationAgent3D as NavigationAgent3D
@export var patrol_points_root: Node3D
#IMPORTANT waypoints root on instance

var patrol_points: Array[Node] = []
var patrol_index = 0
var speed := 5
var new_target: Vector3
var player_position
var player
@onready var state = "patrol"
@onready var visRay = $VisionRayCast
var move = false

func _ready() -> void:
	if patrol_points_root:
		patrol_points = patrol_points_root.get_children()
		if patrol_points.size() > 0:
			set_target(set_next_patrol())

#func _unhandled_input(event: InputEvent) -> void:
#	if Input.is_action_just_pressed("target"):
#		var random_position = Vector3.ZERO
#		random_position.x = randf_range(-5.0, 5.0)
#		random_position.z = randf_range(-5.0, 5.0)
#		nav.set_target_position(random_position)

func _physics_process(delta: float) -> void:
	#print("moving to target:" + str(nav.get_next_path_position()))
	#scan if player is within range, if so attack player
	if state == "patrol":
		set_target(set_next_patrol())
		patrol()
	elif state == "attack":
		attack()
	else:
		do_nothing()

func attack():
	set_target(player)
	
	var destination = nav.get_next_path_position()
	var local_destination = destination - global_position
	var distance = local_destination.normalized()
	look_at(destination)
	velocity = distance * speed
	move_and_slide()

func do_nothing():
	pass
	
func patrol():
	if not nav.is_navigation_finished():
		var destination = nav.get_next_path_position()
		var local_destination = destination - global_position
		var distance = local_destination.normalized()
		velocity = distance * speed
		look_at(destination)
		#set_velocity_to_target(new_target)
		move_and_slide()
	else:
		patrol_index = (patrol_index + 1) % patrol_points.size()
		set_target(set_next_patrol())
		

func set_state(new_state):
	state = new_state

func set_target(target):
	nav.set_target_position(target.global_transform.origin)

func set_next_patrol():
	var target_point = patrol_points[patrol_index]
	return target_point


func _on_vision_timer_timeout() -> void:
	var overlaps = $Vision.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.name == "Player":
				player = overlap
				player_position = overlap.global_transform.origin
				visRay.look_at(player_position, Vector3.UP)
				visRay.force_raycast_update()
				
				if visRay.is_colliding():
					var collider = visRay.get_collider()
					if collider.name == "Player":
						set_state("attack")
						visRay.debug_shape_custom_color = Color(174,0,0)
					else:	
						set_state("patrol")
						visRay.debug_shape_custom_color = Color(0,255,0)
			else:
				set_state("patrol")
				visRay.debug_shape_custom_color = Color(174,0,200)
