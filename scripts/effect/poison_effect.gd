extends Effect

@export var poison_damage = 5

func _on_damage_timer_timeout() -> void:
	if player.health <= 5 :
		return
	
	player.bullet_hit(poison_damage, Vector2.ZERO, 0, 0)
