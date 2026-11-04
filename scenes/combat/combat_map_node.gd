class_name CombatMapNode
extends Node2D

@onready var map_renderer: TileMapLayer = $MapRenderer

var new_map: CombatMap

func load_map(
	map: CombatMap
) -> void:
	new_map = map

	map_renderer.render_map(new_map)
