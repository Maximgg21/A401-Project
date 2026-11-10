class_name MapRenderer
extends Node2D

enum Shape {
	FILL,
	EDGE_V,
	EDGE_H,
	OUTER,
	INNER,
}

const RENDER_SCALE := 2
const SOURCE_ID := 0

const SOUTH := Vector2i(0, 1) # S

const QUADRANTS := [
	{ "offset": Vector2i(0, 0), "v": Vector2i(0, -1), "h": Vector2i(-1, 0), "c": Vector2i(-1, -1) }, # NW
	{ "offset": Vector2i(1, 0), "v": Vector2i(0, -1), "h": Vector2i(1, 0), "c": Vector2i(1, -1) }, # NE
	{ "offset": Vector2i(0, 1), "v": Vector2i(0, 1), "h": Vector2i(-1, 0), "c": Vector2i(-1, 1) }, # SW
	{ "offset": Vector2i(1, 1), "v": Vector2i(0, 1), "h": Vector2i(1, 0), "c": Vector2i(1, 1) }, # SE
]

const WALL_ATLAS := [
	[Vector2i(8, 1), Vector2i(1, 3), Vector2i(4, 5), Vector2i(0, 3), Vector2i(4, 6)], # NW
	[Vector2i(8, 1), Vector2i(1, 3), Vector2i(3, 5), Vector2i(2, 3), Vector2i(3, 6)], # NE
	[Vector2i(8, 1), Vector2i(1, 4), Vector2i(4, 5), Vector2i(0, 4), Vector2i(4, 4)], # SW
	[Vector2i(8, 1), Vector2i(1, 4), Vector2i(3, 5), Vector2i(2, 4), Vector2i(3, 4)], # SE
]

const CAP_OFFSET := Vector2i(0, -2)
const WATER_ALT_ID := 1 #since it uses the alternative tile

#atlas coord for tiles will be hardcoded for now,
#but custom data would be better for a large project
const STONE_FLOOR_ATLAS := Vector2i(5, 1)
const WOOD_FLOOR_ATLAS := Vector2i(15, 1)
const STONE_WALL_FACE_BASE := Vector2i(1, 2)
const STONE_WALL_FACE := Vector2i(1, 1)
const CHASM_ATLAS := Vector2i(8, 1)
const IRON_BARS_ATLAS := Vector2i(9, 9)
const WATER_ATLAS := Vector2i(11, 1)

var map_tiles: Array[MapTile]
var map_width: int
var map_height: int

@onready var floor_layer: TileMapLayer = $Floor
@onready var close_wall_layer: TileMapLayer = $CloseWall
@onready var far_wall_layer: TileMapLayer = $FarWall


func render_map(new_map: CombatMap) -> void:
	floor_layer.clear()
	close_wall_layer.clear()
	far_wall_layer.clear()

	map_tiles = new_map.tiles
	map_width = new_map.width
	map_height = new_map.height

	for y in range(new_map.height):
		for x in range(new_map.width):
			render_tile(Vector2i(x, y))


func render_tile(pos: Vector2i) -> void:
	var tile := get_tile(pos)
	if tile == null or tile.type == null:
		return
	match tile.type.render_type:
		tile.RenderType.FLOOR:
			render_floor(pos, tile)
		tile.RenderType.WALL:
			render_wall(pos)
		tile.RenderType.SINGLETON:
			render_singleton(pos, tile)


func render_floor(pos: Vector2i, tile: MapTile):
	var base := pos * RENDER_SCALE
	for oy in RENDER_SCALE:
		for ox in RENDER_SCALE:
			if tile.type.terrain == MapTile.Terrain.STONE:
				floor_layer.set_cell(base + Vector2i(ox, oy), SOURCE_ID, STONE_FLOOR_ATLAS)
			elif tile.type.terrain == MapTile.Terrain.WOOD:
				floor_layer.set_cell(base + Vector2i(ox, oy), SOURCE_ID, WOOD_FLOOR_ATLAS)


func render_wall(pos: Vector2i) -> void:
	var base := pos * RENDER_SCALE
	var south_open := is_open(pos + SOUTH)
	var layer := far_wall_layer if is_floor(pos + SOUTH) else close_wall_layer

	# Cap: all four quadrants, raised above the footprint.
	for q in 4:
		var def: Dictionary = QUADRANTS[q]
		var shape := get_shape(is_open(pos + def.v), is_open(pos + def.h), is_open(pos + def.c))
		layer.set_cell(base + def.offset + CAP_OFFSET, SOURCE_ID, WALL_ATLAS[q][shape])

	# Face: fills the footprint, only where the south side is exposed.
	if south_open:
		for ox in RENDER_SCALE:
			layer.set_cell(base + Vector2i(ox, 0), SOURCE_ID, STONE_WALL_FACE)
			layer.set_cell(base + Vector2i(ox, 1), SOURCE_ID, STONE_WALL_FACE_BASE)


func render_singleton(pos: Vector2i, tile: MapTile) -> void:
	var base := pos * RENDER_SCALE
	var atlas := Vector2i.ZERO
	var alt := 0

	match tile.type.singleton:
		MapTile.Singleton.WATER:
			atlas = WATER_ATLAS
			alt = WATER_ALT_ID
		MapTile.Singleton.CHASM:
			atlas = CHASM_ATLAS
		MapTile.Singleton.BARS:
			atlas = IRON_BARS_ATLAS
			#bars have transparent gaps, so put floor underneath
			render_floor(pos, tile)

	for oy in RENDER_SCALE:
		for ox in RENDER_SCALE:
			floor_layer.set_cell(base + Vector2i(ox, oy), SOURCE_ID, atlas, alt)
			#floor layer for now, maybe use a seperate layer later?


func get_tile(pos: Vector2i) -> MapTile:
	if not in_bounds(pos):
		return null
	return map_tiles[pos.y * map_width + pos.x]


func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < map_width and pos.y >= 0 and pos.y < map_height


func is_floor(pos: Vector2i) -> bool:
	var t := get_tile(pos)
	return t != null and t.type != null and t.type.render_type == t.RenderType.FLOOR


func is_open(pos: Vector2i) -> bool:
	if pos.y >= map_height:
		return true
	var t := get_tile(pos)
	return t != null and t.type != null and t.type.render_type != MapTile.RenderType.WALL


func get_shape(v_open: bool, h_open: bool, c_open: bool) -> int:
	if v_open and h_open:
		return Shape.OUTER # exposed on both sides: convex corner
	if v_open:
		return Shape.EDGE_V # exposed to the north/south only
	if h_open:
		return Shape.EDGE_H # exposed to the east/west only
	if c_open:
		return Shape.INNER # only the diagonal is open: concave notch
	return Shape.FILL
