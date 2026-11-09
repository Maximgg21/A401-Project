class_name CardEffect
extends Resource


func apply(_context: EffectContext) -> void:
	push_error("apply in card_effect.gd wasn't overriden")


func get_description() -> String:
	push_error("No description provided") # The function's not been overriden
	return ""
