extends Node2D

@onready var multiplayer_ui: Control = $UI/Multiplayer
@onready var ip: LineEdit = $UI/Multiplayer/VBoxContainer/IP

const PLAYER = preload("res://scenes/player.tscn")

var peer = ENetMultiplayerPeer.new()
var players: Array[Player] = []


func _ready() -> void:
	$MultiplayerSpawner.spawn_function = add_player


func _on_host_pressed() -> void:
	peer.create_server(25565)
	multiplayer.multiplayer_peer = peer

	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined your game!")
			$MultiplayerSpawner.spawn(pid)
	)

	$MultiplayerSpawner.spawn(multiplayer.get_unique_id())

	multiplayer_ui.hide()


func _on_join_pressed() -> void:
	peer.create_client(ip.text, 25565)
	multiplayer.multiplayer_peer = peer

	multiplayer_ui.hide()


func add_player(n):
	var player = PLAYER.instantiate()

	players.append(player)

	player.name = str(n)
	player.global_position = Vector2(16, -384)

	var name_tag = player.find_child("Name")
	name_tag.text = "P" + str(len(players))

	return player
