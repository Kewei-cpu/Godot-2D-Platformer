extends Control

@onready var ip: LineEdit = $MarginContainer/VBoxContainer/IP


func _on_host_pressed() -> void:
	GameHandler.host()


func _on_join_pressed() -> void:
	GameHandler.join(ip.text)


func _on_name_text_changed(new_text: String) -> void:
	GameHandler.player_name = new_text
