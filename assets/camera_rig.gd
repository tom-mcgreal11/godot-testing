extends Node3D

@export var target: Node3D
@export var follow_speed: float = 5.0
@export var vertical_deadzone: float = 2.0
@export var follow_offset: Vector3 = Vector3(0, 2, 6)

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	# Desired position for the rig, including offset
	var desired_pos: Vector3 = target.global_position
	
	# Smooth horizontal follow (XZ plane)
	global_position.x = lerp(global_position.x, desired_pos.x, delta * follow_speed)
	global_position.z = lerp(global_position.z, desired_pos.z, delta * follow_speed)
	
	# Smooth vertical follow with deadzone
	var y_offset: float = desired_pos.y - global_position.y

	if y_offset > vertical_deadzone:
		global_position.y = lerp(global_position.y, desired_pos.y, delta * follow_speed)
	elif y_offset < -vertical_deadzone:
		global_position.y = lerp(global_position.y, desired_pos.y, delta * follow_speed * 2.0)
	else:
		if desired_pos.y < global_position.y:
			global_position.y = lerp(global_position.y, desired_pos.y, delta * follow_speed * 2.0)
