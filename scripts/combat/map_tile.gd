class_name MapTile
extends Resource #TODO: seperate this into tile types and instances
enum Terrain { 
	STONE,
	WOOD,
	WATER, #will need to add stuff for this to the tileset (or render it with math (resource intensive))
}

enum Feature {
	NONE,
	WALL, #wall that does not block los = bars
	DOOR,
	PIT,
}

enum Traversability {
	NONE,
	GROUND,
	WATER,
	FLYING,
}
var terrain: Terrain 
var feature: Feature

var movement_cost: int
var traversability: Traversability #0 = unwalkable, 1 = double water unit cost, 2 = double ground unit cost, 3 = only flying units
var blocks_los: bool
