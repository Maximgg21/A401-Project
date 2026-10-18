class_name Hero
extends Combatant

signal energy_changed

var data: HeroData
var max_energy: int
var current_energy: int

func _init(hero_data: HeroData) -> void:
	data = hero_data
	max_health = data.base_health
	current_health = max_health
	max_energy = data.base_energy
	current_energy = max_energy
	speed = data.base_speed
	movement = speed
	movement_type = Combatant.Movement.GROUND #if you want the hero to be able to fly/be a fish, set this using data instead
	team = Combatant.Team.ALLY


func start_turn() -> void:
	super()
	current_energy = max_energy
	energy_changed.emit()

func spend_energy(amount: int) -> bool:
	if current_energy < amount:
		print("Not enough energy")
		return false
		# TODO: add animation to show it in game

	current_energy -= amount
	energy_changed.emit()
	return true
