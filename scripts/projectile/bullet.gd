extends Projectile

@export var damage = 10
@export var hitback = 100

@onready var bullet_hit_particle: CPUParticles2D = $BulletHitParticle
@onready var bullet_gradient_green = preload("res://resources/bullet_gradient_green.tres")
@onready var bullet_gradient_red = preload("res://resources/bullet_gradient_red.tres")


func _on_body_entered(body: Node) -> void:
	if body is Player:
		bullet_hit_particle.color_ramp = bullet_gradient_red

	call_deferred("remove_bullet")

	if not is_multiplayer_authority():
		return

	if body is Player:
		if body.get_multiplayer_authority() == multiplayer.get_unique_id():
			return
		body.bullet_hit.rpc_id(body.get_multiplayer_authority(), damage, transform.x.normalized(), hitback, source_id, DeathCause.DeathCause.SHOT)


@rpc("call_local", "any_peer")
func remove_bullet():
	bullet_hit_particle.emitting = true
	hide_all()
