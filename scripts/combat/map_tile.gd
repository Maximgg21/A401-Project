class_name MapTile
extends RefCounted

enum Terrain {
	STONE,
	WOOD,
	WATER,
}

enum Traversability {
	NONE,
	GROUND,
	WATER,
	FLYING,
}

@export var type: MapTileType
