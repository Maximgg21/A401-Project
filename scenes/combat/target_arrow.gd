class_name TargetArrow
extends Node2D

@export_group("Arrow head")
@export var length: int = 36
@export var half_width: int = 24

var start_point: Vector2
var end_point: Vector2

@onready var line: Line2D = %Body
@onready var arrowhead: Polygon2D = %ArrowHead


func _ready() -> void:
	arrowhead.polygon = PackedVector2Array(
		[Vector2.ZERO, Vector2(-length, -half_width), Vector2(-length, half_width)]
	)
	stop()


func _process(_delta: float) -> void:
	end_point = get_global_mouse_position()
	var direction := end_point - start_point

	line.clear_points()
	line.add_point(start_point)
	line.add_point(end_point - direction.normalized() * length)

	arrowhead.position = end_point
	arrowhead.rotation = direction.angle()


func start(from: Vector2) -> void:
	start_point = from
	set_process(true)
	visible = true


func stop() -> void:
	set_process(false)
	visible = false
