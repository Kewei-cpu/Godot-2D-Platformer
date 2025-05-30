class_name Player
extends CharacterBody2D

@onready var camera: PlayerCamera = %Camera

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

@onready var effect_bar: EffectBar = %EffectBar
@onready var inventory: Inventory = %Inventory
@onready var enemy_indicator: CanvasLayer = %EnemyIndicator

@onready var name_tag: Label = %NameTag
@onready var healthbar_background: ColorRect = %HealthbarBackground
@onready var health_fill: ColorRect = %HealthFill
@onready var health_label: Label = %HealthLabel

@onready var point_light_2d: PointLight2D = $PointLight2D

@onready var game: Game = get_parent()
@onready var is_authority = is_multiplayer_authority()

const BULLET = preload("res://scenes/projectile/bullet.tscn")
const GRENADE = preload("res://scenes/projectile/grenade.tscn")
const FLASHBANG = preload("res://scenes/projectile/flashbang.tscn")

const SPEED_EFFECT = preload("res://scenes/effect/speed_effect.tscn")
const SLOWNESS_EFFECT = preload("res://scenes/effect/slowness_effect.tscn")
const REGENERATION_EFFECT = preload("res://scenes/effect/regeneration_effect.tscn")
const JUMP_BOOST_EFFECT = preload("res://scenes/effect/jump_boost_effect.tscn")

@export var max_speed: int = 175
@export var jump_speed: int = -300

@export var ground_acceleration: int = 1200
@export var air_acceleration: int = 800
@export var ground_friction: int = 1000
@export var air_friction: int = 600

@export var max_health: int = 100

var last_death_cause: DeathCause.DeathCause = DeathCause.DeathCause.UNKNOWN

var camouflaged = false
var frozen = false
var dead = false
var camouflage_list: Array[int] = []
var current_camouflage = 0
var last_damage_source: int = 0

var health = IntStream.new()

enum Team {HIDER, SEEKER}

enum Projectile {Bullet, Grenade, Flashbang}

var player_team: Team


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()


func _ready() -> void:
	#var damage_input_ui = preload("res://scenes/player/damageinput.tscn").instantiate()
	#add_child(damage_input_ui)
	player_team = Team.HIDER if get_multiplayer_authority() in game.hiders else Team.SEEKER

	set_player_collision_layer()

	if not is_multiplayer_authority():
		return

	inventory.show()
	camera.enabled = true
	camera.make_current()

	set_health(max_health)

	if player_team == Team.HIDER:
		cool_down.wait_time = 0.25
		max_speed = 150
		camouflage_list.append(randi_range(0, 24))
		camouflage_list.append(randi_range(25, 47))
	else:
		camera.zoom = Vector2(4, 4)


func _process(_delta: float) -> void:
	if not is_authority:
		return

	handle_dead()

	if dead:
		return

	handle_camouflage()
	handle_freeze()
	inventory.handle_slot_change()
	inventory.handle_item_use()

	show_hit_color()

	#if Input.is_key_pressed(KEY_F1):
	#var enemy := game.hiders if player_team == Team.SEEKER else game.seekers
	#for uid in enemy:
	#var enemy_player = get_node_or_null("../" + str(uid))
	#
	#if enemy_player:
	#enemy_indicator.add_target(enemy_player)

	#if Input.is_action_just_pressed("test1"):
		#effect_bar.add_effect(SPEED_EFFECT)


func _physics_process(delta: float) -> void:
	if not is_authority:
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

	if Input.is_action_pressed("shoot") and not camouflaged:
		if !cool_down.is_stopped():
			return
		shoot(Projectile.Bullet)
		cool_down.start()


