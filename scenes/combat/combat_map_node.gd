class_name CombatMapNode
extends Node2D

@onready var map_renderer: MapRenderer = $MapRenderer
@onready var map_entities: MapEntities = $MapEntities

var new_map: CombatMap

func load_map(
	map: CombatMap
) -> void:
	new_map = map
	map_renderer.render_map(new_map)

const TEST_ROOM := preload("res://data/rooms/test_room.tres")

func _ready() -> void:
	var map := CombatMap.from_template(TEST_ROOM) as CombatMap
	if map == null:
		push_error("test_room.tres is not a CombatMap")
		return
	load_map(map)
