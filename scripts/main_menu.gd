extends Control

@onready var ip: LineEdit = $MarginContainer/VBoxContainer/IP


func _on_host_pressed() -> void:
	MultiplayerHandler.host()


func _on_join_pressed() -> void:
	MultiplayerHandler.join(ip.text)


func _on_name_text_changed(new_text: String) -> void:
	MultiplayerHandler.player_name = new_text
