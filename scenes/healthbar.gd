extends Node2D

@export var max_health: int = 100:
	set(value):
		max_health = max(1, value)
		update_health_display()
		
@export var health: int = 100:
	set(value):
		health = clamp(value, 0, max_health)
		update_health_display()





func _ready():
	update_health_display()
	#$OtherNode.health_changed.connect(_on_variable_changed)
	


func update_health_display():
	var a
