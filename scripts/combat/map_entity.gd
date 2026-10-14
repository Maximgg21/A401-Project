class_name Entity
extends Resource
#this represents enemies, allies, and destructable objects
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
var position: Vector2i
var hp: int
var controlID: ControllerType #this represents what controls this entity, 0 = no control, 1 = player control, 2= ai control
var ai_type: int
var initiative: int
var movement_type: Movement
