extends CanvasLayer

@onready var arrow: TextureRect = %Arrow
@onready var player: Player = $".."

var target: Player


func set_target(_target: Player) -> void:
	target = _target
	var visible_notifier: VisibleOnScreenNotifier2D = target.get_node("%VisibleNotifier")
	visible_notifier.screen_entered.connect(hide)
	visible_notifier.screen_exited.connect(show)
	show()


func _process(delta) -> void:
	if not is_multiplayer_authority():
		return

	if not target:
		return

	var direction = target.global_position - player.global_position
	var screen_edge_position = get_screen_edge_position(direction, 50)
	arrow.position = screen_edge_position - Vector2(40, 40)
	arrow.rotation = direction.angle()


func get_screen_edge_position(direction: Vector2, margin: int = 50) -> Vector2:
	# get screen rect Bounds from direction angle
	var screen_rect: Rect2 = Rect2(Vector2.ZERO, get_viewport().get_visible_rect().size)
	var screen_center: Vector2 = screen_rect.get_center()

	# Define a line segment starting from the center and extending far beyond the screen edge
	# Use a large multiplier to ensure it crosses the boundary
	var line_end: Vector2 = screen_center + direction.normalized() * (screen_rect.size.x + screen_rect.size.y)
	var polyline: PackedVector2Array = [screen_center, line_end]

	# Define the screen rectangle as a polygon
	var screen_polygon: PackedVector2Array = [
		screen_rect.position + Vector2(margin, margin),
		Vector2(screen_rect.end.x, screen_rect.position.y) + Vector2(-margin, margin),
		screen_rect.end + Vector2(-margin, -margin),
		Vector2(screen_rect.position.x, screen_rect.end.y) + Vector2(margin, -margin),
	]

	# Calculate the intersection points
	var intersections: Array = Geometry2D.intersect_polyline_with_polygon(polyline, screen_polygon)

	#print(intersections)

	return intersections[0].get(1)
