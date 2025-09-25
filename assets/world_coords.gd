extends Node3D

@onready var entity = $Entity
@onready var first_waypoint = $Point1
@onready var second_waypoint: = $Point2

func _ready() -> void:
	setup_entity()
	
func setup_entity():
	entity.set_target(first_waypoint)
