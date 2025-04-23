class_name Player
extends CharacterBody2D

@onready var player: Player = $"."
@onready var name_tag: Label = $Name

@onready var character_sprite: AnimatedSprite2D = $CharacterSprite
@onready var character_collision: CollisionShape2D = $CharacterCollision

@onready var block_sprite: Sprite2D = $BlockSprite
@onready var block_collision: CollisionShape2D = $BlockCollision

@onready var gun_container: Node2D = $GunContainer
@onready var gun_sprite: Sprite2D = $GunContainer/GunSprite
@onready var muzzle: Marker2D = $GunContainer/GunSprite/Muzzle

@onready var cool_down: Timer = $CoolDown
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer

@onready var terrain = get_parent().get_node("Terrain")
const CAMERA = preload("res://scenes/camera.tscn")
const BULLET = preload("res://scenes/bullet.tscn")

const MAX_SPEED = 900.0
const JUMP_VELOCITY = -1100.0

const ACCELERATION = MAX_SPEED / 0.2
const GROUND_FRICTION = 6000.0
const AIR_FRICTION = 2000.0

const MAX_HEALTH = 100

const BLOCK_LIST = [0, 1, 2, 3, 4, 5, 6, 7, 8, 16, 17, 18, 19, 20, 21, 22, 23, 24, 32, 33, 34, 35, 36, 37, 38, 39, 40]

@export var is_block = false
@export var frozen = false

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
	pass


func _process(_delta: float) -> void:
	if !is_multiplayer_authority():
		return

	if Input.is_action_just_pressed("switch"):
		if frozen:
			return

		is_block = !is_block
		update_block()

	if Input.is_action_just_pressed("lock"):
		if character_sprite.visible:
			return

		frozen = !frozen
		update_frozen()


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return

	if frozen:
		velocity = Vector2(0, 0)
		global_position = global_position.snapped(Vector2(64, 64))
		return

	gun_container.look_at(get_global_mouse_position())
	gun_sprite.flip_v = get_global_mouse_position().x < global_position.x

	if Input.is_action_just_pressed("shoot") and !is_block:
		if !cool_down.is_stopped():
			return
		shoot.rpc(multiplayer.get_unique_id())
		cool_down.start()

	var speed_direction = 1 if velocity.x > 0 else -1 if velocity.x < 0 else 0

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
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
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
	 
	var was_on_floor := is_on_floor()
	move_and_slide()
	
	if is_on_floor() != was_on_floor:
		if was_on_floor and not should_jump:
			coyote_timer.start()
		else:
			coyote_timer.stop()


func respawn():
	global_position = Vector2(64, -384)
	velocity = Vector2(0, 0)
	health = MAX_HEALTH
	is_block = false
	frozen = false
	call_deferred("update_block")
	call_deferred("update_frozen")
	

func update_block():
	character_sprite.visible = !is_block
	block_sprite.visible = is_block

	character_collision.disabled = is_block
	block_collision.disabled = !is_block

	gun_container.visible = !is_block

	player.set_collision_layer_value(1, is_block)


	if is_block:
		var mouse_pos = get_global_mouse_position()
		var local_pos = terrain.to_local(mouse_pos)
		var tile_pos = terrain.local_to_map(local_pos)
		
		var source_id = terrain.get_cell_source_id(tile_pos)
		var atlas_coords = terrain.get_cell_atlas_coords(tile_pos)
		
		if source_id != -1:
			block_sprite.frame_coords = atlas_coords
			block_sprite.show()
		
		if 	!atlas_coords in Terrain.BLOCKS:
			player.set_collision_layer_value(1, false)
		
func update_frozen():
	name_tag.visible = !frozen


@rpc("any_peer")
func take_damage(damage):
	health -= damage

	if health <= 0:
		respawn()


@rpc("call_local")
func shoot(pid):
	var bullet = BULLET.instantiate()
	get_parent().add_child(bullet)
	bullet.transform = muzzle.global_transform
	bullet.global_scale = Vector2(1, 1)
	bullet.set_multiplayer_authority(pid)
