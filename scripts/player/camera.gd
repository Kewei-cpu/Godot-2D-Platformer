class_name PlayerCamera
extends Camera2D

var target_zoom: Vector2 
var tween: Tween

func change_zoom_tween(amount: Vector2) -> void:
	target_zoom = zoom + amount
	
	if tween and tween.is_valid():
		tween.kill()
		
	tween = create_tween()
	tween.tween_property(self, "zoom", target_zoom, 0.5)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_CUBIC)
