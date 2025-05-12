extends Effect


func on_effect_start():
	player.max_speed -= 50
	

func on_effect_end():
	player.max_speed += 50
