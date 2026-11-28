class_name Combat
extends Node2D

@export var test_room: RoomTemplate
@export var manager: CombatManager
@export var renderer: CombatMapNode
@export var enemy_view: EnemyView
@export var hero_view: HeroView
@export var overlay: MovementOverlay
@export var hud: CombatHud
@export var camera: CombatCamera


func _ready() -> void:
	# TODO: have this choose a spawn point in the template with rng
	var hero_start = test_room.player_spawns[0]
	var enemy_start = test_room.enemy_spawns[0]

	var map := CombatMap.from_template(test_room)
	manager.setup(map)
	renderer.load_map(map)

	manager.place_entity(manager.hero, hero_start)
	manager.place_entity(manager.enemy, enemy_start)

	var entities := renderer.map_entities
	entities.setup(manager, renderer.map_renderer)
	entities.bind_view(manager.hero, hero_view)
	entities.bind_view(manager.enemy, enemy_view)
	overlay.setup(manager, renderer.map_renderer)

	enemy_view.hovered.connect(hud._on_target_hovered)
	enemy_view.unhovered.connect(hud._on_target_unhovered)
	hero_view.hovered.connect(hud._on_target_hovered)
	hero_view.unhovered.connect(hud._on_target_unhovered)

	camera.setup(renderer.map_renderer)

	manager.start_combat()


func _unhandled_input(event: InputEvent) -> void: #
	if event is InputEventMouseButton and event.pressed \
			and event.button_index == MOUSE_BUTTON_LEFT:
		var cell := renderer.map_renderer.global_to_logical(get_global_mouse_position())
		manager.move_hero(cell)
