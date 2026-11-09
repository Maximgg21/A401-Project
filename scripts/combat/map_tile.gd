class_name MapTile
extends RefCounted

enum Terrain {
	STONE,
	WOOD,
	WATER,
}

enum RenderType {
	FLOOR,
	WALL,
	SINGLETON # a tile that will always be rendered the same, regardless of any nearby tiles
}

enum Traversability {
	NONE,
	GROUND,
	WATER,
	FLYING,
}

@export var type: MapTileType
