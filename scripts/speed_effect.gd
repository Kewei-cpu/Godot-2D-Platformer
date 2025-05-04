extends Effect


func on_effect_start():
	player.MAX_SPEED += 50
	

func on_effect_end():
	player.MAX_SPEED -= 50
	
