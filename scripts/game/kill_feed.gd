extends CanvasLayer
class_name KillFeed
@onready var feed_container = $FeedContainer/VBoxContainer

const KILL_FEED_ITEM = preload("res://scenes/game/kill_feed_text.tscn")

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
	DeathCause.DeathCause.FALL:
	[
		"{victim}尝试游泳",
		"{victim}证明了他是旱鸭子",
		"海水拥抱了{victim}",
		"{victim}与美人鱼约会失败",
		"{victim}忘记了如何浮起来",
		"{victim}的水性测试不及格",
		"{victim}沉入了深渊",
		"水拒绝了{victim}",
		"{victim}的潜水生涯就此结束",
		"{victim}发现了海底压力太大",
		"{victim}试图挑战水的密度",
		"液体战胜了{victim}",
		"{victim}的水肺罢工了",
		"{victim}成为了鱼类的点心"
	],
	DeathCause.DeathCause.SHOT:
	[
		"{killer}精准命中了{victim}",
		"{victim}被{killer}射成了筛子",
		"{killer}的子弹找到了{victim}",
		"{victim}体验了{killer}的枪法",
		"{killer}给{victim}开了个洞",
		"铅制营养剂注入了{victim}体内",
		"{victim}成为了{killer}的靶子",
		"{killer}的子弹与{victim}亲密接触",
		"{victim}尝试徒手接子弹",
		"{killer}的射击练习以{victim}告终",
		"{victim}被{killer}物理说服",
		"金属风暴席卷了{victim}",
		"{killer}用子弹给{victim}签名",
		"{victim}的防弹衣质检不合格"
	],
	DeathCause.DeathCause.EXPLOSION:
	[
		"{victim}变成了烟花",
		"{killer}引爆了{victim}",
		"{victim}体验了爆炸艺术",
		"{victim}的分子结构重排了",
		"{killer}给{victim}上了堂化学课",
		"{victim}尝试拥抱TNT",
		"冲击波与{victim}热情相拥",
		"{victim}的碎片散落各地",
		"{killer}的爆破实验成功了",
		"{victim}参与了分散式重组",
		"{victim}的零件开始自由活动",
		"{killer}让{victim}瞬间绽放",
		"轰！{victim}去哪儿了？",
		"{victim}成为了开放式建筑"
	],
	DeathCause.DeathCause.UNKNOWN:
	[
		"{victim}神秘消失",
		"{victim}退出了游戏",
		"{killer}终结了{victim}",
		"{victim}被未知力量抹除",
		"现实拒绝了{victim}",
		"{victim}遇到了程序错误",
		"{killer}使用了神秘力量",
		"{victim}进入了异次元",
		"404: {victim} not found",
		"{victim}被服务器遗忘",
		"量子态{victim}坍缩了",
		"{killer}触发了{victim}的bug",
		"{victim}遭遇了不可描述事件",
		"系统回收了{victim}"
	]
}

@rpc("any_peer", "call_local", "reliable")
func add_kill(killer: String, victim: String, cause: DeathCause.DeathCause):
	var item = KILL_FEED_ITEM.instantiate()
	var messages = death_messages_by_cause.get(cause)
	if messages == null:
		messages = death_messages_by_cause[DeathCause.DeathCause.UNKNOWN]
	var chosen_msg = messages.pick_random()

	item.text = chosen_msg.format({"killer": killer, "victim": victim})

	match cause:
		DeathCause.DeathCause.EXPLOSION:
			item.add_theme_color_override("font_color", Color.ORANGE_RED)
		DeathCause.DeathCause.FALL:
			item.add_theme_color_override("font_color", Color.SKY_BLUE)
		DeathCause.DeathCause.SHOT:
			item.add_theme_color_override("font_color", Color.PERU)
	
	feed_container.add_child(item)

	# if feed_container.get_child_count() > 5:
	# 	feed_container.get_child(0).queue_free()
