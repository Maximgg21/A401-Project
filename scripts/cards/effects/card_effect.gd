class_name CardEffect
extends Resource


func apply(_context: EffectContext) -> void:
	## Get context to know who targets who
	push_error("apply in card_effect.gd wasn't overriden")


func get_description() -> String:
	## Description of the card effect
	push_error("No description provided")
	return ""


func needs_target() -> bool:
	## Card effect that needs a target for the card to be played
	return false
