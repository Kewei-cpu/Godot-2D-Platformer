extends Effect


func on_effect_start():
	player.JUMP_VELOCITY -= 100


func on_effect_end():
	player.JUMP_VELOCITY += 100
