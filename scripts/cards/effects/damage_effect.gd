class_name DamageEffect
extends CardEffect

@export var amount: int = 6
@export var upgraded: int


func get_description() -> String:
	return "Deal %d damage" % amount
