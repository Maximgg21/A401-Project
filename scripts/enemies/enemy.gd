class_name Enemy
extends Combatant

signal intent_changed

enum Intent {
	MOVE,
	ATTACK,
}

var intent: Intent = Intent.MOVE
var enemy_data: EnemyData:
	# Convert parent's data: CombatantData into EnemyData
	get:
		return data as EnemyData


func _init(new_data: EnemyData) -> void:
	super(new_data)
	team = Team.ENEMY


func set_intent(new_intent: Intent) -> void:
	intent = new_intent
	intent_changed.emit()
