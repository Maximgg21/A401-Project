class_name CombatMapNode
extends Node2D

const TEST_ROOM := preload("res://data/rooms/test_room.tres")

var new_map: CombatMap

@onready var map_renderer: MapRenderer = $MapRenderer
@onready var map_entities: MapEntities = $MapEntities


func _ready() -> void:
	var map := load_from_template(TEST_ROOM)
	load_map(map)


func load_from_template(template: RoomTemplate) -> CombatMap:
	var map := CombatMap.from_template(template) as CombatMap
	if map == null:
		push_error("test_room.tres is not a CombatMap")
		return null
	return map


func load_map(map: CombatMap) -> void:
	map_renderer.render_map(map)
