extends Node

var peer = ENetMultiplayerPeer.new()

@export var is_host = false
@export var game_started = false
@export var new_players: Array[int] = []
@export var ready_players: Array[int] = []

func host(port = 25565) -> void:
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(func(pid): new_players.append(pid))
	var tree: SceneTree = get_tree()

	await Transition.fade_to_black()
	tree.change_scene_to_file("res://scenes/game.tscn")
	Transition.fade_from_black()

	is_host = true
	new_players.append(multiplayer.get_unique_id())


func join(ip, port = 25565) -> void:
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

	await Transition.fade_to_black()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	Transition.fade_from_black()
	
	

@rpc("any_peer")
func player_ready(pid: int) -> void:
	# Called when a player is ready
	print("Player ready: " + str(pid))
	
	# Add the player to the guest list
	ready_players.append(pid)


func is_everyone_ready() -> bool:
	# Check if all players are ready
	return ready_players.size() == multiplayer.get_peers().size()  + 1
