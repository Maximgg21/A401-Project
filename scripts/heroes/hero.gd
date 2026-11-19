class_name Hero
extends Combatant

signal energy_changed

var max_energy: int
var current_energy: int
var hero_data: HeroData:
	# Convert parent's data: CombatantData into HeroData
	get:
		return data as HeroData


func _init(new_data: HeroData) -> void:
	super(new_data)
	max_energy = new_data.base_energy
	current_energy = max_energy
	team = Combatant.Team.ALLY


func start_turn() -> void:
	super()
	current_energy = max_energy
	energy_changed.emit()


func spend_energy(amount: int) -> bool:
	if current_energy < amount:
		ScreenShake.shake() # Animation (change to a better one later)
		return false

	current_energy -= amount
	energy_changed.emit()
	return true
