extends Node

const local_stats_path := "user://local_stats.data"

@export var local_stats := {
	"name": "",
	"ip": "",
}


func _ready() -> void:
	load_local_stats()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_local_stats()
		get_tree().quit()


func save_local_stats() -> void:
	var file = FileAccess.open(local_stats_path, FileAccess.WRITE)
	file.store_var(local_stats)
	file.close()


func load_local_stats() -> void:
	var file = FileAccess.open(local_stats_path, FileAccess.READ)
	if not file:
		return

	local_stats = file.get_var()
	file.close()
