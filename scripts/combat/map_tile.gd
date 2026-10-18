class_name MapTile
extends Resource 
@export var type: MapTileType

enum Terrain { 
	STONE,
	WOOD,
	WATER, #will need to add stuff for this to the tileset (or render it with math (resource intensive))
}

enum Feature {
	NONE,
	WALL,
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
