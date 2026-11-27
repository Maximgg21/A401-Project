class_name MapEntity
extends RefCounted

signal health_changed
signal died

enum Team {
	NONE,
	ALLY,
	ENEMY,
	NEUTRAL,
}

#this represents enemies and allies or really anything with hp such as destructible furniture
var position: Vector2i
var max_health: int
var current_health: int
var team: Team = Team.NONE


func _init() -> void:
	max_health = 1
	current_health = max_health


func take_damage(amount: int) -> void:
	if amount == 0:
		return

	var was_alive := current_health > 0
	current_health = clampi(current_health - amount, 0, max_health)
	health_changed.emit()
	if was_alive and current_health == 0:
		died.emit()
