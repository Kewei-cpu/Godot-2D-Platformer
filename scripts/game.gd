extends Node2D
class_name Game

const PLAYER = preload("res://scenes/player.tscn")

@onready var waiting_screen: CanvasLayer = %WaitingScreen
@onready var player_count: Label = %PlayerCount
@onready var ready_count: Label = %ReadyCount
@onready var start_game_button: Button = %StartGame
@onready var spawn_point: Marker2D = $LevelMap/SpawnPoint

@onready var hiders_list: ItemList = %HidersList
@onready var join_hiders: Button = %JoinHiders
@onready var seekers_list: ItemList = %SeekersList
@onready var join_seekers: Button = %JoinSeekers


@export var names_dict: Dictionary = {}
@export var ready_players: Array[int] = []
@export var hiders: Array[int] = []
@export var seekers: Array[int] = []


func _ready() -> void:
	multiplayer.allow_object_decoding = true
	%MultiplayerSpawner.spawn_function = add_player
	if multiplayer.is_server():
		player_ready(multiplayer.get_unique_id(), GameHandler.player_name)
	else:
		player_ready.rpc_id(1, multiplayer.get_unique_id(), GameHandler.player_name)
		start_game_button.hide()


func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_F3):
		print(ready_players, hiders, seekers)
	
	if !multiplayer.is_server():
		return

	start_game_button.visible = is_everyone_ready()
	update_waiting_screen.rpc(multiplayer.get_peers().size() + 1, ready_players.size())


func player_joined(uid: int) -> void:
	# Called when a player joins the game
	print("Player added: " + str(uid))
	%MultiplayerSpawner.spawn(uid)


func add_player(uid):
	var player = PLAYER.instantiate()
	player.set_multiplayer_authority(uid)

	player.name = str(uid)
	player.global_position = spawn_point.global_position

	var name_tag: Label = player.find_child("Name")
	name_tag.text = get_player_name(uid)

	return player


func _on_start_game_pressed() -> void:
	if is_everyone_ready():
		print("All players_in_game are ready, starting the game...")
		hide_waiting_screen.rpc()
		for uid in GameHandler.players:
			player_joined(uid)


func is_everyone_ready() -> bool:
	# Check if all players are ready
	return true


func get_player_name(uid: int) -> String:
	# Get the player name from the player list
	if uid in names_dict:
		return names_dict[uid]

	return "Unknown Player"


@rpc("any_peer")
func player_ready(uid: int, player_name: String):
	# Called when a player is ready
	print("Player %s is ready! (uid: %s)" % [get_player_name(uid), uid])

	# Check if the player is already in the list
	if uid in names_dict:
		print("Player %s is already in the list (uid: %s)" % [get_player_name(uid), uid])
		return

	names_dict[uid] = player_name
	ready_players.append(uid)

	update_players_info.rpc(GameHandler.players, names_dict)

@rpc("call_remote")
func update_players_info(players_list, _names_dict):
	GameHandler.players = players_list
	names_dict = _names_dict

@rpc("call_local")
func update_waiting_screen(all_player, ready_player):
	player_count.text = "Current Players: " + str(all_player)
	ready_count.text = "Ready Players: " + str(ready_player)


@rpc("any_peer")
func join_hider(uid: int):
	if uid in hiders:
		print("Player %s is already in hiders (uid: %s)" % [get_player_name(uid), uid])
		return
	
	if uid in seekers:
		seekers.erase(uid)
		update_seekers_list.rpc(seekers)

	print("Player %s joined hiders (uid: %s)" % [get_player_name(uid), uid])

	hiders.append(uid)
	update_hiders_list.rpc(hiders)


@rpc("any_peer")
func join_seeker(uid: int):
	if uid in seekers:
		print("Player %s is already in seekers (uid: %s)" % [get_player_name(uid), uid])
		return

	if uid in hiders:
		hiders.erase(uid)
		update_hiders_list.rpc(hiders)

	print("Player %s joined seekers (uid: %s)" % [get_player_name(uid), uid])

	seekers.append(uid)
	update_seekers_list.rpc(seekers)


@rpc("call_local")
func update_hiders_list(_hiders):
	print("hiders: %s" % str(_hiders))
	hiders_list.clear()

	for uid in _hiders:
		hiders_list.add_item(get_player_name(uid))

@rpc("call_local")
func update_seekers_list(_seekers):
	print("seekers: %s" % str(_seekers))
	seekers_list.clear()

	for uid in _seekers:
		seekers_list.add_item(get_player_name(uid))

@rpc("call_local")
func hide_waiting_screen():
	waiting_screen.hide()


func _on_join_hiders_pressed() -> void:
	if multiplayer.is_server():
		join_hider(multiplayer.get_unique_id())
	else:
		join_hider.rpc_id(1, multiplayer.get_unique_id())


func _on_join_seekers_pressed() -> void:
	if multiplayer.is_server():
		join_seeker(multiplayer.get_unique_id())
	else:
		join_seeker.rpc_id(1, multiplayer.get_unique_id())
