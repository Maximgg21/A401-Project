class_name DamageEffect
extends CardEffect

@export var amount: int
@export var upgraded: int


func apply(context: EffectContext) -> void:
	context.target.take_damage(amount)


func get_description() -> String:
	return "Deal %d damage" % amount
