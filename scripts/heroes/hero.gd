class_name Hero
extends RefCounted

signal energy_changed
signal health_changed
signal movement_changed

var data: HeroData
var max_health: int
var current_health: int
var max_energy: int
var current_energy: int
var speed: int # How many movement do I gain every turn
var movement: int # How many tiles can I move


func _init(hero_data: HeroData) -> void:
	data = hero_data
	max_health = data.base_health
	current_health = max_health
	max_energy = data.base_energy
	current_energy = max_energy
	speed = data.base_speed
	movement = speed


func start_turn() -> void:
	current_energy = max_energy
	movement = speed

	energy_changed.emit()
	movement_changed.emit()


func spend_energy(amount: int) -> bool:
	if current_energy < amount:
		print("Not enough energy")
		return false
		# TODO: add animation to show it in game

	current_energy -= amount
	energy_changed.emit()
	return true
