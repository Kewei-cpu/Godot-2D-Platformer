extends RigidBody2D

@export var speed = 100
@export var damage = 25


func _physics_process(delta: float) -> void:
	var velocity = transform.x.normalized() * speed * delta
	var collision = move_and_collide(velocity)
	
	if !is_multiplayer_authority():
		return
	if !collision:
		return

	var body = collision.get_collider()
	if body is Player:
		if body.get_multiplayer_authority() == multiplayer.get_unique_id():
			return
		body.take_damage.rpc_id(body.get_multiplayer_authority(), damage)
	
	if body is TileMapLayer:
		var coord: Vector2i = body.local_to_map(body.to_local(collision.get_position() - collision.get_normal()))
		var current_tile: Vector2i = body.get_cell_atlas_coords(coord)
		
		if !current_tile in Terrain.BLOCKS: print(1)
		
		if current_tile in [Terrain.DAMAGED_DIRT, Terrain.BROKEN_SAND, Terrain.BROKEN_GRANITE, Terrain.BROKEN_COBBLESTONE] + Terrain.BRIDGES:
			body.change_tile.rpc(coord, -1)
		
		elif current_tile in [Terrain.DAMAGED_DIRT, Terrain.DAMAGED_SAND, Terrain.DAMAGED_GRANITE, Terrain.DAMAGED_COBBLESTONE]:
			var new_tile = current_tile + Vector2i(0, 1)
			body.change_tile.rpc(coord, 0, new_tile)
		
		else:
			if current_tile in Terrain.BLOCK_DIRT:
				body.change_tile.rpc(coord, 0, Terrain.DAMAGED_DIRT)
			elif current_tile in Terrain.BLOCK_SAND:
				body.change_tile.rpc(coord, 0, Terrain.DAMAGED_SAND)
			elif current_tile in Terrain.BLOCK_GRANITE:
				body.change_tile.rpc(coord, 0, Terrain.DAMAGED_GRANITE)
			elif current_tile in Terrain.BLOCK_COBBLESTONE:
				body.change_tile.rpc(coord, 0, Terrain.DAMAGED_COBBLESTONE)
	
	remove_bullet.rpc()




@rpc("call_local", "any_peer")
func remove_bullet():
	queue_free()


func _on_life_timer_timeout() -> void:
	queue_free()
