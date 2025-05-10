extends CanvasLayer
class_name  KillFeed
@onready var feed_container = $FeedContainer/VBoxContainer

const KILL_FEED_ITEM = preload("res://scenes/game/kill_feed_item.tscn")


var death_messages = [
	"{victim}没有恐高症",
	"{victim}的灵魂归于地狱",
	"{victim}体验了自由落体",
	"{killer}送{victim}去了异世界",
	"{victim}尝试了脸刹",
	"{killer}让{victim}提前退场",
	"{victim}去见了上帝",
	"{killer}终结了{victim}的游戏体验",
	"{victim}的冒险到此为止",
	"{killer}获得了{victim}的人头"
]
var death_messages_by_cause = {
	DeathCause.DeathCause.FALL: [
		"{victim}尝试游泳",
		"{victim}证明了他是旱鸭子",
		"海水拥抱了{victim}"
	],
	DeathCause.DeathCause.SHOT: [
		"{killer}精准命中了{victim}",
		"{victim}被{killer}射成了筛子",
		"{killer}的子弹找到了{victim}"
	],
	DeathCause.DeathCause.EXPLOSION: [
		"{victim}变成了烟花",
		"{killer}引爆了{victim}",
		"{victim}体验了爆炸艺术"
	],
	DeathCause.DeathCause.UNKNOWN: [
		"{victim}神秘消失",
		"{victim}退出了游戏",
		"{killer}终结了{victim}"
	]
}
func _ready():

	layer = 10  
	var game_node = get_tree().root.get_node("Game") 
	if game_node and game_node.has_method("set_kill_feed"):
		game_node.set_kill_feed(self)
	
@rpc("any_peer", "call_local", "reliable")
func add_kill(killer: String, victim: String, cause: DeathCause.DeathCause):
	var item = KILL_FEED_ITEM.instantiate()
	feed_container.add_child(item)
	var messages = death_messages_by_cause.get(cause)
	if messages == null:
		messages = death_messages_by_cause[DeathCause.DeathCause.UNKNOWN]
	var chosen_msg = messages[randi() % messages.size()]
	
	item.get_node("Text").text = chosen_msg.format({
		"killer": killer,
		"victim": victim
	})
	
	match cause:
		DeathCause.DeathCause.EXPLOSION:
			item.get_node("Text").add_theme_color_override("font_color", Color.ORANGE_RED)
		DeathCause.DeathCause.FALL:
			item.get_node("Text").add_theme_color_override("font_color", Color.SKY_BLUE)
		DeathCause.DeathCause.SHOT:
			item.get_node("Text").add_theme_color_override("font_color", Color.PERU)
			
	
	
	
	#var random_message = death_messages[randi() % death_messages.size()]
	#var display_text = random_message.format({"killer": killer, "victim": victim})
	'''
	if killer == "none":
		item.get_node("Text").text = "%s 自杀了" % [victim]
	else:
		item.get_node("Text").text = "%s 击杀了 %s" % [killer, victim]
	'''
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(func(): item.queue_free())
	
	
	if feed_container.get_child_count() > 5:
		feed_container.get_child(0).queue_free()
