class_name BlockEffect
extends CardEffect

@export var amount: int = 5


func get_description() -> String:
	return "Gain %d block" % amount
