class_name EffectArea
extends Area2D


@export var effect: PackedScene

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_waiting_timer: Timer = $AnimationWaitingTimer


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.effect_bar.add_effect(effect)


func _on_lasting_timer_timeout() -> void:
	animation_player.play("shrink")
	animation_waiting_timer.start()


func _on_animation_waiting_timer_timeout() -> void:
	queue_free()
