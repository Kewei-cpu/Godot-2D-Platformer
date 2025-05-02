class_name Player
extends CharacterBody2D

@onready var name_tag: Label = %NameTag

@onready var character_sprite: AnimatedSprite2D = %CharacterSprite
@onready var block_sprite: AnimatedSprite2D = %BlockSprite

@onready var character_collision: CollisionShape2D = %CharacterCollision
@onready var block_collision: CollisionShape2D = %BlockCollision

@onready var gun_container: Node2D = %GunContainer
@onready var gun_sprite: Sprite2D = %GunSprite
@onready var muzzle: Marker2D = %Muzzle
@onready var center: Marker2D = %Center

@onready var cool_down: Timer = %CoolDown
@onready var coyote_timer: Timer = %CoyoteTimer
@onready var jump_request_timer: Timer = %JumpRequestTimer
@onready var hit_color: Timer = %HitColor

@onready var respawn_timer: Timer = %RespawnTimer
@onready var death_screen: CanvasLayer = %DeathScreen
@onready var respawn_time_left: Label = %RespawnTimeLeft

@onready var terrain: TileMapLayer = $"../LevelMap/Midground"
@onready var spawn_points: Node2D = $"../LevelMap/SpawnPoints"

@onready var inventory: Inventory = %Inventory
@onready var enemy_indicator: CanvasLayer = %EnemyIndicator

@onready var healthbar_background: ColorRect = %HealthbarBackground
@onready var health_fill: ColorRect = %HealthFill
@onready var health_label: Label = %HealthLabel

@onready var game: Game = get_parent()

const CAMERA = preload("res://scenes/camera.tscn")
const BULLET = preload("res://scenes/bullet.tscn")

@export var MAX_SPEED = 175
@export var JUMP_VELOCITY = -300

@export var GROUND_ACCELERATION = 1200
@export var AIR_ACCELERATION = 800
@export var GROUND_FRICTION = 1000
@export var AIR_FRICTION = 600

@export var MAX_HEALTH = 100

var camouflaged = false
var frozen = false
var dead = false

var health = MAX_HEALTH

enum Team {
	HIDER,
	SEEKER,
}
var player_team: Team


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()


func _ready() -> void:
	player_team = Team.HIDER if get_multiplayer_authority() in game.hiders else Team.SEEKER

	set_player_collision_layer()

	if not is_multiplayer_authority():
		return

	if player_team == Team.HIDER:
		cool_down.wait_time = 0.2

	inventory.show()
	var camera = CAMERA.instantiate()
	add_child(camera)


func _process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	handle_dead()

	if dead:
		return

	handle_camouflage()
	handle_freeze()
	inventory.handle_slot_change()
	inventory.handle_item_use()

	show_hit_color()

	if Input.is_key_pressed(KEY_F1):
		var enemy := game.hiders if player_team == Team.SEEKER else game.seekers
		for uid in enemy:
			var enemy_player = get_node("../" + str(uid))
			enemy_indicator.set_target(enemy_player)


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return

	if dead:
		return

	if frozen:
		velocity = Vector2(0, 0)
		global_position = global_position.snapped(Vector2(16, 16))
		return

	handle_shoot()

	var should_jump: bool = handle_jump(delta)

	handle_move(delta)

	var was_on_floor := is_on_floor()
	move_and_slide()

	if is_on_floor() != was_on_floor:
		if was_on_floor and not should_jump:
			coyote_timer.start()
		else:
			coyote_timer.stop()


func handle_dead():
	if dead:
		hide()
		character_collision.disabled = true
		block_collision.disabled = true
		death_screen.show()
		respawn_time_left.text = str(snappedf(respawn_timer.time_left, 0.1))
	else:
		show()
		character_collision.disabled = camouflaged
		block_collision.disabled = not camouflaged
		death_screen.hide()


func handle_camouflage():
	if player_team == Team.SEEKER:
		return

	if Input.is_action_just_pressed("switch"):
		if frozen:
			return
		set_camouflage(not camouflaged)


func handle_freeze():
	if player_team == Team.SEEKER:
		return

	if Input.is_action_just_pressed("lock"):
		if not camouflaged:
			return
		set_frozen(not frozen)


func handle_shoot():
	gun_container.look_at(get_global_mouse_position())
	gun_sprite.flip_v = get_global_mouse_position().x < global_position.x

	if Input.is_action_just_pressed("shoot") and not camouflaged:
		if !cool_down.is_stopped():
			return
		shoot()
		cool_down.start()


