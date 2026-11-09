class_name Combat
extends Node2D

@export var manager: CombatManager


func _ready() -> void:
	manager.start_combat()
