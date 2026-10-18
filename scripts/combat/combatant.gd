class_name Combatant
extends MapEntity
#this represents enemies and allies
enum Movement {
	NONE,
	GROUND,
	WATER,
	FLYING,
}
enum Team {
	ALLY,
	ENEMY,
	NEUTRAL
}

signal movement_changed

var speed: int # How many movement do I gain every turn
var movement: int # How many tiles can I move
var team: Team
var movement_type: Movement

func start_turn() -> void:
	movement = speed
	movement_changed.emit()
	
