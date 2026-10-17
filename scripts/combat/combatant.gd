class_name Combatant
extends MapEntity
#this represents enemies and allies
enum ControllerType {
	NONE,
	PLAYER,
	AI,
}
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
var control_id: ControllerType #this represents what controls this entity, 0 = no control, 1 = player control, 2= ai control
var team: Team
var movement_type: Movement
var movement_points: int
