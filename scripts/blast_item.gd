extends Collectable


func on_player_use() -> bool:
	var radius := 16
	var bullet_count := 16

	for i in range(bullet_count):
		# create bullets in a circle
		var angle := (i * 2 * PI) / bullet_count
		var bullet_transform := Transform2D(angle, Vector2.from_angle(angle) * radius + player.center.global_position)

		player.fire_bullet.rpc(player.get_multiplayer_authority(), player.BULLET, bullet_transform)

	return false
