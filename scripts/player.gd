class_name Player
extends CharacterBody2D

@onready var player: Player = $"."
@onready var name_tag: Label = $Name

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite
@onready var block_sprite: AnimatedSprite2D = $BlockSprite
@onready var item_sprite: AnimatedSprite2D = $ItemSprite


@onready var character_collision: CollisionShape2D = $CharacterCollision
@onready var block_collision: CollisionShape2D = $BlockCollision

@onready var gun_container: Node2D = $GunContainer
@onready var gun_sprite: Sprite2D = $GunContainer/GunSprite
@onready var muzzle: Marker2D = $GunContainer/GunSprite/Muzzle

@onready var cool_down: Timer = $CoolDown
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var hit_color: Timer = $HitColor

@onready var terrain: TileMapLayer = $"../LevelMap/Midground"
@onready var spawn_point: Marker2D = $"../LevelMap/SpawnPoint"

const CAMERA = preload("res://scenes/camera.tscn")
const BULLET = preload("res://scenes/bullet.tscn")

@export var MAX_SPEED = 175
@export var JUMP_VELOCITY = -300

@export var ACCELERATION = 800
@export var GROUND_FRICTION = 800
@export var AIR_FRICTION = 400

@export var MAX_HEALTH = 100



@onready var healthbar_background: ColorRect = $HealthbarBackground
@onready var health_fill: ColorRect = $HealthFill
@onready var health_label: Label = $HealthLabel




var _camouflaged = false
var _frozen = false

var health = MAX_HEALTH


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()


func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

	if is_multiplayer_authority():
		var camera = CAMERA.instantiate(PackedScene.GEN_EDIT_STATE_DISABLED)
		add_child(camera)


func _ready() -> void:
	#if is_multiplayer_authority():
	#print(1)
	#name_tag.label_settings.font_color = Color(0.456, 0.777, 0.153)
	health_label.text = "%d/%d" % [health, MAX_HEALTH]
	pass


func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("test"):
		health -= 10
		on_health_changed()
	
	
	if !is_multiplayer_authority():
		return

	if Input.is_action_just_pressed("switch"):
		if is_frozen():
			return

		set_camouflage(not is_camouflaged())

	if Input.is_action_just_pressed("lock"):
		if not is_camouflaged():
			return

		set_frozen(not is_frozen())
		
	show_hit_color()


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return

	if is_frozen():
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


func handle_shoot():
	gun_container.look_at(get_global_mouse_position())
	gun_sprite.flip_v = get_global_mouse_position().x < global_position.x

	if Input.is_action_just_pressed("shoot") and not is_camouflaged():
		if !cool_down.is_stopped():
			return
		shoot.rpc(multiplayer.get_unique_id())
		cool_down.start()


func handle_jump(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

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

	if direction:
		velocity.x = clampf(velocity.x + direction * ACCELERATION * delta, -MAX_SPEED, MAX_SPEED)

	elif is_on_floor():
		velocity.x = velocity.x - speed_direction * clampf(GROUND_FRICTION * delta, 0, abs(velocity.x))

	else:
		velocity.x = velocity.x - speed_direction * clampf(AIR_FRICTION * delta, 0, abs(velocity.x))

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
		item_sprite.modulate = Color(1, 1, 1)
	
	else:	
		character_sprite.modulate = Color(0.906, 0.306, 0.357)
		block_sprite.modulate = Color(0.906, 0.306, 0.357)
		item_sprite.modulate = Color(0.906, 0.306, 0.357)
	
func respawn():
	global_position = spawn_point.global_position
	velocity = Vector2(0, 0)
	health = MAX_HEALTH
	call_deferred("set_camouflage", false)
	call_deferred("set_frozen", false)


func set_camouflage(is_camouflage: bool):
	_camouflaged = is_camouflage
	
	if is_camouflage:
		block_sprite.frame = randi() % 25 # total 25 blocks
	
	character_sprite.visible = !is_camouflage
	block_sprite.visible = is_camouflage

	character_collision.disabled = is_camouflage
	block_collision.disabled = !is_camouflage

	gun_container.visible = !is_camouflage

	player.set_collision_layer_value(1, is_camouflage)


func set_frozen(is_frozen: bool):
	_frozen = is_frozen
	name_tag.visible = !is_frozen
	health_fill.visible = !is_frozen
	health_label.visible = !is_frozen
	healthbar_background.visible = !is_frozen
	
func is_camouflaged():
	return _camouflaged
	
func is_frozen():
	return _frozen


@rpc("any_peer")
func bullet_hit(damage, collision_normal, hitback):
	health -= damage
	hit_color.start()
	on_health_changed()
	if health <= 0:
		respawn()
	
	velocity -= collision_normal * hitback
	

@rpc("call_local", "any_peer")
func shoot(pid):
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	bullet.transform = muzzle.global_transform
	bullet.global_scale = Vector2(1, 1)
	bullet.set_multiplayer_authority(pid)
	
	
	
	
	#


func on_health_changed():
	if not is_inside_tree():
		return
		
	var health_ratio = float(health) / MAX_HEALTH
	health_fill.scale.x = health_ratio
	
	health_label.text = "%d/%d" % [health, MAX_HEALTH]
	
	if health_ratio < 0.3:
		health_fill.color = Color.RED
	elif health_ratio < 0.6:
		health_fill.color = Color.YELLOW
	else:
		health_fill.color = Color.GREEN
