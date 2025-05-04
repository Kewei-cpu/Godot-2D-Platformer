extends Area2D

var player: Player


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.dead:
			return

		body.die()
