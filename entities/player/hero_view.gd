class_name HeroView
extends CombatantView

var hero: Hero


func setup(new_combatant: Combatant) -> void:
	super(new_combatant)
	hero = new_combatant as Hero
	sprite.play("idle_down")


func _animate(dir: Vector2) -> void:
	var state := "idle" if dir == Vector2.ZERO else "walk"
	var facing := sprite.animation.trim_prefix("idle_").trim_prefix("walk_")

	if dir != Vector2.ZERO:
		if absf(dir.x) > absf(dir.y):
			facing = "side"
			sprite.flip_h = dir.x < 0
		else:
			facing = "down" if dir.y > 0 else "up"

	sprite.play("%s_%s" % [state, facing])


func _refresh() -> void:
	pass
