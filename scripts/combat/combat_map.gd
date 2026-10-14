class_name CombatMap
extends Resource
#this will define maps for combat
var width: int
var height: int
var tiles: Array[MapTile]
var entities: Array[Entity] #a lookup table may be needed for their positions

func get_tile(position: Vector2i) -> MapTile:
	return tiles[position.y * width + position.x]

func set_tile(position: Vector2i, tile: MapTile) -> void:
	tiles[position.y * width + position.x] = tile

func in_bounds(position: Vector2i) -> bool:
	return (
		position.x >= 0
		and position.x < width
		and position.y >= 0
		and position.y < height
	)
