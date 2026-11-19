class_name EnemyView
extends CombatantView

var enemy: Enemy


func setup(new_combatant: Combatant) -> void:
	super(new_combatant)
	enemy = new_combatant as Enemy

	sprite.play("idle")
