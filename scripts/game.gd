extends Node2D
class_name Game

const PLAYER = preload("res://scenes/player.tscn")
@onready var waiting_screen: CanvasLayer = %WaitingScreen
@onready var player_count: Label = $WaitingScreen/VBoxContainer/PlayerCount
@onready var ready_count: Label = $WaitingScreen/VBoxContainer/ReadyCount
@onready var start_game: Button = $WaitingScreen/VBoxContainer/StartGame
@onready var spawn_point: Marker2D = $LevelMap/SpawnPoint



var players: Array[Player] = []
var peer = ENetMultiplayerPeer.new()


func _ready() -> void:
	%MultiplayerSpawner.spawn_function = add_player
	if GameHandler.is_host:
		GameHandler.player_ready(multiplayer.get_unique_id())
		start_game.show()
	else:
		GameHandler.player_ready.rpc_id(1, multiplayer.get_unique_id())


func _process(delta: float) -> void:
	if !GameHandler.is_host:
		return

	start_game.visible = GameHandler.is_everyone_ready()
	update_wating_screen.rpc(multiplayer.get_peers().size() + 1, GameHandler.ready_players.size())

	if GameHandler.is_everyone_ready() and GameHandler.game_started:
		
		print("All players are ready, starting the game...")
		hide_wating_screen.rpc()
		while !GameHandler.new_players.is_empty():
			var pid = GameHandler.new_players.pop_front()
			player_joined(pid)
		GameHandler.game_started = false
	
		#Transition.cross_fade()

func player_joined(pid):
	# Called when a player joins the game
	print("Player added: " + str(pid))
	%MultiplayerSpawner.spawn(pid)


func add_player(n):
	var player = PLAYER.instantiate()

	players.append(player)
	
	player.set_multiplayer_authority(n)

	player.name = str(n)
	player.global_position = spawn_point.global_position

	var name_tag = player.find_child("Name")
	name_tag.text = "P" + str(len(players))

	return player


func _on_start_game_pressed() -> void:
	GameHandler.game_started = true


@rpc("call_local")
func update_wating_screen(all_player, ready_player):
	player_count.text = "Current Players: " + str(all_player)
	ready_count.text = "Ready Players: " + str(ready_player)


@rpc("call_local")
func hide_wating_screen():
	waiting_screen.hide()
