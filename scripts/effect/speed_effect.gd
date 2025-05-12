extends Effect

var initial_camera_zoom: Vector2


func on_effect_start():
	initial_camera_zoom = player.camera.zoom
	player.max_speed += 50

	player.camera.change_zoom_tween(Vector2(-0.5, -0.5))


func on_effect_end():
	player.max_speed -= 50
	player.camera.change_zoom_tween(Vector2(0.5, 0.5))
