extends Collectable

@onready var lasting_time: Timer = $Lasting_Time
@onready var delta_time: Timer = $Delta_time

var on_use : bool = false
var delta : bool = false

func _ready() -> void:
	delta_time.one_shot = false
func on_player_use() -> bool:
	on_use = true
	lasting_time.start()
	delta_time.start()
	var radius := 16
	var bullet_count := 16
	
	for i in range(bullet_count):
		# create bullets in a circle
		var angle := (i * 2 * PI) / bullet_count
		var bullet_transform := Transform2D(angle, Vector2.from_angle(angle) * radius + player.center.global_position)

		player.fire_bullet.rpc(player.get_multiplayer_authority(), player.BULLET, bullet_transform)
	await lasting_time.timeout
	print(1231312)
	return false

func _physics_process(delta: float) -> void:
	pass
		
func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.


func _on_delta_time_timeout() -> void:
	var radius := 16
	var bullet_count := 16
	for i in range(bullet_count):
		# create bullets in a circle
		var angle := (i * 2 * PI) / bullet_count
		var bullet_transform := Transform2D(angle, Vector2.from_angle(angle) * radius + player.center.global_position)

		player.fire_bullet.rpc(player.get_multiplayer_authority(), player.BULLET, bullet_transform)
	delta_time.start()
	pass # Replace with function body.
