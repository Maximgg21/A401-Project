extends CharacterBody2D

const SPEED := 90.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(_delta: float) -> void:
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * SPEED
	move_and_slide()
	_animate(dir)

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