func handle_jump(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_released("jump"):
		if velocity.y < jump_speed * 0.5 and not is_on_floor():
			velocity.y = jump_speed * 0.5

	# Handle jump.
	var can_jump := is_on_floor() or coyote_timer.time_left > 0.0
	var should_jump := can_jump and jump_request_timer.time_left > 0.0
	if should_jump:
		velocity.y = jump_speed
		coyote_timer.stop()
		jump_request_timer.stop()

	return should_jump


func handle_move(delta):
	var direction := Input.get_axis("move_left", "move_right")
	var speed_direction := 1 if velocity.x > 0 else -1 if velocity.x < 0 else 0

	if is_on_floor():
		if direction:
			velocity.x = clampf(velocity.x + direction * ground_acceleration * delta, -max_speed, max_speed)
		else:
			velocity.x -= speed_direction * clampf(ground_friction * delta, 0, abs(velocity.x))

	else:
		if direction:
			velocity.x = clampf(velocity.x + direction * air_acceleration * delta, -max_speed, max_speed)
		else:
			velocity.x -= speed_direction * clampf(air_friction * delta, 0, abs(velocity.x))

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
		character_sprite.modulate = Color(3, 0.5, 0.5)
		block_sprite.modulate = Color(3, 0.5, 0.5)


func respawn():
	velocity = Vector2(0, 0)
	dead = false

	set_health(max_health)
	update_health_bar()
	call_deferred("set_camouflage", false)
	call_deferred("set_frozen", false)

	set_player_collision_layer()


func set_camouflage(is_camouflage: bool):
	camouflaged = is_camouflage

	if is_camouflage:
		current_camouflage = (current_camouflage + 1) % 2
		var random_camouflage = camouflage_list[current_camouflage]

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
	point_light_2d.enabled = !is_frozen

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
func bullet_hit(damage, collision_normal, hitback, source_id, damagecause):
	last_damage_source = source_id
	last_death_cause = damagecause
	change_health(-damage)

	velocity += collision_normal * hitback
	hit_color.start()

func get_last_damage_source() -> int:
	return last_damage_source
	
	
func shoot(projectile: int = Projectile.Bullet):
	var bullet_transform := Transform2D(muzzle.get_global_rotation(), muzzle.get_global_position())
	spawn_projectile.rpc(multiplayer.get_unique_id(), projectile, bullet_transform)


func die():
	if dead:
		return

	var killer_id = get_last_damage_source()
	var killer_name = game.players.get(killer_id, {}).get("name", "unknown")
	var victim_name = name_tag.text

	game.kill_feed.add_kill.rpc(killer_name, victim_name, last_death_cause)
	last_death_cause = DeathCause.DeathCause.UNKNOWN
	dead = true
	clear_player_collision_layer()
	effect_bar.clear_all_effects()
	
	if player_team == Team.HIDER:
		game.remove_player_from_scene.rpc(get_multiplayer_authority())
		game.hider_die(get_multiplayer_authority())
		return
	
	respawn_timer.start()
	var spawn_point: Marker2D = spawn_points.get_children().pick_random()
	global_position = spawn_point.global_position


@rpc("call_local")
func spawn_projectile(pid, _projectile: int, _transform: Transform2D):
	var projectile: Projectile
	#projectile.set_multiplayer_authority(pid)
	
	if _projectile == Projectile.Bullet:
		projectile = BULLET.instantiate()
	elif _projectile == Projectile.Grenade:
		projectile = GRENADE.instantiate()
	elif _projectile == Projectile.Flashbang:
		projectile = FLASHBANG.instantiate()
	else:
		return

	projectile.transform = _transform
	projectile.initial_velocity = velocity * 0.5
	projectile.set_multiplayer_authority(pid)
	projectile.source_id = pid
	
	var bullet_team = Team.HIDER if pid in game.hiders else Team.SEEKER

	if bullet_team == Team.HIDER:
		projectile.set_collision_mask_value(3, true)
		projectile.set_collision_mask_value(5, true)
		projectile.set_collision_mask_value(7, true)
	else:
		projectile.set_collision_mask_value(2, true)
		projectile.set_collision_mask_value(4, true)
		projectile.set_collision_mask_value(6, true)

	get_parent().add_child(projectile)


func update_health_bar():
	if not is_inside_tree():
		return

	var health_ratio = float(health.value) / max_health
	health_fill.scale.x = health_ratio

	health_label.text = str(health.value)

	if health_ratio < 0.3:
		health_fill.color = Color(0.928, 0.329, 0.199, 0.784)
	elif health_ratio < 0.6:
		health_fill.color = Color(0.914, 0.686, 0.165, 0.784)
	else:
		health_fill.color = Color(0.0, 0.745, 0.247, 0.659)


func change_health(amount: int) -> void:
	health.value = clamp(health.value + amount, 0, max_health)
	update_health_bar()
	if health.value <= 0:
		die()


func set_health(value: int) -> void:
	health.value = clamp(value, 0, max_health)
	update_health_bar()


func _on_respawn_timer_timeout() -> void:
	respawn()
