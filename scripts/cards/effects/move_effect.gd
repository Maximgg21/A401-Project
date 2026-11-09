class_name MoveEffect
extends CardEffect

@export var amount: int = 2


func apply(context: EffectContext) -> void:
	context.source.gain_movement(amount)


func get_description() -> String:
	return "Move %d tiles" % amount
