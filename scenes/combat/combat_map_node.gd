class_name CombatMapNode
extends Node2D

@onready var map_renderer: TileMapLayer = $MapRenderer

var map_tiles: Array[MapTile]
var width: int
var height: int

func load_map(
	tiles: Array[MapTile],
	map_width: int,
	map_height: int
) -> void:
	map_tiles = tiles
	width = map_width
	height = map_height

	map_renderer.render_map(map_tiles, width, height)
