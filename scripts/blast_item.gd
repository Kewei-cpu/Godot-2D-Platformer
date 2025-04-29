extends Collectable

@onready var lasting_time: Timer = $Lasting_Time
@onready var delta_time: Timer = $Delta_time

@export	var radius := 10
@export	var bullet_count := 16

func on_player_use() -> bool:
	lasting_time.start()
	delta_time.start()
	
	fire_bullet_cirecle()

	return false

func _on_timer_timeout() -> void:
	queue_free()


func _on_delta_time_timeout() -> void:
	fire_bullet_cirecle()


func fire_bullet_cirecle():
	for i in range(bullet_count):
		
		# create bullets in a circle
		var angle := (i * 2 * PI) / bullet_count
		var bullet_transform := Transform2D(angle, Vector2.from_angle(angle) * radius + player.center.global_position)

		player.fire_bullet.rpc(player.get_multiplayer_authority(), bullet_transform)
