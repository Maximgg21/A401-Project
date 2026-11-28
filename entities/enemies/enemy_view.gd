class_name EnemyView
extends CombatantView

var enemy: Enemy
var _idle_offset: Vector2

@onready var intent_label: Label = %IntentLabel


func setup(new_combatant: Combatant) -> void:
	super(new_combatant)
	enemy = new_combatant as Enemy
	enemy.intent_changed.connect(_on_intent_changed)
	_on_intent_changed()

	_idle_offset = sprite.offset
	sprite.animation_changed.connect(_on_animation_changed)
	sprite.play("idle")


func _on_animation_changed() -> void:
	# idle frames are 32px but run/death are 64px, so line up the frame bottoms
	var idle_height := sprite.sprite_frames.get_frame_texture("idle", 0).get_height()
	var height := sprite.sprite_frames.get_frame_texture(sprite.animation, 0).get_height()
	sprite.offset.y = _idle_offset.y - (height - idle_height) / 2.0


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
