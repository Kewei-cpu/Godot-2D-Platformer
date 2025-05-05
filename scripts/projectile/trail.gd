extends Line2D

@export var length = 15

func _physics_process(delta: float) -> void:
	global_position = Vector2(0, 0)
	global_rotation = 0

	var point: Vector2 = get_parent().global_position

	add_point(point)
	while get_point_count() > length:
		remove_point(0)
