extends Node2D
class_name Game

const PLAYER = preload("res://scenes/player/player.tscn")

@onready var seeker_waiting_screen: CanvasLayerRPC = %SeekerWaitingScreen
@onready var hide_time_left: Label = %HideTimeLeft

@onready var seeking_time: CanvasLayerRPC = %SeekingTime
@onready var seek_time_left: Label = %SeekTimeLeft
@onready var hiding_time: CanvasLayerRPC = %HidingTime
@onready var hider_hide_time_left: Label = %HiderHideTimeLeft

@onready var hide_timer: Timer = %HideTimer
@onready var seek_timer: Timer = %SeekTimer

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var spawn_points: Node2D = %LevelMap/SpawnPoints

@onready var is_server = multiplayer.is_server()

@onready var players: Dictionary = MultiplayerHandler.players
@onready var hiders: Array[int] = MultiplayerHandler.hiders
@onready var seekers: Array[int] = MultiplayerHandler.seekers


func _ready() -> void:
	multiplayer_spawner.spawn_function = add_player_to_scene
	MultiplayerHandler.server_disconnected.connect(MultiplayerHandler.disconnect_player)
	MultiplayerHandler.player_disconnected.connect(remove_player_from_scene)
	MultiplayerHandler.player_loaded.rpc_id(1)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("quit"):
		MultiplayerHandler.disconnect_player()

	if not is_server:
		return

	if not hide_timer.is_stopped():
		for uid in seekers:
			update_seeker_waiting_screen.rpc_id(uid, snappedf(hide_timer.time_left, 0.1))
		for uid in hiders:
			update_hider_hide_time_display.rpc_id(uid, snappedf(hide_timer.time_left, 0.1))

	if not seek_timer.is_stopped():
		update_seeking_time_display.rpc(snappedf(seek_timer.time_left, 0.1))

	if Input.is_action_just_pressed("restart"):
		back_to_lobby.rpc()


func start_game():
	for uid in hiders:
		multiplayer_spawner.spawn(uid)
		hiding_time.show_rpc.rpc_id(uid)

	for uid in seekers:
		seeker_waiting_screen.show_rpc.rpc_id(uid)

	hide_timer.start()


func add_player_to_scene(uid):
	var player = PLAYER.instantiate()
	player.set_multiplayer_authority(uid)

	player.name = str(uid)

	var spawn_point: Marker2D = spawn_points.get_children().pick_random()
	player.global_position = spawn_point.global_position

	var name_tag: Label = player.find_child("NameTag")
	name_tag.text = MultiplayerHandler.get_player_name(uid)

	return player


func remove_player_from_scene(uid):
	var player = get_node(str(uid))
	
	if player:
		player.queue_free()


@rpc("authority", "call_local", "reliable")
func back_to_lobby():
	await Fade.fade_out(0.5, Color.BLACK, "Noise").finished
	get_tree().change_scene_to_file("res://scenes/game/lobby.tscn")
	Fade.fade_in(0.5, Color.BLACK, "Diamond")


@rpc("call_local", "any_peer")
func update_seeker_waiting_screen(time_left):
	hide_time_left.text = str(time_left)


@rpc("call_local", "any_peer")
func update_hider_hide_time_display(time_left):
	hider_hide_time_left.text = str(time_left)


@rpc("call_local", "any_peer")
func update_seeking_time_display(time_left):
	seek_time_left.text = str(time_left)


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
