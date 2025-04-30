extends Node2D
class_name Game

const PLAYER = preload("res://scenes/player.tscn")

@onready var waiting_screen: CanvasLayerRPC = %WaitingScreen
@onready var player_count: Label = %PlayerCount
@onready var ready_count: Label = %ReadyCount
@onready var spawn_point: Marker2D = $LevelMap/SpawnPoint

@onready var hiders_list: ItemList = %HidersList
@onready var join_hiders: Button = %JoinHiders
@onready var seekers_list: ItemList = %SeekersList
@onready var join_seekers: Button = %JoinSeekers
@onready var status_tooltip: Label = %StatusTooltip
@onready var start_game_button: Button = %StartGame

@onready var seeker_waiting_screen: CanvasLayerRPC = %SeekerWaitingScreen
@onready var hide_time_left: Label = %HideTimeLeft

@onready var seeking_time: CanvasLayerRPC = %SeekingTime
@onready var seek_time_left: Label = %SeekTimeLeft
@onready var hiding_time: CanvasLayerRPC = %HidingTime
@onready var hider_hide_time_left: Label = %HiderHideTimeLeft

@onready var hide_timer: Timer = %HideTimer
@onready var seek_timer: Timer = %SeekTimer

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

@onready var is_server = multiplayer.is_server()

var players: Array[int] = []
var names_dict: Dictionary = {}
var hiders: Array[int] = []
var seekers: Array[int] = []


func _ready() -> void:
	multiplayer_spawner.spawn_function = add_player_to_scene
	if multiplayer.is_server():
		player_ready(multiplayer.get_unique_id(), MultiplayerHandler.player_name)
	else:
		player_ready.rpc_id(1, multiplayer.get_unique_id(), MultiplayerHandler.player_name)
		start_game_button.hide()


func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return
	
	if not hide_timer.is_stopped():
		for uid in seekers:
			update_seeker_waiting_screen.rpc_id(uid, snappedf(hide_timer.time_left, 0.1))
		for uid in hiders:
			update_hider_hide_time_display.rpc_id(uid, snappedf(hide_timer.time_left, 0.1))
	
	if not seek_timer.is_stopped():
		update_seeking_time_display.rpc(snappedf(seek_timer.time_left, 0.1))

	
func add_player_to_scene(uid):
	var player = PLAYER.instantiate()
	player.set_multiplayer_authority(uid)

	player.name = str(uid)
	player.global_position = spawn_point.global_position

	var name_tag: Label = player.find_child("Name")
	name_tag.text = get_player_name(uid)

	return player


func is_everyone_ready() -> bool:
	return players.size() == hiders.size() + seekers.size()


func get_player_name(uid: int) -> String:
	if uid in names_dict:
		return names_dict[uid]
	return "Unknown Player"


@rpc("any_peer")
func player_ready(uid: int, player_name: String):
	names_dict[uid] = player_name
	players.append(uid)

	print("Player %s is ready! (uid: %s)" % [get_player_name(uid), uid])
	update_players_info.rpc(players, names_dict, hiders, seekers)


@rpc("any_peer")
func join_hider(uid: int):
	if uid in hiders:
		print("Player %s is already in hiders (uid: %s)" % [get_player_name(uid), uid])
		return
	
	if uid in seekers:
		seekers.erase(uid)

	print("Player %s joined hiders (uid: %s)" % [get_player_name(uid), uid])

	hiders.append(uid)
	update_players_info.rpc(players, names_dict, hiders, seekers)


@rpc("any_peer")
func join_seeker(uid: int):
	if uid in seekers:
		print("Player %s is already in seekers (uid: %s)" % [get_player_name(uid), uid])
		return

	if uid in hiders:
		hiders.erase(uid)

	print("Player %s joined seekers (uid: %s)" % [get_player_name(uid), uid])

	seekers.append(uid)

	update_players_info.rpc(players, names_dict, hiders, seekers)

@rpc("call_local")
func update_players_info(_players, _names_dict, _hiders, _seekers):
	if not multiplayer.is_server():
		players = _players
		names_dict = _names_dict
		hiders = _hiders
		seekers = _seekers

	update_waiting_screen()

func update_waiting_screen():
	player_count.text = "Current Players: " + str(players.size())
	ready_count.text = "Ready Players: " + str(hiders.size() + seekers.size())

	hiders_list.clear()

	for uid in hiders:
		hiders_list.add_item(get_player_name(uid))

	seekers_list.clear()

	for uid in seekers:
		seekers_list.add_item(get_player_name(uid))
		
	if is_everyone_ready():
		status_tooltip.text = "Waiting for the host start the game..."
		if is_server:
			start_game_button.show()
	else:
		status_tooltip.text = "Waiting for every one to choose a side..."
		start_game_button.hide()
		
@rpc("call_local", "any_peer")
func update_seeker_waiting_screen(time_left):
	hide_time_left.text = str(time_left)
	
@rpc("call_local", "any_peer")
func update_hider_hide_time_display(time_left):
	hider_hide_time_left.text = str(time_left)
	
@rpc("call_local", "any_peer")
func update_seeking_time_display(time_left):
	seek_time_left.text = str(time_left)

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


func _on_start_game_pressed() -> void:
	if not is_server:
		return
	
	if is_everyone_ready():
		print("All players_in_game are ready, starting the game...")
		waiting_screen.hide_rpc.rpc()
		for uid in hiders:
			multiplayer_spawner.spawn(uid)
			hiding_time.show_rpc.rpc_id(uid)
		for uid in seekers:	
			seeker_waiting_screen.show_rpc.rpc_id(uid)
			
		hide_timer.start()


func _on_hide_timer_timeout() -> void:
	if not is_server:
		return
	
	for uid in hiders:
		hiding_time.hide_rpc.rpc_id(uid)
		seeking_time.show_rpc.rpc_id(uid)
	
	for uid in seekers:
		seeker_waiting_screen.hide_rpc.rpc_id(uid)
		multiplayer_spawner.spawn(uid)
		seeking_time.show_rpc.rpc_id(uid)
		
	seek_timer.start()
