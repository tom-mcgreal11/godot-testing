extends CharacterBody3D

@onready var nav = $NavigationAgent3D as NavigationAgent3D
@export var patrol_points_root: Node3D
@export var health = 100
#IMPORTANT waypoints root on instance

var patrol_points: Array[Node] = []
var patrol_index = 0
var speed := 5
var attack_range := 2.0
var new_target: Vector3
var player_position
var player
@onready var visRay = $VisionRayCast
var move = false
var is_waiting := false
enum bot_state {PATROL, CHASE, ATTACK, KILL, SEARCH}
var last_known_player_pos: Vector3 = Vector3.ZERO
var current_state = bot_state.PATROL

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
	match current_state:
		bot_state.PATROL:
			set_target(set_next_patrol())
			patrol()
		bot_state.CHASE:
			if player:
				var player_pos = player.global_position
				var dir = (player_pos - global_position).normalized()
				var stop_pos = player_pos - dir * attack_range
				nav.set_target_position(stop_pos)
			chase()
		bot_state.ATTACK:
			attack()
		bot_state.KILL:
			kill()
		bot_state.SEARCH:
			search()
		_:
			do_nothing()

func kill():
	queue_free()

func chase():
	if not nav.is_navigation_finished():
		#set_target(player)
		move_towards()
	else:
		velocity = Vector3.ZERO
		set_state(bot_state.ATTACK)
		#move_and_slide()

func attack():
	#do_an_attack_animation
	velocity = Vector3.ZERO
	move_and_slide()
	await get_tree().create_timer(1.0).timeout
	set_state(bot_state.CHASE)
	
func do_nothing():
	pass

func move_towards():
	var destination = nav.get_next_path_position()
	var local_destination = destination - global_position
	var distance = local_destination.normalized()
	velocity = distance * speed
	look_at(destination)
	#set_velocity_to_target(new_target)
	move_and_slide()
		
func patrol():
	if is_waiting or patrol_points.is_empty():
		return
		
	if not nav.is_navigation_finished():
		move_towards()
	else:
		#await get_tree().create_timer(1).timeout
		velocity = Vector3.ZERO
		move_and_slide()
		start_wait()
		#patrol_index = (patrol_index + 1) % patrol_points.size()
		#set_target(set_next_patrol())
		

func start_wait():
	is_waiting = true
	await get_tree().create_timer(randf_range(1.0, 2.0)).timeout  # wait 1–2 seconds
	# Move to next patrol point
	patrol_index = (patrol_index + 1) % patrol_points.size()
	set_target(set_next_patrol())
	is_waiting = false
	
func set_state(new_state):
	current_state = new_state

func set_target(target):
	nav.set_target_position(target.global_transform.origin)

func set_next_patrol():
	var target_point = patrol_points[patrol_index]
	return target_point


#func _on_vision_timer_timeout() -> void:
	#var overlaps = $Vision.get_overlapping_bodies()
	#if overlaps.size() > 0:
		#for overlap in overlaps:
			#if overlap.name == "Player":
				#player = overlap
				#player_position = overlap.global_transform.origin
				#visRay.look_at(player_position, Vector3.UP)
				#visRay.force_raycast_update()
				#
				#if visRay.is_colliding():
					#var collider = visRay.get_collider()
					#if collider.name == "Player":
						#set_state(bot_state.CHASE)
						#visRay.debug_shape_custom_color = Color(174,0,0)
					#else:	
						#set_state(bot_state.PATROL)
						#visRay.debug_shape_custom_color = Color(0,255,0)
			#else:
				#set_state(bot_state.PATROL)
				#visRay.debug_shape_custom_color = Color(174,0,200)

func _on_vision_timer_timeout() -> void:
	var overlaps = $Vision.get_overlapping_bodies()
	var saw_player := false
	
	for overlap in overlaps:
		if overlap.name == "Player":
			player = overlap
			player_position = player.global_position
			visRay.look_at(player_position, Vector3.UP)
			visRay.force_raycast_update()
			
			if visRay.is_colliding():
				var collider = visRay.get_collider()
				if collider.name == "Player":
					# ✅ Player is visible
					saw_player = true
					last_known_player_pos = player_position
					set_state(bot_state.CHASE)
					visRay.debug_shape_custom_color = Color(1, 0, 0)  # red
					break  # found player; stop checking others
	
	# ✅ If we didn't see the player this tick
	if not saw_player and current_state != bot_state.SEARCH:
		if last_known_player_pos != Vector3.ZERO:
			set_state(bot_state.SEARCH)
			visRay.debug_shape_custom_color = Color(0, 0.7, 1)  # cyan
		else:
			set_state(bot_state.PATROL)
			visRay.debug_shape_custom_color = Color(0, 1, 0)  # green

func search():
	if not nav.is_navigation_finished():
		# Move toward the last seen position
		nav.set_target_position(last_known_player_pos)
		move_towards()
	else:
		# Arrived at last known position
		velocity = Vector3.ZERO
		move_and_slide()
		await get_tree().create_timer(2.0).timeout  # wait a bit
		set_state(bot_state.PATROL)

func _on_hitbox_area_entered(area: Area3D) -> void:
	if area.is_in_group("sword"):
		health -= 25
		if health <= 0:
			current_state = bot_state.KILL
