class_name CombatMap
extends Resource
#this will define maps for combat
var width: int
var height: int
var tiles: Array[MapTile]
var entities: Array[Combatant] #a lookup table may be needed for their positions


func get_tile(position: Vector2i) -> MapTile:
	if(in_bounds(position)):
		return tiles[position.y * width + position.x]
	return


func set_tile(position: Vector2i, tile: MapTile) -> void:
	if (in_bounds(position)):
		tiles[position.y * width + position.x] = tile


func get_movement_cost(entity: Combatant, position: Vector2i) -> int: #this calculates movement costs for non-flying units traveling between water and ground
	var tile := get_tile(position)
	var cost := tile.movement_cost

	match entity.movement_type:
		Combatant.Movement.GROUND:
			if tile.terrain == MapTile.Traversability.WATER:
				cost *= 2

		Combatant.Movement.WATER:
			if tile.terrain == MapTile.Traversability.GROUND:
				cost *= 2

		Combatant.Movement.FLYING:
			pass
			
	return cost



func in_bounds(position: Vector2i) -> bool:
	return (position.x >= 0 and position.x < width and position.y >= 0 and position.y < height)
