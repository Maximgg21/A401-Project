class_name EffectContext
extends RefCounted

var source: Combatant
var target: MapEntity


func _init(source: Combatant, target: MapEntity = null) -> void:
	self.source = source
	self.target = target
