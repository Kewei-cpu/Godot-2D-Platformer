extends CanvasLayer
class_name KillFeed

@onready var feed_container: VBoxContainer = %FeedContainer

const KILL_FEED_ITEM = preload("res://scenes/game/kill_feed_text.tscn")

var death_messages_by_cause = {
	DeathCause.DeathCause.FALL: [
		"{victim} tried to swim",
		"{victim} proved they can't swim",
		"The sea embraced {victim}",
		"{victim} failed their mermaid date",
		"{victim} forgot how to float",
		"{victim} failed the swimming test",
		"{victim} sank into the abyss",
		"Water rejected {victim}",
		"{victim}'s diving career ended here",
		"{victim} discovered water pressure is too strong",
		"{victim} tried to challenge water density",
		"Liquids defeated {victim}",
		"{victim}'s scuba gear malfunctioned",
		"{victim} became fish food"
	],
	DeathCause.DeathCause.SHOT: [
		"{killer} precisely hit {victim}",
		"{victim} was turned into Swiss cheese by {killer}",
		"{killer}'s bullet found {victim}",
		"{victim} experienced {killer}'s marksmanship",
		"{killer} put a hole in {victim}",
		"Lead supplements injected into {victim}'s body",
		"{victim} became {killer}'s target practice",
		"{killer}'s bullet had intimate contact with {victim}",
		"{victim} tried to catch bullets with bare hands",
		"{killer}'s shooting practice ended with {victim}",
		"{victim} was physically convinced by {killer}",
		"A metal storm swept through {victim}",
		"{killer} signed {victim} with bullets",
		"{victim}'s bulletproof vest failed quality check"
	],
	DeathCause.DeathCause.EXPLOSION: [
		"{victim} became fireworks",
		"{killer} detonated {victim}",
		"{victim} experienced explosive art",
		"{victim}'s molecular structure was rearranged",
		"{killer} gave {victim} a chemistry lesson",
		"{victim} tried to hug TNT",
		"The shockwave warmly embraced {victim}",
		"{victim}'s fragments scattered everywhere",
		"{killer}'s demolition experiment succeeded",
		"{victim} participated in distributed reorganization",
		"{victim}'s body parts gained free movement",
		"{killer} made {victim} bloom instantly",
		"Boom! Where did {victim} go?",
		"{victim} became open-concept architecture"
	],
	DeathCause.DeathCause.UNKNOWN: [
		"{victim} mysteriously disappeared",
		"{victim} left the game",
		"{killer} terminated {victim}",
		"{victim} was erased by unknown forces",
		"Reality rejected {victim}",
		"{victim} encountered a program error",
		"{killer} used mysterious powers",
		"{victim} entered another dimension",
		"404: {victim} not found",
		"{victim} was forgotten by the server",
		"Quantum state {victim} collapsed",
		"{killer} triggered {victim}'s bug",
		"{victim} encountered an indescribable event",
		"The system recycled {victim}"
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
