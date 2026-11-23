class_name MovementOverlay
extends Node2D

@export var fill := Color(0.3, 0.7, 1.0, 0.35)
@export var border := Color(0.6, 0.85, 1.0, 0.9)
@export var font_size := 14

var fontslop := preload("res://assets/fonts/Cinzel/Cinzel-Regular.ttf")

var _renderer: MapRenderer
var _costs: Dictionary = { }


func setup(manager: CombatManager, renderer: MapRenderer) -> void:
	_renderer = renderer
	manager.reachable_changed.connect(_on_reachable_changed)


func _on_reachable_changed(costs: Dictionary) -> void:
	_costs = costs
	queue_redraw()


func _draw() -> void:
	if _renderer == null:
		return
	var size := _renderer.tile_pixel_size()
	var font := fontslop
	for cell in _costs:
		var center := to_local(_renderer.logical_to_global(cell))
		var rect := Rect2(center - size * 0.5, size)
		draw_rect(rect, fill)
		draw_rect(rect, border, false, 1.0)
		draw_string(
			font,
			Vector2(rect.position.x, center.y + font_size * 0.35),
			str(_costs[cell]),
			HORIZONTAL_ALIGNMENT_CENTER,
			size.x,
			font_size,
		)
