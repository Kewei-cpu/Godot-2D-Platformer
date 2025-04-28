extends Node

var player_name: String = "Anony"
var players: Array[int] = []
var peer = ENetMultiplayerPeer.new()


func host(port = 25565) -> void:
	peer.create_server(port)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(func(pid): players.append(pid))
	print(player_name)
	players.append(multiplayer.get_unique_id())

	await Transition.fade_to_black()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	Transition.fade_from_black()


func join(ip, port = 25565) -> void:
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer

	await Transition.fade_to_black()
	get_tree().change_scene_to_file("res://scenes/game.tscn")
	Transition.fade_from_black()
