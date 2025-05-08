extends Collectable


func on_player_use() -> bool:
	if player.frozen:
		return true

	player.shoot(player.Projectile.Flashbang)
	return false
