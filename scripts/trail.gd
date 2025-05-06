extends Line2D

@export var length = 15
@onready var vanish_timer: Timer = $"../VanishTimer"

var max_points := 0
var total_time := 0.0
var vanish_time = 0.5


func _physics_process(delta: float) -> void:
	global_position = Vector2(0, 0)
	global_rotation = 0

	var point: Vector2 = get_parent().global_position

	add_point(point)

	max_points = max(max_points, get_point_count())

	while get_point_count() > length:
		remove_point(0)
