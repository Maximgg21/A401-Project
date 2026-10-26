class_name RoomTemplate
extends Resource

@export var width: int
@export var height: int
@export var tile_palette: Array[MapTileType] # types used by this room
@export var tile_indices: PackedInt32Array # width * height indices into the palette
@export var player_spawns: Array[Vector2i]
@export var enemy_spawns: Array[Vector2i]
