class_name CombatantView
extends CharacterBody2D

signal hovered(combatant: Combatant)
signal unhovered(combatant: Combatant)

var combatant: Combatant

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: HealthBar = %HealthBar


func setup(new_combatant: Combatant) -> void:
	input_pickable = true
	combatant = new_combatant
	combatant.health_changed.connect(_on_health_changed)
	combatant.died.connect(_on_died)
	_on_health_changed()
	sprite.sprite_frames = combatant.data.sprite


func _on_health_changed() -> void:
	health_bar.set_health(combatant.current_health, combatant.max_health)


func _on_died() -> void:
	input_pickable = false
	sprite.modulate = Color.WHITE
	health_bar.hide()
	unhovered.emit(combatant)


func play_death() -> void:
	if sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		await sprite.animation_finished


func play_walk(dir: Vector2) -> void:
	if combatant.current_health == 0:
		return
	sprite.play("idle" if dir == Vector2.ZERO else "run")
	if dir.x != 0:
		sprite.flip_h = dir.x < 0


func _mouse_enter() -> void:
	sprite.modulate = Color(1.4, 1.4, 1.4)
	hovered.emit(combatant)


func _mouse_exit() -> void:
	sprite.modulate = Color.WHITE
	unhovered.emit(combatant)
