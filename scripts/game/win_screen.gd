extends CanvasLayerRPC

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var label: Label = $VBoxContainer/LabelRPC

@rpc("authority", "call_local", "reliable")
func hiders_win():
	label.text = "Hiders Win !!!"
	label.add_theme_color_override("font_color", Color(0.62, 0.879, 0.937))
	show()
	animation_player.play("flicker")


@rpc("authority", "call_local", "reliable")
func seekers_win():
	label.text = "Seekers Win !!!"
	label.add_theme_color_override("font_color", Color(0.925, 0.492, 0.42))
	show()
	animation_player.play("flicker")
