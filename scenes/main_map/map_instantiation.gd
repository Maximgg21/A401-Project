extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Replace with function body.
	load("res://entities/map_nodes/basic_map_node.tscn").instantiate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
