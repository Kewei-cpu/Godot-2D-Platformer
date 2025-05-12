extends Node2D

@export var item_list: Array[PackedScene]
@export var max_spawn_time: float = 20.0
@export var min_spawn_time: float = 10.0

@onready var game: Game = get_node("/root/Game")
@onready var spawn_timer: Timer = $SpawnTimer

var spawned_item: Collectable


func _process(_delta: float) -> void:
	if not game.is_server:
		return

	spawned_item = get_node_or_null("Item")
	if not spawned_item and spawn_timer.is_stopped():
		reset_spawn_timer()
	
func reset_spawn_timer():
	spawn_timer.start(randf_range(min_spawn_time, max_spawn_time))


func _on_spawn_timer_timeout() -> void:
	if spawned_item:
		return
		
	spawn_item.rpc(randi() % item_list.size())

	
@rpc("authority", "call_local", "reliable")
func spawn_item(item_idx: int):
	var item_scene: PackedScene = item_list[item_idx]
	var item: Collectable = item_scene.instantiate()
	item.name = "Item"
	add_child(item)
