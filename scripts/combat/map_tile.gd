class_name MapTile
extends Resource
enum Traversability {
	NONE,
	GROUND,
	WATER,
	FLYING,
}
var terrain: int #this can be turned into an enum
var movement_cost: int
var traversability: Traversability #0 = unwalkable, 1 = double water unit cost, 2 = double ground unit cost, 3 = only flying units
var blocks_los: bool
