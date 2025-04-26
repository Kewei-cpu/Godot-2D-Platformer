class_name Collectable
extends Area2D

@export var icon_sprite: Sprite2D
@export var useable: bool = true

var player: Player = null


func _process(delta: float) -> void:
	if !player:
		return

	on_constant_effect()


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return
	player = body

	if not player.is_multiplayer_authority():
		return

	var collected := player.add_item_to_inventory(self)

	if collected:
		destroy()
	else:
		print("No room!")


func on_player_use() -> bool:
	# return true if the item is still kept after use
	
	return false


func on_constant_effect():
	pass


@rpc("call_local")
func destroy():
	queue_free()
