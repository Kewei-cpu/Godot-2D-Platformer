extends Effect


func on_effect_start():
	player.MAX_SPEED += 50
	player.camera.zoom -= Vector2(0.5, 0.5)

func on_effect_end():
	player.MAX_SPEED -= 50
	player.camera.zoom += Vector2(0.5, 0.5)
