extends Collectable

func on_player_use() -> bool:
	player.effect_bar.add_effect(player.REGENERATION_EFFECT)
	
	return false
