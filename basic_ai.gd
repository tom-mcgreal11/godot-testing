extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var reached_checkpoint = false
var gravity := 10
var speed := 20

func _ready():
	nav.target_reached.connect(Callable(self, "_on_nav_target_reached"))
	nav.navigation_finished.connect(_on_navigation_finished)

func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()
	
func patrol(target: Vector3):
	nav.target_position = target

func _on_nav_target_reached():
	# Emit a simple signal the main scene can listen to
	emit_signal("reached_point", self)
	
func _on_navigation_finished():
	print("Finished.")
	#get_parent()._on_navigation_finished(self)
