class_name Collectable
extends Area2D

@export var icon_texture: Texture2D
@export var useable: bool = true
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var point_light_2d: PointLight2D = $PointLight2D

var player: Player
var time := 0.0


func _process(delta: float) -> void:
	animated_sprite_2d.position.y = -3 + 3 * sin(2 * time)
	time += delta

	if !player:
		return
		
	on_constant_effect()


func _on_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	player = body
	
	if not player.is_multiplayer_authority():
		return

	var is_collected: bool = player.inventory.add_item_to_inventory(self)

	if is_collected:
		item_collected.rpc(player.get_multiplayer_authority())
	else:
		print("No room!")


func on_player_use() -> bool:
	# return true if the item is still kept after use

	return false


func on_constant_effect():
	pass


@rpc("call_local", "any_peer")
func item_collected(uid: int):
	var player: Player = get_node("/root/Game/" + str(uid))
	call_deferred("reparent", player)
	collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.hide()
	point_light_2d.enabled = false

@rpc("call_local")
func destroy():
	queue_free()
