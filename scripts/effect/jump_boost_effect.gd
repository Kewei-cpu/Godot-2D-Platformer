extends Effect


func on_effect_start():
	player.jump_speed -= 100


func on_effect_end():
	player.jump_speed += 100
