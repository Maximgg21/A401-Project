class_name CombatPathfinder
extends RefCounted

const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]


func _get_cheapest(frontier: Array[Vector2i], costs: Dictionary[Vector2i, int]) -> Vector2i:
	var cheapest := frontier[0]

	for position in frontier:
		if costs[position] < costs[cheapest]:
			cheapest = position

	return cheapest


func _can_traverse(entity: Entity, tile: MapTile) -> bool:
	if (tile.traversability == 0):
		return false
	elif (tile.traversability == 3):
		if entity.movement_type == 3:
			return true
		else:
			return false
	else:
		return true


func find_reachable_tiles(
	# shitty implementation of Dijkstra's algorithm, can certainly be improved
	#main possible improvement is to implement a priority queue for scanning
	map: CombatMap,
	start: Vector2i,
	max_movement: int,
	entity: Entity,
) -> Dictionary:
	var frontier: Array[Vector2i] = [start]

	var costs: Dictionary[Vector2i, int] = { }
	var came_from: Dictionary[Vector2i, Vector2i] = { }

	costs[start] = 0
	came_from[start] = start

	while not frontier.is_empty():
		var current: Vector2i = _get_cheapest(frontier, costs)
		frontier.erase(current)

		for direction in DIRECTIONS:
			var next := current + direction

			if not map.in_bounds(next):
				continue

			var tile := map.get_tile(next)

			if not _can_traverse(entity, tile):
				continue

			var new_cost: int = costs[current] + tile.movement_cost

			if new_cost > max_movement:
				continue

			if not costs.has(next) or new_cost < costs[next]:
				costs[next] = new_cost
				came_from[next] = current

				if not frontier.has(next):
					frontier.append(next)

	return { "costs": costs, "came_from": came_from }


func reconstruct_path(
	#once a point the unit can travel to is chosen, this returns the path it must take to that point
	came_from: Dictionary[Vector2i, Vector2i],
	start: Vector2i,
	target: Vector2i,
) -> Array[Vector2i]:
	var path: Array[Vector2i] = []
	if not came_from.has(target):
		return path
	var current := target

	while current != start:
		path.push_back(current)
		current = came_from[current]

	path.reverse()

	return path # a path is a list of 2d vector ints. DOES NOT RETURN STARTING TILE
