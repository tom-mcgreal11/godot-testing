extends Node3D

@export var target: Node3D              # Assign your Ship in the editor
@export var follow_speed: float = 5.0   # How fast the rig follows
@export var vertical_deadzone: float = 2.0
@export var pitch_lerp: float = 5.0     # Smooth rotation speed
@export var follow_offset: Vector3 = Vector3(0, 2, 3)  # Offset above the player

func _physics_process(delta: float) -> void:
	if not target:
		return
	
	# Desired position for the rig, including offset
	var desired_pos: Vector3 = target.global_position + follow_offset
	
	# Smooth horizontal follow (XZ plane)
	global_position.x = lerp(global_position.x, desired_pos.x, delta * follow_speed)
	global_position.z = lerp(global_position.z, desired_pos.z, delta * follow_speed)
	
	# Smooth vertical follow with deadzone
	var y_offset: float = desired_pos.y - global_position.y
	if abs(y_offset) > vertical_deadzone:
		global_position.y = lerp(global_position.y, desired_pos.y, delta * follow_speed)
	
	# Rotate spring arm to look at player smoothly
	var spring_arm: SpringArm3D = $SpringArm3D
	var target_dir: Vector3 = (target.global_position - spring_arm.global_position).normalized()
	var target_basis: Basis = Basis.looking_at(target_dir, Vector3.UP)
	var target_quat: Quaternion = target_basis.get_rotation_quaternion()
	var current_quat: Quaternion = spring_arm.global_transform.basis.get_rotation_quaternion()
	var new_quat: Quaternion = current_quat.slerp(target_quat, delta * pitch_lerp)
	spring_arm.rotation = new_quat.get_euler()
