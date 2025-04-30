extends Area2D

var player: Player


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.respawn_timer.start()
