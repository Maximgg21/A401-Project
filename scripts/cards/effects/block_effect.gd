class_name BlockEffect
extends CardEffect

@export var amount: int = 5


func apply(context: EffectContext) -> void:
	context.source.gain_block(amount)


func get_description() -> String:
	return "Gain %d block" % amount
