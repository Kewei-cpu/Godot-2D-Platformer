extends Node

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func fade_from_black():
	animation_player.play("fade_from_black")
	await animation_player.animation_finished


func fade_to_black():
	animation_player.play("fade_to_black")
	await animation_player.animation_finished


func cross_fade():
	animation_player.play("cross_fade")
