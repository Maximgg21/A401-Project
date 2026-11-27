class_name EnemyView
extends CombatantView

var enemy: Enemy

@onready var intent_label: Label = %IntentLabel


func setup(new_combatant: Combatant) -> void:
	super(new_combatant)
	enemy = new_combatant as Enemy
	enemy.intent_changed.connect(_on_intent_changed)
	_on_intent_changed()

	sprite.play("idle")


func _on_intent_changed() -> void:
	if enemy.intent == Enemy.Intent.ATTACK:
		intent_label.text = "ATK %d" % enemy.enemy_data.damage
		intent_label.modulate = Color(1, 0.3, 0.3)
	else:
		intent_label.text = "MOVE"
		intent_label.modulate = Color(0.75, 0.75, 0.75)


func _on_died() -> void:
	super()
	intent_label.hide()
