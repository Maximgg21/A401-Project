class_name MoveEffect
extends CardEffect

@export var amount: int = 2


func get_description() -> String:
	return "Move %d tiles" % amount
