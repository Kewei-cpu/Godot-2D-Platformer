extends Projectile

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


func _on_explode_timer_timeout() -> void:
	if visible_on_screen_notifier_2d.is_on_screen():
		var game: Game = get_node("/root/Game")
		game.play_flash()
		
	animation_player.play("flash")
	point_light_2d.texture.width = 200
	point_light_2d.texture.height = 200
