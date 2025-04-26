extends Control

@onready var ip: LineEdit = $MarginContainer/VBoxContainer/IP


func _on_host_pressed() -> void:
	GameHandler.host()


func _on_join_pressed() -> void:
	GameHandler.join(ip.text)
