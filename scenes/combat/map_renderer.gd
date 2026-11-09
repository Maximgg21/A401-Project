class_name MapRenderer
extends Node2D

@onready var floor_layer: TileMapLayer = $Floor
@onready var close_wall_layer: TileMapLayer = $CloseWall
@onready var far_wall_layer: TileMapLayer = $FarWall

var map_tiles: Array[MapTile]
var map_width: int
var map_height: int

const RENDER_SCALE := 2
const SOURCE_ID := 0

#atlas coord for tiles will be hardcoded for now, but custom data would be better for a large project
const STONE_FLOOR_ATLAS := Vector2i(5, 1)
const WOOD_FLOOR_ATLAS := Vector2i(15, 1)


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

func render_floor(pos: Vector2i, tile: MapTile):
	var base := pos * RENDER_SCALE
	for oy in RENDER_SCALE:
		for ox in RENDER_SCALE:
			if tile.type.terrain == tile.Terrain.STONE:
				floor_layer.set_cell(base + Vector2i(ox, oy), SOURCE_ID, STONE_FLOOR_ATLAS)
			elif tile.type.terrain == tile.Terrain.WOOD:
				floor_layer.set_cell(base + Vector2i(ox, oy), SOURCE_ID, WOOD_FLOOR_ATLAS)	

func render_wall(pos):
	#check south
	#if a floor is south, render face
	#else, render directionally
	return

func get_tile(pos: Vector2i) -> MapTile:
	if not in_bounds(pos):
		return null
	return map_tiles[pos.y * map_width + pos.x]


func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < map_width and pos.y >= 0 and pos.y < map_height
	

func is_wall(pos: Vector2i) -> bool:
	var t := get_tile(pos)
	return t != null and t.type != null and t.type.render_type == t.RenderType.WALL

func is_floor(pos: Vector2i) -> bool:
	var t := get_tile(pos)
	return t != null and t.type != null and t.type.render_type == t.RenderType.FLOOR
