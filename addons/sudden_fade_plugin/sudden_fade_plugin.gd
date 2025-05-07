@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("FadeTransitionManager", "ColorRect", preload("fade_transition_manager.gd"), null)
	pass


func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	pass
