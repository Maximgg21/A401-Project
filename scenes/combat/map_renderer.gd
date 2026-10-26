class_name MapRenderer
extends TileMapLayer

const RENDER_SCALE := 2

const NEIGHBORS := [
	Vector2i(0, -1), # N
	Vector2i(1, -1), # NE
	Vector2i(1, 0), # E
	Vector2i(1, 1), # SE
	Vector2i(0, 1), # S
	Vector2i(-1, 1), # SW
	Vector2i(-1, 0), # W
	Vector2i(-1, -1), # NW
]

enum TILE_TYPE {
	NONE,
	FLOOR,
	WALL,
}

var map_tiles: Array[MapTile]
var map_width: int
var map_height: int


func render_map(tiles: Array[MapTile], width: int, height: int) -> void:
	clear()

	map_tiles = tiles
	map_width = width
	map_height = height

	for y in range(height):
		for x in range(width):
			render_tile(Vector2i(x, y))


func render_tile(position: Vector2i) -> void:
	var tile := get_tile(position)

	if tile == null or tile.type == null:
		return

	# Step 1: determine which surrounding tiles connect to this one.

	# Step 2: use tile type + neighbors to determine what art to use.
	# TODO: var visual := get_visual(tile.type, neighbors)

	# Step 3: render the logical tile as a 2x2 group.

	# TODO:
	# set_cell(render_position, ...)
	# set_cell(render_position + Vector2i.RIGHT, ...)
	# set_cell(render_position + Vector2i.DOWN, ...)
	# set_cell(render_position + Vector2i(1, 1), ...)


func get_tile(position: Vector2i) -> MapTile:
	if not in_bounds(position):
		return null

	return map_tiles[position.y * map_width + position.x]


func in_bounds(position: Vector2i) -> bool:
	return (
		position.x >= 0 and position.x < map_width and position.y >= 0 and position.y < map_height
	)
