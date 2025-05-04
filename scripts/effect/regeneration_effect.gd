extends Effect

@onready var regeneration_timer: Timer = $RegenerationTimer


func on_effect_start():
	regeneration_timer.start()
	regeneration_timer.timeout.connect(regen)


func regen():
	player.change_health(5)
