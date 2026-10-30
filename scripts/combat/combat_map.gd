class_name CombatMap
extends RefCounted

var width: int
var height: int
var tiles: Array[MapTile]


static func from_template(template: RoomTemplate) -> CombatMap:
	var map := CombatMap.new()
	map.width = template.width
	map.height = template.height
	map.tiles.resize(map.width * map.height)
	for i in map.tiles.size():
		var tile := MapTile.new()
		tile.type = template.tile_palette[template.tile_indices[i]]
		map.tiles[i] = tile
	return map


func initialize(new_width: int, new_height: int, default_type: MapTileType) -> void:
	width = new_width
	height = new_height

	tiles.resize(width * height)

	for i in range(tiles.size()):
		var tile := MapTile.new()
		tile.type = default_type
		tiles[i] = tile


func get_tile(position: Vector2i) -> MapTile:
	if (in_bounds(position)):
		return tiles[position.y * width + position.x]
	return null


func set_tile(position: Vector2i, tile: MapTile) -> void:
	if (in_bounds(position)):
		tiles[position.y * width + position.x] = tile


func get_movement_cost(
	entity: Combatant,
	position: Vector2i,
) -> int: #this calculates movement costs for non-flying units traveling between water and ground
	var tile := get_tile(position)
	var cost := tile.type.movement_cost

	match entity.movement_type:
		Combatant.Movement.GROUND:
			if tile.type.traversability == MapTile.Traversability.WATER:
				cost *= 2

		Combatant.Movement.WATER:
			if tile.type.traversability == MapTile.Traversability.GROUND:
				cost *= 2

		Combatant.Movement.FLYING:
			pass

	return cost


func in_bounds(position: Vector2i) -> bool:
	return (position.x >= 0 and position.x < width and position.y >= 0 and position.y < height)
