extends Control


@onready var player_name: LineEdit = $MarginContainer/VBoxContainer/Name
@onready var ip: LineEdit = $MarginContainer/VBoxContainer/IP


func _on_host_pressed() -> void:
	MultiplayerHandler.create_game()
	await Fade.fade_out(0.5, Color.BLACK, "Diamond").finished
	get_tree().change_scene_to_file("res://scenes/game/lobby.tscn")
	Fade.fade_in(0.5, Color.BLACK, "Noise")

func _on_join_pressed() -> void:
	if ip.text == null or !ip.text.contains("."):
		return
	MultiplayerHandler.join_game(ip.text)
	await Fade.fade_out(0.5, Color.BLACK, "Diamond").finished
	get_tree().change_scene_to_file("res://scenes/game/lobby.tscn")
	Fade.fade_in(0.5, Color.BLACK, "Noise")


func _on_name_text_changed(new_text: String) -> void:
	if new_text == "":
		return
	
	MultiplayerHandler.player_info["name"] = new_text
