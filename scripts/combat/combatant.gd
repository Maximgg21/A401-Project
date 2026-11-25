class_name Combatant
extends MapEntity

signal movement_changed

#this represents enemies and allies
enum Movement {
	NONE,
	GROUND,
	WATER,
	FLYING,
}

var speed: int # How many movement do I gain every turn
var movement: int # How many tiles can I move
var block: int
var movement_type: Movement
var data: CombatantData


func _init(combatant_data: CombatantData = null) -> void:
	if !combatant_data:
		return
	data = combatant_data

	max_health = data.base_health
	current_health = max_health
	speed = data.base_speed
	movement = speed
	#if you want the hero to be able to fly/be a fish, set this using data instead
	movement_type = Movement.GROUND


func start_turn() -> void:
	movement = speed
	movement_changed.emit()
	block = 0


func take_damage(amount: int) -> void:
	if amount < block:
		block -= amount
	else:
		super(amount - block)
		block = 0


func gain_block(amount: int) -> void:
	block += amount


func spend_movement(amount: int) -> bool:
	if amount > movement:
		return false
	movement -= amount
	movement_changed.emit()
	return true


func gain_movement(amount: int) -> void:
	movement += amount
	movement_changed.emit()
