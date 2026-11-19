class_name Combat
extends Node2D

@export var manager: CombatManager
@export var enemy_view: EnemyView
@export var hero_view: HeroView


func _ready() -> void:
	enemy_view.setup(manager.enemy)
	hero_view.setup(manager.hero)
	manager.start_combat()
