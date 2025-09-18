extends Node3D

signal reached_point(enemy)

@onready var waypoints = [$Point1, $Point2]
var next_index_for_enemy := {} # Dictionary to store per-enemy waypoint index

func _ready():
	# connect existing enemies already in scene (and set their first target)
	for enemy in get_tree().get_nodes_in_group("enemy"):
		_setup_enemy(enemy)

func _setup_enemy(enemy):
	enemy.connect("reached_point", Callable(self, "_on_enemy_reached_point"))
	next_index_for_enemy[enemy] = 0
	enemy.patrol(waypoints[0].global_transform.origin)

func _on_enemy_reached_point(enemy):
	var idx = next_index_for_enemy.get(enemy, 0)
	idx = (idx + 1) % waypoints.size()
	next_index_for_enemy[enemy] = idx
	enemy.patrol(waypoints[idx].global_transform.origin)
