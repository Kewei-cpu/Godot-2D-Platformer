extends RigidBody2D

@export var speed = 500
@export var damage = 10
@export var hitback = 100

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var life_timer: Timer = $LifeTimer
@onready var vanish_timer: Timer = $VanishTimer

var velocity: Vector2
var has_hit := false

func _ready() -> void:
	set_collision_layer_value(3, true) 
	set_collision_mask_value(1, false) 
	set_collision_mask_value(2, true)  
	
func _physics_process(delta: float) -> void:
	if has_hit:
		return
	
	velocity = transform.x.normalized() * speed
	var collision = move_and_collide(velocity * delta) 

	if !is_multiplayer_authority():
		return
	if !collision:
		return

	var body = collision.get_collider()
	if body is Player:
		if body.get_multiplayer_authority() == multiplayer.get_unique_id():
			return
		body.bullet_hit.rpc_id(body.get_multiplayer_authority(), damage, collision.get_normal(), hitback)

	if body is TileMapLayer:
		var coord: Vector2i = body.local_to_map(body.to_local(collision.get_position() - collision.get_normal()))

	remove_bullet.rpc()


@rpc("call_local", "any_peer")
func remove_bullet():
	has_hit = true
	sprite_2d.hide()
	collision_shape_2d.disabled = true
	vanish_timer.start(1)


func _on_life_timer_timeout() -> void:
	queue_free()
