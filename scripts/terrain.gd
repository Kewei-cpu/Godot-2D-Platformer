class_name Terrain
extends TileMapLayer

const BLOCKS: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(0, 1),
	Vector2i(0, 2),
	Vector2i(1, 0),
	Vector2i(1, 1),
	Vector2i(1, 2),
	Vector2i(2, 0),
	Vector2i(2, 1),
	Vector2i(2, 2),
	Vector2i(2, 3),
	Vector2i(3, 0),
	Vector2i(3, 1),
	Vector2i(3, 2),
	Vector2i(4, 0),
	Vector2i(4, 1),
	Vector2i(4, 2),
	Vector2i(5, 0),
	Vector2i(5, 1),
	Vector2i(5, 2),
	Vector2i(6, 0),
	Vector2i(6, 1),
	Vector2i(6, 2),
	Vector2i(7, 0),
	Vector2i(7, 1),
	Vector2i(7, 2),
	Vector2i(8, 0),
	Vector2i(8, 1),
	Vector2i(8, 2)
]

const BLOCK_DIRT: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(0, 1),
	Vector2i(0, 2),
	Vector2i(1, 0),
	Vector2i(1, 1),
	Vector2i(1, 2),
]

const BLOCK_SAND: Array[Vector2i] = [
	Vector2i(2, 0),
	Vector2i(2, 1),
	Vector2i(2, 2),
	Vector2i(2, 3),
	Vector2i(3, 0),
	Vector2i(3, 1),
	Vector2i(3, 2),
]

const BLOCK_GRANITE: Array[Vector2i] = [
	Vector2i(4, 0),
	Vector2i(4, 1),
	Vector2i(4, 2),
	Vector2i(5, 0),
	Vector2i(5, 1),
	Vector2i(5, 2),
]

const BLOCK_COBBLESTONE: Array[Vector2i] = [
	Vector2i(6, 0),
	Vector2i(6, 1),
	Vector2i(6, 2),
	Vector2i(7, 0),
	Vector2i(7, 1),
	Vector2i(7, 2),
	Vector2i(8, 0),
	Vector2i(8, 1),
	Vector2i(8, 2)
]

const BRIDGES: Array[Vector2i] = [
	Vector2i(9, 0),
	Vector2i(9, 1),
	Vector2i(9, 2),
	Vector2i(10, 0),
	Vector2i(10, 1),
	Vector2i(10, 2),
	Vector2i(11, 0),
	Vector2i(11, 1),
	Vector2i(11, 2),
]

const DAMAGED_DIRT: Vector2i = Vector2i(1, 0)
const BROKEN_DIRT: Vector2i = Vector2i(1, 1)

const DAMAGED_SAND: Vector2i = Vector2i(3, 0)
const BROKEN_SAND: Vector2i = Vector2i(3, 1)

const DAMAGED_GRANITE: Vector2i = Vector2i(5, 0)
const BROKEN_GRANITE: Vector2i = Vector2i(5, 1)

const DAMAGED_COBBLESTONE: Vector2i = Vector2i(8, 0)
const BROKEN_COBBLESTONE: Vector2i = Vector2i(8, 1)



@rpc("call_local", "any_peer")
func change_tile(coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0) -> void:
	set_cell(coords, source_id, atlas_coords, alternative_tile)
	if source_id == -1:
		if get_cell_source_id(coords + Vector2i(0, -1)) == 0 and get_cell_atlas_coords(coords + Vector2i(0, -1)) not in BLOCKS:
			change_tile.rpc(coords + Vector2i(0, -1), -1)
