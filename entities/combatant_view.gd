class_name CombatantView
extends CharacterBody2D

var combatant: Combatant

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: HealthBar = %HealthBar


func setup(new_combatant: Combatant) -> void:
	combatant = new_combatant
	combatant.health_changed.connect(_on_health_changed)
	_on_health_changed()
	sprite.sprite_frames = combatant.data.sprite


func _on_health_changed() -> void:
	health_bar.set_health(combatant.current_health, combatant.max_health)
