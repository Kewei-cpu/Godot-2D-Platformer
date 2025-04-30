extends Area2D

var player: Player


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.dead:
			return
		
		body.respawn_timer.start()
		body.dead = true
		var spawn_point: Marker2D = body.spawn_points.get_children().pick_random()
		body.global_position = spawn_point.global_position
