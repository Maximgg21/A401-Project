class_name Combat
extends Node2D

@export var manager: CombatManager
@export var enemy_view: EnemyView
@export var hero_view: HeroView
@export var hud: CombatHud


func _ready() -> void:
	enemy_view.setup(manager.enemy)
	enemy_view.hovered.connect(hud._on_target_hovered)
	enemy_view.unhovered.connect(hud._on_target_unhovered)
	hero_view.setup(manager.hero)
	hero_view.hovered.connect(hud._on_target_hovered)
	hero_view.unhovered.connect(hud._on_target_unhovered)

	manager.start_combat()
