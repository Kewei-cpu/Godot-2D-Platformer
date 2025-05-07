extends Control

@onready var player_count: Label = %PlayerCount
@onready var ready_count: Label = %ReadyCount

@onready var hiders_list: ItemList = %HidersList
@onready var join_hiders: Button = %JoinHiders
@onready var seekers_list: ItemList = %SeekersList
@onready var join_seekers: Button = %JoinSeekers
@onready var status_tooltip: Label = %StatusTooltip
@onready var start_game_button: Button = %StartGame

@onready var is_server := multiplayer.is_server()

@onready var players: Dictionary = MultiplayerHandler.players
@onready var hiders: Array[int] = MultiplayerHandler.hiders
@onready var seekers: Array[int] = MultiplayerHandler.seekers


func _process(_delta: float) -> void:
	update_waiting_screen()


func update_waiting_screen():
	player_count.text = "Current Players: " + str(MultiplayerHandler.players.size())
	ready_count.text = "Ready Players: " + str(hiders.size() + seekers.size())

	hiders_list.clear()

	for uid in hiders:
		hiders_list.add_item(MultiplayerHandler.get_player_name(uid))

	seekers_list.clear()

	for uid in seekers:
		seekers_list.add_item(MultiplayerHandler.get_player_name(uid))

	if is_everyone_ready():
		status_tooltip.text = "Waiting for the host start the game..."
		if is_server:
			start_game_button.show()
	else:
		status_tooltip.text = "Waiting for every player to choose a side..."
		start_game_button.hide()


func is_everyone_ready() -> bool:
	return hiders.size() + seekers.size() == players.size()


func _on_join_hiders_pressed() -> void:
	MultiplayerHandler.join_hiders.rpc(multiplayer.get_unique_id())


func _on_join_seekers_pressed() -> void:
	MultiplayerHandler.join_seekers.rpc(multiplayer.get_unique_id())


func _on_hiders_list_item_activated(index: int) -> void:
	var id: int = hiders[index]
	MultiplayerHandler.disconnect_player.rpc_id(id)

func _on_seekers_list_item_activated(index: int) -> void:
	var id: int = seekers[index]
	MultiplayerHandler.disconnect_player.rpc_id(id)


func _on_start_game_pressed() -> void:
	MultiplayerHandler.load_game.rpc("res://scenes/game/game.tscn")
