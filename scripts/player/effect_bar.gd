class_name EffectBar
extends CanvasLayer

@onready var h_box_container: HBoxContainer = $MarginContainer/HBoxContainer


func _ready() -> void:
	if not is_multiplayer_authority():
		return

	show()


func add_effect(effect_scene: PackedScene):
	var effect: Effect = effect_scene.instantiate()

	h_box_container.add_child(effect)
