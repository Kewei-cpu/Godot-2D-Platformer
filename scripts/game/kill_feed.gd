extends CanvasLayer
class_name  KillFeed
@onready var feed_container = $FeedContainer/VBoxContainer

const KILL_FEED_ITEM = preload("res://scenes/game/kill_feed_item.tscn")

func _ready():

	layer = 10  
	var game_node = get_tree().root.get_node("Game") 
	if game_node and game_node.has_method("set_kill_feed"):
		game_node.set_kill_feed(self)
	
@rpc("any_peer", "call_local", "reliable")
func add_kill(killer: String, victim: String):
	var item = KILL_FEED_ITEM.instantiate()
	feed_container.add_child(item)
	if killer == "none":
		item.get_node("Text").text = "%s 自杀了" % [victim]
	else:
		item.get_node("Text").text = "%s 击杀了 %s" % [killer, victim]
	
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(func(): item.queue_free())
	
	
	if feed_container.get_child_count() > 5:
		feed_container.get_child(0).queue_free()
