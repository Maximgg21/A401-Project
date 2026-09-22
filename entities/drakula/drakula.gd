extends CharacterBody2D


const SPEED = 100.0
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# Moving in 4 directions 
	var dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = dir * SPEED

	move_and_slide()
	
	if dir == Vector2.ZERO:
		sprite.play("idle")
	else:
		sprite.play("move")
		sprite.flip_h = dir.x < 0
