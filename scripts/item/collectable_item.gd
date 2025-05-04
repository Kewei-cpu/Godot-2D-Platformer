class_name Collectable
extends Area2D

@export var icon_texture: Texture2D
@export var useable: bool = true
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var player: Player = null
var time := 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

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
		hide_item.rpc()
	else:
		print("No room!")


func on_player_use() -> bool:
	# return true if the item is still kept after use

	return false


func on_constant_effect():
	pass


@rpc("call_local", "any_peer")
func hide_item():
	collision_shape_2d.set_deferred("disabled", true)
	animated_sprite_2d.hide()


@rpc("call_local")
func destroy():
	queue_free()
