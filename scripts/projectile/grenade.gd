extends Projectile

var Poison = preload("res://scenes/effect/poison_effect.tscn")
var Area = preload("res://scenes/effect/effect_area.tscn")

func _on_explode_timer_timeout() -> void:
	if not is_multiplayer_authority():
		return
	
	spawn_effect_area.rpc()
	
	

@rpc("call_local", "any_peer")
func spawn_effect_area():
	var game: Game = get_parent()
	
	var area: EffectArea = Area.instantiate()
	area.position = global_position
	area.effect = Poison
	
	game.add_child(area)
