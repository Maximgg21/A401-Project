class_name CombatantView
extends CharacterBody2D

signal hovered(combatant: Combatant)
signal unhovered()

var combatant: Combatant

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: HealthBar = %HealthBar


func setup(new_combatant: Combatant) -> void:
	input_pickable = true
	combatant = new_combatant
	combatant.health_changed.connect(_on_health_changed)
	_on_health_changed()
	sprite.sprite_frames = combatant.data.sprite


func _on_health_changed() -> void:
	health_bar.set_health(combatant.current_health, combatant.max_health)


func _mouse_enter() -> void:
	sprite.modulate = Color(1.4, 1.4, 1.4)
	hovered.emit(combatant)


func _mouse_exit() -> void:
	sprite.modulate = Color.WHITE
	unhovered.emit()
