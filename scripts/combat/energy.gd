class_name Energy
extends RefCounted

signal changed

var maximum: int = 3
var current: int


func turn_start() -> void:
	current = maximum
	changed.emit()


func spend(amount: int) -> bool:
	if amount > current:
		return false
	current -= amount
	changed.emit()
	return true


func increase_maximum(amount: int) -> void:
	max += amount
	changed.emit()


func gain(amount: int) -> void:
	current += amount
	changed.emit()
