extends CanvasLayer

@onready var player: Player = $".."

var ARROW = preload("res://scenes/player/enemy_indicator_arrow.tscn")


func add_target(target: Player):
	if get_node(str(target.name)):
		return
	
	
	var arrow = ARROW.instantiate()
	print('add', target)
	
	arrow.name = str(target.get_multiplayer_authority())
	arrow.set_target(target)
	add_child(arrow)
