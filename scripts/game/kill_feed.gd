extends CanvasLayer
class_name KillFeed

@onready var feed_container: VBoxContainer = %FeedContainer

const KILL_FEED_ITEM = preload("res://scenes/game/kill_feed_text.tscn")

var death_messages_by_cause = {
	DeathCause.DeathCause.FALL:
	[
		"[color=orange_red]{victim}[/color] tried to swim",
		"[color=orange_red]{victim}[/color] proved they can't swim",
		"The sea embraced [color=orange_red]{victim}[/color]",
		"[color=orange_red]{victim}[/color] failed their mermaid date",
		"[color=orange_red]{victim}[/color] forgot how to float",
		"[color=orange_red]{victim}[/color] failed the swimming test",
		"[color=orange_red]{victim}[/color] sank into the abyss",
		"Water rejected [color=orange_red]{victim}[/color]",
		"[color=orange_red]{victim}[/color]'s diving career ended here",
		"[color=orange_red]{victim}[/color] discovered water pressure is too strong",
		"[color=orange_red]{victim}[/color] tried to challenge water density",
		"Liquids defeated [color=orange_red]{victim}[/color]",
		"[color=orange_red]{victim}[/color]'s scuba gear malfunctioned",
		"[color=orange_red]{victim}[/color] became fish food"
	],
	DeathCause.DeathCause.SHOT:
	[
		"[color=sky_blue]{victim}[/color] precisely hit [color=orange_red]{victim}[/color]",
		"[color=sky_blue]{victim}[/color]'s bullet found [color=orange_red]{victim}[/color]",
		"[color=sky_blue]{victim}[/color] put a hole in [color=orange_red]{victim}[/color]",
		"Lead supplements injected into [color=orange_red]{victim}[/color]'s body",
		"[color=orange_red]{victim}[/color] tried to catch bullets with bare hands",
		"A metal storm swept through [color=orange_red]{victim}[/color]",
		"[color=orange_red]{victim}[/color]'s bulletproof vest failed quality check"
	],
	DeathCause.DeathCause.EXPLOSION:
	[
		"[color=orange_red]{victim}[/color] became fireworks",
		"[color=orange_red]{victim}[/color] experienced explosive art",
		"[color=orange_red]{victim}[/color]'s molecular structure was rearranged",
		"[color=orange_red]{victim}[/color] tried to hug TNT",
		"The shockwave warmly embraced [color=orange_red]{victim}[/color]",
		"[color=orange_red]{victim}[/color]'s fragments scattered everywhere",
		"[color=sky_blue]{victim}[/color]'s demolition experiment succeeded",
		"[color=orange_red]{victim}[/color]'s body parts gained free movement",
		"Boom! Where did [color=orange_red]{victim}[/color] go?",
		"[color=orange_red]{victim}[/color] became open-concept architecture"
	],
	DeathCause.DeathCause.UNKNOWN:
	[
		"[color=orange_red]{victim}[/color] mysteriously disappeared",
		"[color=orange_red]{victim}[/color] left the game",
		"[color=orange_red]{victim}[/color] was erased by unknown forces",
		"Reality rejected [color=orange_red]{victim}[/color]",
		"[color=orange_red]{victim}[/color] encountered a program error",
		"[color=sky_blue]{victim}[/color] used mysterious powers",
		"[color=orange_red]{victim}[/color] entered another dimension",
		"404: [color=orange_red]{victim}[/color] not found",
		"[color=orange_red]{victim}[/color] was forgotten by the server",
		"Quantum state [color=orange_red]{victim}[/color] collapsed",
		"The system recycled [color=orange_red]{victim}[/color]"
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
	feed_container.add_child(item)
