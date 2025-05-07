extends Node
## This is the parent node of this scene. 
## 
## It contains logic to load a next scene 
## when a button is pressed.
func _on_new_game_pressed() -> void:
	$FadeTransitionManager.fade_out()