func handle_jump(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_released("jump"):
		if velocity.y < JUMP_VELOCITY * 0.5 and not is_on_floor():
			velocity.y = JUMP_VELOCITY * 0.5

	# Handle jump.
	var can_jump := is_on_floor() or coyote_timer.time_left > 0.0
	var should_jump := can_jump and jump_request_timer.time_left > 0.0
	if should_jump:
		velocity.y = JUMP_VELOCITY
		coyote_timer.stop()
		jump_request_timer.stop()

	return should_jump


func handle_move(delta):
	var direction := Input.get_axis("move_left", "move_right")
	var speed_direction := 1 if velocity.x > 0 else -1 if velocity.x < 0 else 0

	if is_on_floor():
		if direction:
			velocity.x = clampf(velocity.x + direction * GROUND_ACCELERATION * delta, -MAX_SPEED, MAX_SPEED)
		else:
			velocity.x -= speed_direction * clampf(GROUND_FRICTION * delta, 0, abs(velocity.x))

	else:
		if direction:
			velocity.x = clampf(velocity.x + direction * AIR_ACCELERATION * delta, -MAX_SPEED, MAX_SPEED)
		else:
			velocity.x -= speed_direction * clampf(AIR_FRICTION * delta, 0, abs(velocity.x))

	if is_on_floor():
		if velocity.x == 0:
			character_sprite.play("idle")
		else:
			character_sprite.play("run")
			character_sprite.flip_h = velocity.x < 0
	else:
		character_sprite.play("jump")


func show_hit_color():
	if hit_color.is_stopped():
		character_sprite.modulate = Color(1, 1, 1)
		block_sprite.modulate = Color(1, 1, 1)

	else:
		character_sprite.modulate = Color(0.906, 0.306, 0.357)
		block_sprite.modulate = Color(0.906, 0.306, 0.357)


func respawn():
	velocity = Vector2(0, 0)
	dead = false

	set_health(MAX_HEALTH)
	update_health_bar()
	call_deferred("set_camouflage", false)
	call_deferred("set_frozen", false)

	set_player_collision_layer()


func set_camouflage(is_camouflage: bool):
	camouflaged = is_camouflage

	if is_camouflage:
		var random_camouflage = randi() % 48  # total 48 sprites

		if random_camouflage < 25:
			block_sprite.play("block")
			block_sprite.frame = random_camouflage
		else:
			block_sprite.play("item")
			block_sprite.frame = random_camouflage - 25

	character_sprite.visible = !is_camouflage
	block_sprite.visible = is_camouflage

	character_collision.disabled = is_camouflage
	block_collision.disabled = !is_camouflage

	gun_container.visible = !is_camouflage


func set_frozen(is_frozen: bool):
	frozen = is_frozen
	name_tag.visible = !is_frozen
	health_fill.visible = !is_frozen
	health_label.visible = !is_frozen
	healthbar_background.visible = !is_frozen

	clear_player_collision_layer()
	if player_team == Team.HIDER:
		set_collision_layer_value(2, !is_frozen)
		if block_sprite.animation == "block":
			set_collision_layer_value(4, is_frozen)
		else:
			set_collision_layer_value(6, is_frozen)
	else:
		set_collision_layer_value(3, !is_frozen)
		if block_sprite.animation == "block":
			set_collision_layer_value(5, is_frozen)
		else:
			set_collision_layer_value(7, is_frozen)


func clear_player_collision_layer():
	set_collision_layer_value(2, false)
	set_collision_layer_value(3, false)
	set_collision_layer_value(4, false)
	set_collision_layer_value(5, false)
	set_collision_layer_value(6, false)
	set_collision_layer_value(7, false)


func set_player_collision_layer():
	if player_team == Team.HIDER:
		set_collision_layer_value(2, true)
		set_collision_mask_value(3, true)
	else:
		set_collision_layer_value(3, true)
		set_collision_mask_value(2, true)


@rpc("any_peer")
func bullet_hit(damage, collision_normal, hitback):
	change_health(-damage)

	velocity += collision_normal * hitback
	hit_color.start()


func shoot():
	var bullet_transform := Transform2D(muzzle.get_global_rotation(), muzzle.get_global_position())
	fire_bullet.rpc(multiplayer.get_unique_id(), bullet_transform)


func die():
	respawn_timer.start()
	dead = true
	clear_player_collision_layer()

	var spawn_point: Marker2D = spawn_points.get_children().pick_random()
	global_position = spawn_point.global_position


@rpc("call_local")
func fire_bullet(pid, bullet_transform: Transform2D):
	var bullet = BULLET.instantiate()
	bullet.transform = bullet_transform
	bullet.velocity = velocity
	bullet.set_multiplayer_authority(pid)

	var bullet_team = Team.HIDER if pid in game.hiders else Team.SEEKER

	if bullet_team == Team.HIDER:
		bullet.set_collision_mask_value(3, true)
		bullet.set_collision_mask_value(5, true)
		bullet.set_collision_mask_value(7, true)
	else:
		bullet.set_collision_mask_value(2, true)
		bullet.set_collision_mask_value(4, true)
		bullet.set_collision_mask_value(6, true)

	get_parent().add_child(bullet)


func update_health_bar():
	if not is_inside_tree():
		return

	var health_ratio = float(health) / MAX_HEALTH
	health_fill.scale.x = health_ratio

	health_label.text = str(health)

	if health_ratio < 0.3:
		health_fill.color = Color(0.928, 0.329, 0.199, 0.784)
	elif health_ratio < 0.6:
		health_fill.color = Color(0.914, 0.686, 0.165, 0.784)
	else:
		health_fill.color = Color(0.0, 0.745, 0.247, 0.659)


func change_health(amount: int) -> void:
	health = clamp(health + amount, 0, MAX_HEALTH)
	update_health_bar()
	if health == 0:
		die()


func set_health(value: int) -> void:
	health = clamp(value, 0, MAX_HEALTH)
	update_health_bar()


func _on_respawn_timer_timeout() -> void:
	respawn()
