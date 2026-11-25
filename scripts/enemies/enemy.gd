class_name Enemy
extends Combatant

var enemy_data: EnemyData:
	# Convert parent's data: CombatantData into EnemyData
	get:
		return data as EnemyData


func _init(new_data: EnemyData) -> void:
	super(new_data)
	team = Team.ENEMY
