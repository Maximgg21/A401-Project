class_name CombatCamera
extends Camera2D

# TODO:
#remove input in hud while panning

@export var start_zoom := 2.0
@export var min_zoom := 1.0
@export var max_zoom := 4.0
@export var zoom_step := 1.25
@export var margin := Vector2(100, 100)
@export var center_offset := Vector2(0, 40)

var _bounds: Rect2
var _dragging := false
var _tween: Tween


func setup(renderer: MapRenderer) -> void:
	_bounds = renderer.map_global_rect().grow_individual(margin.x, margin.y, margin.x, margin.y)
	global_position = _bounds.get_center() + center_offset
	#TODO: center on the hero if map exceeds a certain size


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				_zoom_by(zoom_step)
			MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_by(1.0 / zoom_step)
			MOUSE_BUTTON_RIGHT:
				_dragging = event.pressed
	elif event is InputEventMouseMotion and _dragging:
		_kill_tween()
		global_position = _clamped(global_position + -event.relative / zoom.x)


func _zoom_by(factor: float) -> void:
	_kill_tween()
	var screen_off := get_viewport().get_mouse_position() - get_viewport_rect().size * 0.5
	var world_under_cursor := global_position + screen_off / zoom.x
	zoom = Vector2.ONE * clampf(zoom.x * factor, min_zoom, max_zoom)
	global_position = _clamped(world_under_cursor - screen_off / zoom.x)


func _kill_tween() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()


func _clamped(p: Vector2) -> Vector2:
	var half := get_viewport_rect().size / zoom * 0.5
	for axis in 2:
		if _bounds.size[axis] <= half[axis] * 2.0:
			p[axis] = (_bounds.get_center()[axis] + center_offset[axis])
		else:
			p[axis] = clampf(
				p[axis],
				_bounds.position[axis] + half[axis],
				_bounds.end[axis] - half[axis],
			)
	return p
