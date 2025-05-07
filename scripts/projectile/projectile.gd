class_name Projectile
extends RigidBody2D

@export var speed: float = 500
@export var initial_velocity: Vector2 = Vector2.ZERO

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var life_timer: Timer = $LifeTimer
@onready var trail: Line2D = $Trail
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	linear_velocity = transform.x.normalized() * speed + initial_velocity
	angular_velocity = 0.0


func hide_all():
	sprite_2d.hide()
	collision_shape_2d.disabled = true
	#point_light_2d.enabled = false
	gravity_scale = 0
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	trail.hide()
	animation_player.play("fade")
	life_timer.start(0.5)


func _on_life_timer_timeout() -> void:
	queue_free()
