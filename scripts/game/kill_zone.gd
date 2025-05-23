extends Area2D

var player: Player

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.is_multiplayer_authority():
		if body.dead:
			return
		body.last_death_cause = DeathCause.DeathCause.FALL
		body.die()
