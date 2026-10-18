class_name MapEntity
extends RefCounted
#this represents enemies and allies or really anything with hp such as destructible furniture
var position: Vector2i
var max_health: int
var current_health: int

signal health_changed

func TakeDamage(amount: int):
	current_health = clampi(current_health - amount, 0, max_health)
	
	health_changed.emit()
